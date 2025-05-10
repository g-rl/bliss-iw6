#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\_utils;
#include scripts\_menu;
#include scripts\_functions;
#include scripts\_structure;
#include scripts\_binds;

/*
    bliss iw6x @nyli2b
    started: 4/26/25
    last update: 5/9/25

    exe and some functions from mirele @girlmachinery - thank you!!
*/

main()
{
    setdvar("sv_cheats", 1);
    setdvar("pm_bouncing", 1);
    setdvar("g_playercollision", 0);
    setdvar("g_playerejection", 0);
    setdvar("g_enableelevators", 1); // wont get stuck with fake eles as much
    setdvar("bg_surfacePenetration", 999999);
    setdvar("jump_slowdownenable", 0);
    // setdvar("jump_enablefalldamage", 0); // dont think i need this with damage_hook
    setdvar("sv_hostname", "bliss [setup & unsetup]");
    setdvar("panelafile", "hello"); // need this for fileread to work
}

init()
{
    thread on_player_connect();
    thread handle_snr(); // auto plant & team stuff

    level.original_damage = level.callbackPlayerDamage;
    level.callbackPlayerDamage = ::damage_hook; // no fall damage / always one shot
    level.is_debug = true; // for menu options
    wait 1;
    maps\mp\_utility::gameflagset("graceperiod_done");
}

on_player_connect()
{
    level endon("game_ended");

    for(;;) 
    {
        level waittill("connected", player);

        if (player.pers["team"] != "axis" && player.pers["team"] != "allies")
            player thread setup_teams();

        if (!isbot(player))
        {
            player thread on_event();
            player thread close_menu_game_over();
        }
        else
        {
            player thread on_bot_spawned(); // set bot ranks
        }
    }
}

on_event()
{
    self endon("disconnect");
    level endon("game_ended");

    self.bliss = [];

    for(;;) 
    {
        event_name = waittill_any_return("spawned_player", "player_downed", "death");

        switch(event_name)
        {
        case "spawned_player":

            // dont load options if spawned already
            if (isdefined(self.first_spawn))
                continue;

            self thread setup_memory(); // reload options n stuff

            // host checks
            if (self ishost())
            {
                self thread check_snr(); // kick player if gametype is not s&r
                self thread set_random_rounds(); // always cycle rounds
            }

            // setup menu & button monitoring 
            if (!isdefined(self.menu_init))
            {
                if (!isdefined(self.menu))
                    self.menu = [];

                self overflow_fix_init(); // does not work.
                self thread initial_variable(); // some other player threads are in here - _menu.gsc
                self thread initial_monitor();
                self thread monitor_buttons();
                self thread create_notify();
                self.menu_init = true;
                self.first_spawn = true;
            }

            // main player threads
            self thread class_change(); // always class change
            self thread change_health(); // change max health to 300
            self thread load_bots(); // make sure to load bot positions
            self thread load_self(); // load saved spawnpoint
            self thread bypass_intro(); // skip intro
            wait 1; // wait a second to apply ranks correctly
            self setrank(59, randomintrange(10,12)); // always try to set max rank
            break;
        case "death":
        case "player_downed":
        default:
            self thread close_menu_if_open();
            break;
        }
    }
}

on_bot_spawned()
{
    self endon("disconnect");
    level endon("game_ended");

    for(;;)
    {
        self waittill("spawned_player");
        wait 1; // wait a sec or they wont set 
        self setrank(59, randomint(11));
    }
}

// memory
setup_memory()
{
    camo_list = randomize("15,39,33,27,13,36"); // i like these camos lol
    perk_list = list("specialty_bulletaccuracy,specialty_quickswap,specialty_fastoffhand,specialty_marathon,specialty_bulletpenetration"); // default perks

    // using setpersifuniold as well until i fix saving
    self setpersifuniold("unstuck", self.origin);
    self setpersifuni("camo", int(camo_list));
    self setpersifuni("smooth_can_time", "0.2");

    // only load these settings from host data
    if (self ishost())
    {
        setdvarifuni("timescale", 1);
        setdvarifuni("scr_killcam_time", 5);
        setdvarifuni("timer_paused", 0);
        setdvarifuni("g_gravity", 800);
        setdvarifuni("g_speed", 190);  
        setslowmotion(getdvarfloat("timescale"), getdvarfloat("timescale"), 0);
        level thread reload_bomb(); // repause timer if enabled
    }

    // reload toggles etc on spawn
    self setup_pers("instashoots", ::inphectinstashootloop);
    self setup_pers("always_canswap", ::alwayscanswaploop);
    self setup_pers("smooth_canswaps", ::smoothcanswapsloop);
    self setup_pers("freeze_bots", ::freeze_loop);
    self setup_pers("eq_swap", ::eq_swap_loop);
    self setup_pers("instant_eq", ::insta_eq_loop);
    self setup_pers("auto_prone", ::auto_prone);
    self setup_pers("game_end_prone", ::prone_make_sure);
    self setup_pers("auto_reload", ::auto_reload);
    self setup_pers("elevators", ::elevators);
    self setup_pers("pink", ::pink_loop);
    self setup_pers("alt_swap", ::g_weapon, "iw6_m9a1_mp");
    self setup_pers("instashoots_reg", ::instashootloop);
    self setup_pers("insta_pumps", ::insta_pump_loop);

    // reload binds on spawn 
    self setup_bind("sprint_loop", false, ::sprintloopbind);
    self setup_bind("lunge", false, ::lungebind);
    self setup_bind("mala", false, ::malabind);
    self setup_bind("illusion", false, ::illusioncanswapbind);
    self setup_bind("smooth", false, ::smoothbind);
    self setup_bind("gunlock", false, ::gunlockbind);
    self setup_bind("glide", false, ::glidebind);
    self setup_bind("care_package", false, ::care_package_stall);
    self setup_bind("tilt", false, ::stz_tilt_bind);

    // give and save perks 
    foreach(perk in perk_list)
    if (!is_true(self.pers["my_perks"][perk]))
        self.pers["my_perks"][perk] = perk;

    // setup bounce
    self setpersifuniold("bouncecount", "0");
    for(i=1; i<8; i++)
        self setpersifuniold("bouncepos" + i, "0");

    // setup camo array for menu
    if (!isdefined(level.camoarray))
    {
        level.camoarray = [];
        for(i=10; i<46; i++)
        {
            level.camoarray[level.camoarray.size] = i;
        }
    }

    if (getdvarint("bouncecount") >= 1)
    {
        self notify("stop_bounce_loop");
        self thread bounce_loop(); // watch for placed bounces
    }

    // apply weapon stuff after everything
    self handle_camo(); // handle camos from menu selection for both weapons 
    self set_perks(); // set default & custom set perks on spawn
    self refill_ammo(); // refill ammo cuz why not
    self freezecontrols(0);
}