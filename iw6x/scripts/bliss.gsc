#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include scripts\utils;
#include scripts\menu;
#include scripts\functions;
#include scripts\structure;

/*
    bliss iw6x @nyli2b
    started: 4/26/25
    last update: 5/1/25
*/

main()
{
    setdvar("sv_cheats", 1);
    setdvar("pm_bouncing", 1);
    setdvar("g_playercollision", 0);
    setdvar("g_playerejection", 0);
    setdvar("bg_surfacePenetration", 999999);
    setdvar("jump_slowdownEnable", 0);
    setdvar("jump_enablefalldamage", 0);
    setdvar("safeArea_adjusted_horizontal", 1);
    setdvar("safeArea_adjusted_vertical", 1);
    setdvar("safeArea_horizontal", 0.9);
    setdvar("safeArea_vertical", 0.9);
    setdvar("sv_hostname", "bliss [setup & unsetup]");
    setdvar("panelafile", "hello");
}

init()
{
    thread on_player_connect();
    thread handle_snr();

    level.original_damage = level.callbackPlayerDamage;
    level.callbackPlayerDamage = ::damage_hook;
    level.is_debug = true;

    // dont think these are doing anything
    level.ononeleftevent = undefined;
    wait 1;
    level.allowlatecomers = 1;
    level.graceperiod = 0;
    level.ingraceperiod = 0;
    level.prematchperiod = 0;
    level.waitingforplayers = 0;
    level.prematchperiodend = 0;
}

on_player_connect()
{
    level endon("game_ended");

    for(;;) 
    {
        level waittill("connected", player);

        if (player.pers["team"] != "axis" && player.pers["team"] != "allies")
        {
            player thread setup_teams();
        }

        if (!isbot(player))
        {
            player thread on_event();
            player thread close_menu_game_over();
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

            if (isdefined(self.first_spawn))
                continue;
            self.first_spawn = true;

            // host checks
            if (self ishost())
            {
                // only load match if gametype is search & rescue
                if (level.gametype != "sr")
                {
                    iprintlnbold("must be loaded on ^:search & rescue");
                    wait (randomintrange(3, 4));
                    exitlevel();
                    return;
                }
                self thread set_random_rounds(); // always cycle rounds
            }
            
            // setup the menu
            if (!isdefined(self.menu))
                self.menu = [];

            // setup button monitoring & menu variables
            if (!isdefined(self.menu_init))
            {          
                self overflow_fix_init(); // does not work.
                self thread initial_variable(); // other player threads are in here
                self thread initial_monitor();
                self thread monitor_buttons();
                self thread create_notify();
                self.menu_init = true;
            }

            self thread class_change(); // always class change
            self thread change_health(); // change max health to 300
            self thread load_bots(); // make sure to load bot positions
            self thread load_self(); // load saved spawnpoint
            self thread bypass_intro(); // skip intro
            // self thread kem_strike(); // auto kem strikes on third round
            break;
        case "death":
        case "player_downed":
        default:
            self thread close_menu_if_open();
            break;
        }
    }
}

// memory
pers_catcher()
{
    camo_list = randomize("15,39,33,27,13,36"); // i like these camos lol
    perk_list = list("specialty_bulletaccuracy,specialty_quickswap,specialty_fastoffhand,specialty_marathon,specialty_bulletpenetration"); // default perks

    // only load these settings from host data
    if (self ishost())
    {
        setdvarifuni("timescale", 1);
        setdvarifuni("scr_killcam_time", 5);
        setdvarifuni("timer_paused", 0);
        setdvarifuni("g_gravity", 800);
        setdvarifuni("g_speed", 190);  
        setslowmotion(getdvarfloat("timescale"), getdvarfloat("timescale"), 0); 
    }
    
    // using setpersifuniold as well until i fix saving
    self setpersifuniold("unstuck", self.origin);
    self setpersifuni("camo", int(camo_list));
    self setpersifuni("smooth_can_time", "0.2");

    // bind persistence 
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
    
    if (is_true(self getpers("instashoots")))
        self thread inphectinstashootloop();

    if (is_true(self getpers("always_canswap")))
        self thread alwayscanswaploop();

    if (is_true(self getpers("smooth_canswaps")))
        self thread smoothcanswapsloop();

    if (is_true(self getpers("stz_tilt")))
        self thread stz_tilt_bind();

    if (is_true(self getpers("freeze_bots")))
        self thread freeze_loop();

    if (is_true(self getpers("eq_swap")))
        self thread eq_swap_loop();

    if (is_true(self getpers("instant_eq")))
        self thread insta_eq_loop();
    
    if (is_true(self getpers("auto_prone")))
        self thread auto_prone();

    if (is_true(self getpers("game_end_prone")))
        self thread prone_make_sure();

    if (is_true(self getpers("auto_reload")))
        self thread auto_reload();

    if (is_true(self getpers("elevators")))
        self thread elevators();

    if (is_true(self getpers("pink")))
        self thread pink_loop();

    if (is_true(self getpers("alt_swap")))
        self giveweapon("iw6_m9a1_mp");

    if (is_true(self getpers("stall")))
        self thread care_package_stall();

    if (is_true(self getpers("instashoots_reg")))
        self thread instashootloop();
    
    if (is_true(self getpers("insta_pumps")))
        self thread insta_pump_loop();

    // repause timer
    if (getdvarint("timer_paused") == 1)
    {
        level thread maps\mp\gametypes\_gamelogic::pausetimer(); // _gamelogic
        level notify("stop_auto_bomb"); // stop auto plant
    }

    // setup bounce
    self setpersifuni("bouncecount", "0");  
    for(i=1; i<8; i++)
    {
        self setpersifuni("bouncepos" + i, "0");
        waitframe();
    }

    // setup camo array for menu
    if (!isdefined(level.camoarray))
    {
        level.camoarray = [];
        for(i=10; i<46; i++)
        {
            level.camoarray[level.camoarray.size] = i;
        }
    }

    // so everything applies correctly
    self handle_camo(); // handle camos from menu selection for both weapons 
    self set_perks(); // set default & custom set perks on spawn
    self refill_ammo(); // refill ammo cuz why not
    self freezecontrols(0);

    // these are broken asf right now idk why lmfao
    /* 
    // self setpersifuni("unstuck", self.origin);
    self setpersifuni("smooth_can_time", 0.2);
    self setpersifuni("always_canswap", false);
    self setpersifuni("smooth_canswaps", false);
    self setpersifuni("stz_tilt", false);
    self setpersifuni("freeze_bots", false);
    self setpersifuni("instashoots", false);
    self setpersifuni("eq_swap", false);
    self setpersifuni("instant_eq", false);
    self setpersifuni("auto_prone", false);
    self setpersifuni("game_end_prone", false);
    self setpersifuni("stall", false);
    self setpersifuni("pink", false);
    self setpersifuni("auto_reload", false);
    self setpersifuni("alt_swap", false);
    self setpersifuni("elevators", false);
    self setpersifuni("is_saved", false);
    self setpersifuni("freeze_bots", false);
    */
    // setdvarifuni("unstuck_origin_" + getdvar("mapname"), self getorigin()[0] + "," + self getorigin()[1] + "," + self getorigin()[2]);

}