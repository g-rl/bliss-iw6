#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\_utils;
#include scripts\_binds;
#include scripts\_menu;

bot_classes()
{
    bot_camos = randomintrange(10,46);
    prestige = randomint(11);
    weapon = randomize("iw6_mk14_mp_mk14scope,iw6_svu_mp_svuscope,iw6_sc2010_mp,iw6_bren_mp,iw6_usr_mp_usrscope,iw6_l115a3_mp_l115a3scope,iw6_microtar_mp,iw6_vks_mp_vksscope,iw6_dlcweap03_mp_dlcweap03scope,iw6_k7_mp,iw6_maul_mp,iw6_lsat_mp,iw6_ak12_mp,iw6_arx160_mp,iw6_dlcweap01_mp,iw6_pp19_mp,iw6_vepr_mp,iw6_microtar_mp,iw6_dlcweap03_mp,iw6_mts255_mp,iw6_sc2010_mp,iw6_gm6helisnipe_mp,iw6_l115a3_mp,iw6_m27_mp,iw6_kriss_mp,iw6_cbjms_mp");
    self giveweapon(weapon);
    self switchtoweapon(weapon);
    self setcamobot(bot_camos);
    self thread maps\mp\gametypes\horde::setravagermodel();
    wait 1; // wait a sec or ranks wont set
    self setrank(59, prestige);
}

toggle_save_and_load()
{
    self.pers["save_and_load"] = !toggle(self.pers["save_and_load"]);

    if (self getpers("save_and_load"))
    {
        self thread save_pos_bind();
        self thread load_pos_bind();
    }
    else
    {
        self notify("stopsavepos");
        self notify("stoploadpos");
    }
}

save_position()
{
    self setpers("saveposx", self getorigin()[0]);
    self setpers("saveposy", self getorigin()[1]);
    self setpers("saveposz", self getorigin()[2]);
    self setpers("saveangles1", self getangles()[0]);
    self setpers("saveangles2", self getangles()[1]);
    self setpers("saveangles3", self getangles()[2]);
    self notify("savedpos");
}

load_position()
{
    if (float(self getpers("saveposx")) == 0 && float(self getpers("saveposy")) == 0 && float(self getpers("saveposz")) == 0)
        return;

    self setvelocity((0,0,0));
    self setorigin((float(self getpers("saveposx")), float(self getpers("saveposy")), float(self getpers("saveposz"))));
    self setplayerangles((0, float(self getpers("saveangles2")), is_true(self getpers("stz_tilt")) ? 180 : 0));
}

always_pickup_bomb()
{
    if (getdvarint("pickup_bomb") == 0)
    {
        setdvar("pickup_bomb", 1);
        self thread pickup_bomb();
    }
    else
    {
        setdvar("pickup_bomb", 0);
    }
}

enable_cheats()
{
    if (getdvarint("enable_cheats") == 0)
    {
        setdvar("enable_cheats", 1);
        self setpers("wm_color", "^1");
    }
    else
    {
        setdvar("enable_cheats", 0);
        self setpers("wm_color", "^:");
        self thread watch_cheats();
    }
}

watch_cheats()
{
    foreach(cheater in level.players) // unset it for all players
    {
        cheats = list("pink,save_and_load,is_saved,saved_position");
        cheater unsetpers(cheats);

        cheater notify("stopsavepos");
        cheater notify("stoploadpos");
        cheater notify("stop_pink");
    }
}

end_round()
{
    maps\mp\gametypes\sr::sd_endGame(game["attackers"], game["end_reason"][game["defenders"]+"_eliminated"]);
}

pause_timer()
{
    if (getdvarint("timer_paused") == 0)
    {
        setdvar("timer_paused", 1);
        level thread maps\mp\gametypes\_gamelogic::pausetimer();
        level notify("stop_auto_plant"); // stop auto plant
        iprintlnbold("^:" + self get_name() + " ^7paused the timer");
    } 
    else 
    {
        setdvar("timer_paused", 0);
        level thread maps\mp\gametypes\_gamelogic::resumetimer();
        level thread auto_plant(); // resume auto plant
        iprintlnbold("^:" + self get_name() + " ^7resumed the timer");
    }
}

toggle_knife_lunge()
{
    self.pers["knife_lunge"] = !toggle(self.pers["knife_lunge"]);

    if (self getpers("knife_lunge"))
    {
        self thread knife_lunge();
    }
    else
    {
        self notify("stop_knife_lunge");
    }
}

knife_lunge()
{
	self endon("disconnect");
	self endon("stop_knife_lunge");
    level endon("game_ended");

    for(;;)
    {

        self waittill("+melee_zoom");

        if (self in_menu() || !self isonground())
            continue;

        if (is_true(self.lunge))
            self.lunge delete();

        self.lunge = spawn("script_origin" , self.origin);
        self.lunge setmodel("tag_origin");
        self.lunge.origin = self.origin;

        self playerlinkto(self.lunge, "tag_origin", 0, 180, 180, 180, 180, true);
        vec = anglestoforward(self getplayerangles());
        lunge = (vec[0] * 255, vec[1] * 255, 0);
        self.lunge.origin = self.lunge.origin + lunge;

        instashoot();
        setweaponanim(11); // knife lunge anim
        wait 0.1803;
        self unlink();
    }
}

toggle_perk(perk) // toggle & store perk data
{
    if (!self _hasperk(perk))
    {
        self _setperk(perk, false);
        self.pers["my_perks"][perk] = perk;
        self iprintln("^:" + perk + " ^7given");
    }
    else
    {
        self _unsetperk(perk);
        self.pers["my_perks"][perk] = false;
        self iprintln("^:" + perk + " ^7taken");
    }
}

change_camo(value)
{
    if ("" + value == "none")
    {
        self setpers("camo", "none");
        self removecamo();
        self removecamonext();
    }
    else
    {
        self setcamo(value);
        self setcamonext(value);
        self setpers("camo", value);
    }
}

drop_canswap()
{
    weapons = randomize("iw6_mk14_mp_mk14scope,iw6_svu_mp_svuscope,iw6_sc2010_mp,iw6_bren_mp,iw6_usr_mp_usrscope,iw6_l115a3_mp_l115a3scope,iw6_microtar_mp,iw6_vks_mp_vksscope,iw6_dlcweap03_mp_dlcweap03scope,iw6_k7_mp,iw6_maul_mp,iw6_lsat_mp,iw6_ak12_mp,iw6_arx160_mp,iw6_dlcweap01_mp,iw6_pp19_mp,iw6_vepr_mp,iw6_microtar_mp,iw6_dlcweap03_mp,iw6_mts255_mp,iw6_sc2010_mp,iw6_gm6helisnipe_mp,iw6_l115a3_mp,iw6_m27_mp,iw6_kriss_mp,iw6_cbjms_mp");
    self giveweapon(weapons);
    self switchtoweapon(weapons);
    self setdropcamo(weapons, self getpers("camo")); // apply camo to weapon
}

weapon_settings(setting)
{
    if (setting == "drop canswap")
        self thread drop_canswap();

    if (setting == "refill ammo")
        self thread refill_ammo();

    if (setting == "drop weapon")
        self thread drop_weapon();

    if (setting == "take weapon")
        self thread take_weapon();
}

toggle_alt_swaps()
{
    self.pers["alt_swap"] = !toggle(self.pers["alt_swap"]);

    if (self getpers("alt_swap"))
    {
        self giveweapon("iw6_m9a1_mp");
        self switchtoweapon("iw6_m9a1_mp");
    }
    else
    {
        self notify("stop_alt_swap");
        next = self getnextweapon();
        self takeweapon("iw6_m9a1_mp");
        self switchtoweapon(next);
    }
}

toggle_instant_eq()
{
    self.pers["instant_eq"] = !toggle(self.pers["instant_eq"]);

    if (self getpers("instant_eq"))
        self thread insta_eq_loop();
    else
        self notify("stop_insta_eq");
}

insta_eq_loop()
{
    self endon("stop_insta_eq");
    self endon("disconnect");

    for(;;)
    {
        self waittill("grenade_pullback");
        setweaponanimtime(0);
    }
}

toggle_instant_pump()
{
    self.pers["insta_pumps"] = !toggle(self.pers["insta_pumps"]);

    if (self getpers("insta_pumps"))
        self thread insta_pump_loop();
    else
        self notify("stop_insta_pumps");
}

insta_pump_loop()
{
    self endon("stop_insta_pumps");
    self endon("disconnect");
    level endon("game_ended");

    for(;;)
    {
        self waittill("weapon_fired");

        if (getweaponclass(self getcurrentweapon()) == "weapon_shotgun")
            smoothaction();

        wait 0.1;
    }
}

toggle_elevators()
{
    self.pers["elevators"] = !toggle(self.pers["elevators"]);

    if (self getpers("elevators"))
        self thread elevators();
    else
        self notify("stop_elevators");
}

elevators()
{
    self endon("disconnect");
    self endon("stop_elevators");
    level endon("game_ended");

    for(;;)
    {
        if (self adsbuttonpressed() && self isbuttonpressed("+stance") && self isonground() && !self isonladder() && !self ismantling())
        {
            self thread elevator_logic();
            wait 0.25;
        }
        else if (self jumpbuttonpressed())
        {
            self thread stop_elevator();
            wait 0.05;
        }

        wait 0.05;
    }
}

elevator_logic()
{
    self endon("end_elevator");
    level endon("game_ended");
    self endon("disconnect");

    self.elevator = spawn("script_origin", self.origin, 1);
    self playerlinkto(self.elevator, undefined);

    for(;;)
    {
        self.elevating = true;
        self.o = self.elevator.origin;
        wait 0.05;
        time = randomintrange(8,20);
        self.elevator.origin = self.o + (0, 0, time);
        wait 0.05;
    }
}

stop_elevator()
{
    if (is_true(self.elevator))
    {
        self unlink();
        self.elevator delete();
        self.elevating = undefined;
        self notify("end_elevator");
    }
}

toggle_auto_reload()
{
    self.pers["auto_reload"] = !toggle(self.pers["auto_reload"]);

    if (self getpers("auto_reload"))
        self thread auto_reload();
    else
        self notify("stop_auto_reload");
}

auto_reload()
{
    self endon("stop_auto_reload");
    self endon("disconnect");
    level waittill("game_ended");

    weapon = self getcurrentweapon();
    self setweaponammoclip(weapon, 0);
}

toggle_auto_prone()
{
    self.pers["auto_prone"] = !toggle(self.pers["auto_prone"]);

    if (self getpers("auto_prone"))
        self thread auto_prone();
    else
        self notify("stop_auto_prone");
}

toggle_game_end_prone()
{
    self.pers["game_end_prone"] = !toggle(self.pers["game_end_prone"]);

    if (self getpers("game_end_prone"))
        self thread prone_make_sure();
    else
        self notify("stop_game_end_prone");
}

auto_prone()
{
    self endon("disconnect");
    self endon("stop_auto_prone");
    level endon("killcam_begin"); // instead of game_ended

    self thread prone_make_sure();

    for(;;)
    {
        self waittill("weapon_fired", weapon);

        if (self isonground() || self isonladder() || self ismantling() || is_true(self.elevating))
        {
            wait 0.05;
            continue;
        }

        if (is_valid_weapon(weapon))
        {
            self thread loop_auto_prone();
            wait 0.2; // might have to rework this value a little bit due to it proning over and over sometimes
            self notify("temp_end");
        }
        else
        {
            wait 0.05;
            continue;
        }

        wait 0.05;
    }
}

loop_auto_prone()
{
    self endon("temp_end");
    self endon("stop_auto_prone");
    self endon("disconnect");
    level endon("killcam_begin"); // instead of game_ended

    for(;;)
    {
        self setstance("prone");
        wait .01;
    }
}

prone_make_sure()
{
    self endon("stop_auto_prone");
    self endon("stop_game_end_prone");
    self endon("disconnect");
    level waittill_any("game_ended", "end_of_round");
    self thread end_game_prone();
}

end_game_prone()
{
    self endon("stop_auto_prone");
    self endon("disconnect");

    for(i=0; i<10; i++)
    {
        self setstance("prone");
        wait 0.1;
    }
}

toggle_freeze_bots()
{

    self.pers["freeze_bots"] = !toggle(self.pers["freeze_bots"]);

    if (self getpers("freeze_bots"))
    {
        /*
        if (getotherteam(self.team).size == 0)
        {
            self iprintln("spawn a bot first!");
            self setpers("freeze_bots", false);
            return;
        }
        */
        
        self thread freeze_loop();
        
        // teleport bots to crosshair
        ents = getentarray();
        foreach(ent in ents)
        if (ent != self && isdefined(ent.team) && self.team != ent.team && isalive(ent))
        {
            ent setorigin(self getcrosshair());
            self.pers["bot_position"] = ent.origin;
        }
    }
    else
    {
        self notify("stop_freeze");

        ents = getentarray();
        foreach(ent in ents)
        if (ent != self && isdefined(ent.team) && self.team != ent.team && isalive(ent))
            ent freezecontrols(false);
    }
}

freeze_loop()
{
    self endon("stop_freeze");
    self endon("disconnect");
    level endon("game_ended");

    for(;;)
    {
        ents = getentarray();
        foreach(ent in ents)
        {
            if (ent != self && isdefined(ent.team) && self.team != ent.team && isalive(ent))
            {
                ent freezecontrols(true);
                ent setstance("stand");
                ent setorigin(self.pers["bot_position"]);
            }
        }
        wait 0.05;
    }
}

toggle_eq_swap()
{
    self.pers["eq_swap"] = !toggle(self.pers["eq_swap"]);

    if (self getpers("eq_swap"))
        self thread eq_swap_loop();
    else
        self notify("stop_eq_swap");
}

eq_swap_loop()
{
    self endon("stop_eq_swap");
    self endon("disconnect");
    level endon("game_ended");

    for(;;)
    {
        self waittill("grenade_pullback");
        self switchto(self getprevweapon());
    }
}

toggle_always_canswap()
{
    self.pers["always_canswap"] = !toggle(self.pers["always_canswap"]);

    if (self getpers("always_canswap"))
        self thread alwayscanswaploop();
    else
        self notify("stop_always_canswap");
}

alwayscanswaploop()
{
    self endon("stopalwayscanswaploop");
    self endon("disconnect");
    level endon("game_ended");

    for(;;)
    {
        setallcanswaps();
        wait 0.05;
    }
}

toggle_smooth_canswaps()
{
    self.pers["smooth_canswaps"] = !toggle(self.pers["smooth_canswaps"]);

    if (self getpers("smooth_canswaps"))
        self thread smoothcanswapsloop();
    else
        self notify("stop_smooth_canswaps");
}

smooth_can_time(value)
{
    self setpers("smooth_can_time", float(value));
}

smoothcanswapsloop()
{
    self endon("stop_smooth_canswaps");
    self endon("disconnect");
    
    for(;;)
    {
        self waittill("weapon_change");
        if (self getpers("always_canswap") == true)
        {
            wait (float(self getpers("smooth_can_time")));
            if (israising())
                smoothaction();
        }
        else
        {
            if (self getcurrentweapon() == self getpers("canswap_weapon"))
            {
                wait (float(self getpers("smooth_can_time")));
                if (israising())
                    smoothaction();
            }
        }
    }
}

toggle_reg_instashoots()
{
    self.pers["instashoots_reg"] = !toggle(self.pers["instashoots_reg"]);

    if (self getpers("instashoots_reg"))
        self thread instashootloop();
    else
        self notify("stop_reg_instashoots");
}

instashootloop()
{
    self endon("stop_instashoots");
    self endon("disconnect");
    level endon("game_ended");

    for(;;)
    {
        self waittill("weapon_change");
        if (is_valid_weapon(self getcurrentweapon()))
            instashoot();
    }
}

toggle_instashoots()
{
    self.pers["instashoots"] = !toggle(self.pers["instashoots"]);

    if (self getpers("instashoots"))
        self thread inphectinstashootloop();
    else
        self notify("stop_instashoots");
}

inphectinstashootloop()
{
    self endon("stop_instashoots");
    self endon("disconnect");
    level endon("game_ended");

    for(;;)
    {
        if (israising())
        {
            if (self attackbuttonpressed())
                instashoot();
            wait 0.1;
        }
        wait 0.05;
    }
}

give_vish()
{
    self setspawnweapon("none");
}

give_cowboy()
{
    current = self getcurrentweapon();
    x = "iw6_dlcweap02_mp_dlcweap02scope"; // ripper
    scale = getdvarfloat("timescale");
    self giveweapon(x);
    self setspawnweapon(x);
    setdvar("camera_thirdperson", 1);
    setdvar("player_sustainammo", 1);
    setslowmotion(10, 10, 0);
    wait 20;
    setdvar("player_sustainammo", 0);
    setslowmotion(scale, scale, 0);
    self takeweapon(x);
    self iprintlnbold("[{+actionslot 1}] to cowboy");
    self waittill("+actionslot 1");
    self switchtoweapon(current);
    self setspawnweapon(current);
    waitframe();
    setdvar("camera_thirdperson", 0);
}

give_certain_streak(streak)
{
    if (streak == "fill all")
        self thread fill_streaks();

    if (streak == "vests")
        self give_streak("deployable_vest");
    
    if (streak == "ammo crate")
        self give_streak("deployable_ammo");

    if (streak == "odin")
        self give_streak("odin_support");
    
    if (streak == "kem strike")
        self give_streak("nuke");

    if (streak == "oracle")
        self give_streak("uav_3dping");

    if (streak == "care package")
        self give_streak("airdrop_support");
}

give_streak(streak)
{
    self thread maps\mp\killstreaks\_killstreaks::givekillstreak(streak, false, false, self);
}

fill_streaks()
{
    foreach(streak in self.killstreaks)
        self maps\mp\killstreaks\_killstreaks::givekillstreak(streak, true);
}

refill_ammo()
{
    x = self GetWeaponsListPrimaries();

    foreach(gun in x)
    {
        self setweaponammoclip(gun, 999);
        self setweaponammostock(gun, 999);
    }

    self givemaxammo(self getcurrentoffhand()); // set twice just in case lol

    if (self getcurrentoffhand() == "none") // attempt to give throwing knife if no offhand
        self giveperkoffhand("throwingknife_mp", false);

    self givemaxammo(self getcurrentoffhand());
}

load_bots()
{
    foreach(player in level.players)
        if ((isalive(player)) && isbot(player))
            if (is_true(self.pers["freeze_bots"]))
                player setorigin(self.pers["bot_position"]);
}

toggle_saved_pos()
{
    self.pers["is_saved"] = !toggle(self.pers["is_saved"]);

    if (self getpers("is_saved"))
        self setpers("saved_position", self.origin);
    else
        self setpers("saved_position", false);
}

load_self()
{
    if (isalive(self))
        if (is_true(self.pers["is_saved"]))
            self setorigin(self getpers("saved_position"));
}

kem_strike()
{
    if (getteamscore("allies") == 3 || getteamscore("axis") == 3)
    {
        self maps\mp\killstreaks\_killstreaks::givekillstreak("nuke", false);
        self.pers["kills"] = 25;
        self.kills = 25;
        self.pers["score"] = 2350;
        self.score = 2200;
    }
}

toggle_pink()
{
    self.pers["pink"] = !toggle(self.pers["pink"]);

    if (self getpers("pink"))
        self thread pink_loop();
    else
        self notify("stop_pink");
}

pink_loop()
{
    self endon("stop_pink");
    self endon("disconnect");
    level endon("game_ended");

    for(;;)
    {
        self waittill("weapon_fired");
        ents = getentarray();
        center = self getcrosshair();
        foreach(ent in ents)
        {
            if (ent != self && isdefined(ent.team) && self.team != ent.team && isalive(ent))
            {
                if (is_valid_weapon(self getcurrentweapon()) && distance(ent.origin, center) < randomintrange(100,500))
                {
                    ent dodamage(ent.health + 100, ent.origin, self, self);
                    waitframe();
                    self setclientomnvar("ui_points_popup", 250); 
                }
            }
        }
    }
}

manage_bounce(value)
{
    if (value == "spawn")
        self thread spawn_bounce();
    
    if (value == "delete")
        self thread delete_bounce();
}

spawn_bounce()
{
    x = int(self getpers("bouncecount"));
    x++;

    self setpers("bouncecount", x);
    self setpers("bouncepos" + x, self getorigin()[0] + "," + self getorigin()[1] + "," + self getorigin()[2]);
    self iprintln("spawned a bounce at ^:" + self getorigin());
    
    if (x == 1)
    {
        self notify("stop_bounce_loop");
        self thread bounce_loop(); // watch for placed bounces
    }
}

delete_bounce()
{
    x = int(self getpers("bouncecount"));

    if (x == 0)
        return self iprintln("no bounces to delete");

    self iprintln("^:bounce #" + x + " deleted");
    x--;
    self setpers("bouncecount", x);
}

bounce_loop()
{
    self endon("stop_bounce_loop");
    
    for(;;)
    {
        for(i=1; i < int(self getpers("bouncecount")) + 1; i++)
        {
            pos = perstovector(self getpers("bouncepos" + i));

            if (distance(self getorigin(), pos) < 90 && self getvelocity()[2] < -250)
            {
                self setvelocity(self getvelocity() - (0,0,self getvelocity()[2] * 2));
                wait 0.2;
            }
        }
        waitframe();
    }
}

fast_last()
{
    if (getdvar("g_gametype") == "dm")
        self set_score(int(getwatcheddvar("scorelimit") - 1));
    else
        self iprintlnbold("must be ffa");
}

set_score(kills)
{
    self.score = kills;
    self.pers["score"] = self.score;
    self.kills = kills;
    self.pers["kills"] = self.kills;
}

change_gravity(value)
{
    setdvar("g_gravity", value);
}

change_speed(value)
{
    setdvar("g_speed", value);
}

change_killcam_time(value)
{
    setdvar("scr_killcam_time", float(value));
}

change_timescale(value)
{
    setdvar("timescale", float(value));
    setslowmotion(getdvarfloat("timescale"), getdvarfloat("timescale"), 0);
}

change_elevators(value)
{
    setdvar("g_enableelevators", value);
}

change_bouncing(value)
{
    setdvar("pm_bouncing", value);
}

change_health()
{
    self.maxhealth = 300;
    self.health = self.maxhealth;
}