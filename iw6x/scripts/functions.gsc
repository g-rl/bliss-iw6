#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gamelogic;
#include common_scripts\utility;
#include scripts\utils;
#include scripts\menu;

toggle_sprint_loop(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    // self iprintln(new);
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;
    
	if (self.pers[index])
    {
		self iprintln("sprint loop ^2on");
		self thread sprintloopbind(bind, pers);
        // self.pers["test_bind_" + new] = false;
	}
	else
	{
		self iprintln("sprint loop ^1off");
		self notify("stop" + pers);
	}
}

sprintloopbind(bind, endonstring) 
{
    self notify("stop" + endonstring);
    self endon("stop" + endonstring);
    self endon("disconnect");
   
    for(;;) 
    {
        self waittill(bind);
        if (!self in_menu())
        {
            instashoot();
            setweaponanim(32);
        }
        wait 0.1;
    }
}

toggle_mala(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;
    
	if (self.pers[index])
    {
		self iprintln("mala bind ^2on");
		self thread malabind(bind, pers);
	}
	else
	{
		self iprintln("mala bind ^1off");
		self notify("stop" + pers);
	}
}

malabind(bind, endonstring) 
{
    self notify("stop" + endonstring);
    self endon("stop" + endonstring);
    self endon("disconnect");
   
    for(;;) 
    {
        self waittill(bind);
        if (!self in_menu())
        {
            setweaponflag(2);
        }
        wait 0.1;
    }
}

toggle_illusion(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;
    
	if (self.pers[index])
    {
		self iprintln("illusion canswap bind ^2on");
		self thread illusioncanswapbind(bind, pers);
	}
	else
	{
		self iprintln("illusion canswap bind ^1off");
		self notify("stop" + pers);
	}
}

toggle_smooth(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;
    
	if (self.pers[index])
    {
		self iprintln("smooth bind ^2on");
		self thread smoothbind(bind, pers);
	}
	else
	{
		self iprintln("smooth bind ^1off");
		self notify("stop" + pers);
	}
}

gunlockbind(bind, endonstring) 
{
    self notify("stop" + endonstring);
    self endon("stop" + endonstring);
    self endon("disconnect");
   
    for(;;) 
    {
        self waittill(bind);
        if (!self in_menu())
        {
            self SwitchToWeaponImmediate("alt_" + self GetCurrentWeapon());
            waitframe();
            self canswap();
        }
        wait 0.1;
    }
}

toggle_gunlock(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;
    
	if (self.pers[index])
    {
		self iprintln("gunlock ^2on");
		self thread gunlockbind(bind, pers);
	}
	else
	{
		self iprintln("gunlock ^1off");
		self notify("stop" + pers);
	}
}

smoothbind(bind, endonstring) 
{
    self notify("stop" + endonstring);
    self endon("stop" + endonstring);
    self endon("disconnect");
   
    for(;;) 
    {
        self waittill(bind);
        if (!self in_menu())
        {
            smoothaction();
        }
        wait 0.1;
    }
}

illusioncanswapbind(bind, endonstring) 
{
    self notify("stop" + endonstring);
    self endon("stop" + endonstring);
    self endon("disconnect");
   
    for(;;) 
    {
        self waittill(bind);
        if (!self in_menu())
        {
            self canswap();
            waitframe();
            self illusion();
        }
        wait 0.1;
    }
}

toggle_lunge_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    // self iprintln(new);
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;
    
	if (self.pers[index])
    {
		self iprintln("lunge bind ^2on");
		self thread lungebind(bind, pers);
        // self.pers["test_bind_" + new] = false;
	}
	else
	{
		self iprintln("lunge bind ^1off");
		self notify("stop" + pers);
	}
}

lungebind(bind, endonstring) 
{
    self notify("stop" + endonstring);
    self endon("stop" + endonstring);
    self endon("disconnect");
   
    for(;;) 
    {
        self waittill(bind);
        if (!self in_menu())
        {
            instashoot();
            setweaponanim(11);
        }
        wait 0.1;
    }
}

pickup_bomb()
{
    self thread maps\mp\gametypes\sr::onPickup(self);
    // self setclientomnvar( "ui_carrying_bomb", true );
    // setomnvar( "ui_bomb_carrier", self GetEntityNumber() );
}

pause_timer()
{
    if (getdvarint("timer_paused") == 0)
    {
        setdvar("timer_paused", 1);
        level thread pausetimer(); // _gamelogic
        level notify("stop_auto_bomb"); // stop auto plant
        iprintlnbold("^:" + self get_name() + " ^7paused the timer");
    } 
    else 
    {
        setdvar("timer_paused", 0);
        level thread resumetimer(); // _gamelogic
        level thread auto_bomb(); // resume auto plant
        iprintlnbold("^:" + self get_name() + " ^7resumed the timer");
    }
}

toggle_perk(perk) // toggle & store perks
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
        self setpers("camo","none");
        self remove_camo();
        self remove_camo_next();
    }
    else
    {
        self set_camo(value);
        self set_camo_next(value);
        self setpers("camo",value);
    }
}

drop_canswap()
{
    weapons = randomize("iw6_mk14_mp_mk14scope,iw6_svu_mp_svuscope,iw6_sc2010_mp,iw6_bren_mp,iw6_usr_mp_usrscope,iw6_l115a3_mp_l115a3scope,iw6_microtar_mp,iw6_vks_mp_vksscope,iw6_dlcweap03_mp_dlcweap03scope,iw6_k7_mp,iw6_maul_mp,iw6_lsat_mp,iw6_ak12_mp,iw6_arx160_mp,iw6_dlcweap01_mp,iw6_pp19_mp,iw6_vepr_mp,iw6_microtar_mp,iw6_dlcweap03_mp,iw6_mts255_mp,iw6_sc2010_mp,iw6_gm6helisnipe_mp,iw6_l115a3_mp,iw6_m27_mp,iw6_kriss_mp,iw6_cbjms_mp");
    self giveweapon(weapons);
    self switchtoweapon(weapons);
    self setdropcamo(weapons, self getpers("camo"));
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

toggle_elevators()
{
    self.pers["elevators"] = !toggle(self.pers["elevators"]);

    if (self getpers("elevators"))
    {
        self thread elevators();
    }
    else
    {
        self notify("stop_elevators");
    }
}

toggle_stall_bind()
{
    self.pers["stall"] = !toggle(self.pers["stall"]);

    if (self getpers("stall"))
    {
        self thread care_package_stall();
    }
    else
    {
        self notify("stop_stall");
    }
}

care_package_stall()
{
    self endon("disconnect");
    self endon("stop_stall");

    for(;;)
    {
        self waittill("+actionslot 1");

        if (!self in_menu())
        {
            model = spawn("script_model", self.origin);
            model setmodel("tag_origin");
            self playerlinkto(model);
            self thread game_bar();
            wait 0.1;
            self waittill("+actionslot 1");
            self notify("stopgamebar");
            self setclientomnvar( "ui_securing",0);
            self setclientomnvar( "ui_securing_progress",0 );
            self unlink();
            model delete();
        }
        wait 0.01;
    }
}

game_bar()
{
    self endon("stopgamebar");
   	self setclientomnvar( "ui_securing",1);

    progress = 0;

    for(i=0;i<100;i++)
    {
        self setclientomnvar( "ui_securing_progress",progress );
        progress += 0.01;
        waitframe();
    }

    self setclientomnvar( "ui_securing",0);
    self setclientomnvar( "ui_securing_progress",0 );
}

toggle_alt_swaps()
{
    self.pers["alt_swap"] = !toggle(self.pers["alt_swap"]);

    if (self getpers("alt_swap"))
    {
        self giveweapon("iw6_m9a1_mp");
        self switchtoweapon("iw6_m9a1_mp");
        // self thread alt_swap_loop();
    }
    else
    {
        self notify("stop_alt_swap");
        next = self getnextweapon();
        self takeweapon("iw6_m9a1_mp");
        self switchtoweapon(next);
    }
}

toggle_saved_pos()
{
    self.pers["is_saved"] = !toggle(self.pers["is_saved"]);

    if (self getpers("is_saved"))
    {
        self setpers("saved_position", self.origin);
    }
    else
    {
        self setpers("saved_position", false);
    }
}

toggle_instant_eq()
{
    self.pers["instant_eq"] = !toggle(self.pers["instant_eq"]);

    if (self getpers("instant_eq"))
    {
        self thread insta_eq_loop();
    }
    else
    {
        self notify("stop_insta_eq");
    }
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

elevators()
{
    self endon("disconnect");
    self endon("stop_elevators");
    level endon("game_ended");

    for(;;)
    {
        if (self adsButtonPressed() && self isButtonPressed("+stance") && self isOnGround() && !self isOnLadder() && !self isMantling())
        {
            self thread elevator_logic();
            wait 0.25;
        }
        else if (self JumpButtonPressed())
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
    self playerLinkTo(self.elevator, undefined);

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
    if (isdefined(self.elevator))
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
    {
        self thread auto_reload();
    }
    else
    {
        self notify("stop_auto_reload");
    }
}

auto_reload()
{
    self endon("stop_auto_reload");
    self endon("disconnect");
    level waittill("game_ended");

    weapon = self getcurrentweapon();
    self setWeaponAmmoClip(weapon, 0);
}

toggle_auto_prone()
{
    self.pers["auto_prone"] = !toggle(self.pers["auto_prone"]);

    if (self getpers("auto_prone"))
    {
        self thread auto_prone();
    }
    else
    {
        self notify("stop_auto_prone");
    }
}

toggle_game_end_prone()
{
    self.pers["game_end_prone"] = !toggle(self.pers["game_end_prone"]);

    if (self getpers("game_end_prone"))
    {
        self thread prone_make_sure();
    }
    else
    {
        self notify("stop_game_end_prone");
    }
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

        if (self isOnGround() || self isOnLadder() || self isMantling() || isdefined(self.elevating))
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
        self setStance("prone");
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
            ent FreezeControls(false);
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
        if (ent != self && isdefined(ent.team) && self.team != ent.team && isalive(ent))
            ent FreezeControls(true);
        wait 0.05;
    }
}

change_health()
{
    self.maxhealth = 300;
    self.health = self.maxhealth;
}

give_vish()
{
    self setspawnweapon("none");
}

give_cowboy()
{
    current = self getcurrentweapon();
    x = "iw6_dlcweap02_mp_dlcweap02scope";
    scale = 1;
    self giveweapon(x);
    self setspawnweapon(x);
    setdvar("camera_thirdperson",1);
    setdvar("player_sustainammo",1);
    setslowmotion(10, 10, 0);
    wait 20;
    setdvar("player_sustainammo",0);
    setslowmotion(scale, scale, 0);
    self takeweapon(x);
    self iprintlnbold("press [{+actionslot 1}] to cowboy");
    self waittill("+actionslot 1");
    self switchtoweapon(current);
    self setspawnweapon(current);
    waitframe();
    setdvar("camera_thirdperson",0);
}


toggle_eq_swap()
{
    self.pers["eq_swap"] = !toggle(self.pers["eq_swap"]);

    if (self getpers("eq_swap"))
    {
        self thread eq_swap_loop();
    }
    else
    {
        self notify("stop_eq_swap");
    }
}


eq_swap_loop()
{
    self endon("stop_eq_swap");
    self endon("disconnect");
    level endon("game_ended");

    for(;;)
    {
        self waittill("grenade_pullback");
        self nacto(self getprevweapon());
    }
}

nacto(weapon)
{
    current = self getcurrentweapon();

    self takeweapongood(current);
    self giveweapon(weapon);
    self switchtoweapon(weapon);
    waitframe();
    self giveweapongood(current);
}

toggle_stz_tilt()
{
    self.pers["stz_tilt"] = !toggle(self.pers["stz_tilt"]);

    if (self getpers("stz_tilt"))
    {
        self thread stz_tilt_bind();
    }
    else
    {
        self setplayerangles((self.angles[0],self.angles[1],0));
        self notify("stop_stz_tilt");
    }
}

stz_tilt_bind()
{
    self endon("disconnect");
    self endon("stop_stz_tilt");
    level endon("game_ended");

    for(;;)
    {
        self waittill("+actionslot 1");

        if (self in_menu())
            continue;

        if (!is_true(self.tilting))
        {
            self setplayerangles((self.angles[0],self.angles[1],180));
            self.tilting = 1;
        } 
        else
        {
            self setplayerangles((self.angles[0],self.angles[1],0));   
            self.tilting = 0;
        }
    }
}

toggle_always_canswap()
{
    self.pers["always_canswap"] = !toggle(self.pers["always_canswap"]);

    if (self getpers("always_canswap"))
    {
        self thread alwayscanswaploop();
    }
    else
    {
        self notify("stop_always_canswap");
    }
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
    {
        self thread smoothcanswapsloop();
    }
    else
    {
        self notify("stop_smooth_canswaps");
    }
}

smooth_can_time(value)
{
    self setpers("smooth_can_time", float(value));
}

smoothcanswapsloop()
{
    self endon("stop_smooth_canswaps");
    while(true)
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
    {
        self thread instashootloop();
    }
    else
    {
        self notify("stop_reg_instashoots");
    }
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
        {
            instashoot();
        }
    }
}

toggle_instashoots()
{
    self.pers["instashoots"] = !toggle(self.pers["instashoots"]);

    if (self getpers("instashoots"))
    {
        self thread inphectinstashootloop();
    }
    else
    {
        self notify("stop_instashoots");
    }
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
            {
                instashoot();
            }
            wait 0.1;
        }
        wait 0.05;
    }
}

unstuck()
{
    self setorigin(self getpers("unstuck"));
}

fill_streaks()
{
    foreach(streak in self.killstreaks)
    {
        self maps\mp\killstreaks\_killstreaks::givekillstreak(streak, true);
    }  
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
    self thread maps\mp\killstreaks\_killstreaks::giveKillstreak(streak, false, false, self);
}

refill_ammo()
{
    x = self GetWeaponsListPrimaries();
    foreach(gun in x)
    {
        self SetWeaponAmmoClip(gun, 999);
        self SetWeaponAmmoStock(gun, 999);
    }

    self givemaxammo(self getcurrentoffhand());

    if (self getcurrentoffhand() == "none")
        self givePerkOffhand( "throwingknife_mp", false );
}

load_bots()
{
    foreach(p in level.players)
    {
        if ((isalive(p)) && isbot(p))
        {
            if (is_true(self.pers["freeze_bots"]))
                p setorigin(self.pers["bot_position"]);
        }
    }
}

load_self()
{
    if (isalive(self))
    {
        if (is_true(self.pers["is_saved"]))
            self setorigin(self getpers("saved_position"));
    }
}

kem_strike()
{
    if (getteamscore("allies") == 3 || getteamscore("axis") == 3)
    {
        self maps\mp\killstreaks\_killstreaks::givekillstreak("nuke",false);
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
    {
        self thread pink_loop();
    }
    else
    {
        self notify("stop_pink");
    }
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
                if (is_valid_weapon(self getcurrentweapon()) && distance(ent.origin, center) < randomintrange(100,300))
                {
                    ent dodamage( ent.health + 100, ent.origin, self, self );
                }
            }
        }
    }
}

change_gravity(value)
{
    setdvar("g_gravity", value);
}

change_speed(value)
{
    setdvar("g_speed", value);
}

manage_heli(value)
{
    if (value == "spawn")
        self thread spawnheli();
    
    if (value == "delete")
        self thread deleteheli();
}

spawnheli()
{
    if (level.players.size > 1)
    {
        if (self.canspawnheli)
        {
            foreach(player in level.players)
            {
                if (player != self && player.teamname != self.teamname)
                {
                    self.helicoperspawn = SpawnHelicopter( player, self.origin + (0,0,1200), self.angles, "littlebird_mp", level.littlebird_model );
                    self.canspawnheli = false;
                }
            }
        }
        else
        self iprintlnbold("delete the heli first");
    }
    else
    self iprintlnbold("spawn a bot");
}

deleteheli()
{
    if (isdefined(self.helicoperspawn))
    {
        self.helicoperspawn delete();
        self.canspawnheli = true;
        self iprintln("^:helicopter deleted");
    }
}

/*
toggledaakimbo()
{
    toggleakimbo();
}
*/

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
    self iprintln("^:spawned a bounce at " + self getorigin());
    
    if(x == 1)
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
    
    while(!isdefined(undefined))
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

player_to_sniper(player)
{
    player maps\mp\killstreaks\_helisniper::tryUseHeliSniper(player.pers["deaths"] , "heli_sniper");
}

change_player_team(player)
{
    if (player.team == "allies")
    {
        player.team = "axis";
        player.sessionstate = "spectator";
        waitframe();
        player notify( "luinotifyserver", "team_select", 0 );
        waitframe();
        player notify( "luinotifyserver", "class_select", player.class );
        waitframe();
        player.sessionstate = "playing";
    }
    else
    {
        player.team = "allies";
        player.sessionstate = "spectator";
        waitframe();
        player notify( "luinotifyserver", "team_select", 1 );
        waitframe();
        player notify( "luinotifyserver", "class_select", player.class );
        waitframe();
        player.sessionstate = "playing";
    }
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

print_positions()
{
    print(getdvar("mapname") + " ");
    print(self get_printed_position());
}

illusion()
{
    instashoot();
}