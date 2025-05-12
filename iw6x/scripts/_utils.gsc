#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include scripts\_menu;
#include scripts\_functions;

void() {}

setup_teleports() // map, origin, angles
{
    // prison break
    self.bliss["teleports"]["mp_prisonbreak"][0] = ["main spot", "cool spot"];
    self.bliss["teleports"]["mp_prisonbreak"][1] = [(-1746.18, 541.934, 1291.4), (1219.91, 2726, 1716.29)];
    self.bliss["teleports"]["mp_prisonbreak"][2] = [(4.548, -76.0089, 0), (12.196, -136.675, 0)];
    self.bliss["teleports"]["mp_prisonbreak"][3] = "prison break";

    // freight 
    self.bliss["teleports"]["mp_frag"][0] = ["main ele spot", "ladder spot"];
    self.bliss["teleports"]["mp_frag"][1] = [(-125.857, 1424.61, 521.782), (1027.63, 1862.34, 407.484)];
    self.bliss["teleports"]["mp_frag"][2] = [(4.65798, -29.2957, 0), (3.54736, 122.79, 0)];
    self.bliss["teleports"]["mp_frag"][3] = "freight";

    // stormfront
    self.bliss["teleports"]["mp_fahrenheit"][0] = ["middle of map", "ledge spot", "window", "cool spot", "cool spot 2"];
    self.bliss["teleports"]["mp_fahrenheit"][1] = [(1367.68, -1172.25, 858.979), (1068.29, -1852.73, 898.659), (246.793, -2347.9, 916.256), (-1975.21, -2755.56, 827.43), (427.899, 199.001, 986.933)];
    self.bliss["teleports"]["mp_fahrenheit"][2] = [(2.93884, -172.057, 0), (1.42822, -158.434, 0), (2.93859, -72.4658, 0), (6.25, 36.0297, 0), (3.19824, -3.83984, 0)];
    self.bliss["teleports"]["mp_fahrenheit"][3] = "stormfront";

    // sovereign
    self.bliss["teleports"]["mp_sovereign"][0] = ["ledge spot"];
    self.bliss["teleports"]["mp_sovereign"][1] = [(550.173, 1769.26, 405.901)];
    self.bliss["teleports"]["mp_sovereign"][2] = [(4.53735, 146.508, 0)];
    self.bliss["teleports"]["mp_sovereign"][3] = "sovereign";

    // bayview
    self.bliss["teleports"]["mp_ca_rumble"][0] = ["main spot", "a cool oom", "another oom"];
    self.bliss["teleports"]["mp_ca_rumble"][1] = [(-440.559, -1221.58, 247.484), (1062.15, 1423.32, 403.902), (-983.862, 495.13, 533.309)];
    self.bliss["teleports"]["mp_ca_rumble"][2] = [(10.5043, 52.0311, 0), (1.06995, -16.6333, 0), (-0.0946045, -138.186, 0)];
    self.bliss["teleports"]["mp_ca_rumble"][3] = "bayview";
    
    // flooded
    self.bliss["teleports"]["mp_flooded"][0] = ["cool barrier"];
    self.bliss["teleports"]["mp_flooded"][1] = [(575.732, -1031.67, 1055.48)];
    self.bliss["teleports"]["mp_flooded"][2] = [(4.21991, 104.564, 0)];
    self.bliss["teleports"]["mp_flooded"][3] = "flooded";

    // warhawk
    self.bliss["teleports"]["mp_warhawk"][0] = ["ledge spot"];
    self.bliss["teleports"]["mp_warhawk"][1] = [(-210.092, -392.486, 280.392)];
    self.bliss["teleports"]["mp_warhawk"][2] = [(3.73962, -79.0741, 0)];
    self.bliss["teleports"]["mp_warhawk"][3] = "warhawk";

    // if map has options, add teleports menu 
    if (is_true(self.bliss["teleports"][getdvar("mapname")][1]))
        self.bliss["teleports"][getdvar("mapname")][4] = true;
    else
        self.bliss["teleports"][getdvar("mapname")][4] = false;
}

class_change()
{  
    self endon("disconnect");
    level endon("game_ended");

    game["strings"]["change_class"] = ""; // no change class message

    for(;;)
    {
        self waittill("luinotifyserver", var_00, var_01);

        if (var_00 != "class_select")
            continue;

        var_01 = var_01 + 1;
        self.class = "custom" + var_01;
        maps\mp\gametypes\_class::setclass(self.class);
        self.tag_stowed_back = undefined;
        self.tag_stowed_hip = undefined;

        maps\mp\gametypes\_class::giveloadout(self.teamname, self.class);
        
        // attempt to give throwing knife if no offhand
        if (self getcurrentoffhand() == "none")
            self giveperkoffhand("throwingknife_mp", false);

        // watch alt swap
        if (is_true(self getpers("alt_swap")))
            self giveweapon("iw6_m9a1_mp");
        
        // reapply everything
        self refill_ammo();
        self set_perks();
        self handle_camo();
    }
}

damage_hook(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, boneIndex)
{
    if (sMeansofDeath != "MOD_FALLING" && sMeansofDeath != "MOD_TRIGGER_HURT" && sMeansofDeath != "MOD_SUICIDE") 
    {
        if (is_valid_weapon(sWeapon)) 
            iDamage = 999;

        if (sMeansofDeath == "MOD_FALLING")
            iDamage = 0;

        if (getdvar("g_gametype") == "sr" && is_valid_weapon(sWeapon)) // online point popup
        {
            // print("its working lol");
            eattacker thread maps\mp\gametypes\sr::onpickup(eattacker);
            eattacker thread maps\mp\gametypes\_rank::xpPointsPopup(250);
        }
        [[level.original_damage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, boneIndex);
    }
}

handle_snr()
{
    // always attacking
    game["switchedsides"] = false;
    game["attackers"] = "allies";

    while (!isdefined(level.sdbomb))
    {
        wait 0.05;
    }

    while (!isdefined(level.bombzones) || level.bombzones.size < 1)
    {
        wait 0.05;
    }

    level.sdbombmodel hide();
    level.sdbomb hide();

    bombzone_origin = level.bombzones[0].origin - (0, 0, 7.875);
    level.sdbomb.origin = bombzone_origin;
    level.sdbomb.curOrigin = bombzone_origin;

    bomb_model_origin = level.bombzones[0].origin - (0, 0, 17.875);
    level.sdbombmodel.origin = bomb_model_origin;
    level.sdbombmodel.curOrigin = bomb_model_origin;

    level thread auto_plant();
}

check_snr()
{
    if (level.gametype != "sr") // only load match if gametype is search & rescue
    {
        iprintlnbold("must be loaded on ^:search & rescue");
        wait (randomintrange(2, 3));
        iprintlnbold("must be loaded on ^:search & rescue");
        self maps\mp\_flashgrenades::applyflash(10,1);
        self playlocalsound("copycat_steal_class");
        wait 1;
        exitlevel();
        return;
    }
}

is_valid_weapon(weapon)
{
    if (!isdefined(weapon))
        return false;

    if (getweaponclass(weapon) == "weapon_sniper" || getweaponclass(weapon) == "weapon_dmr") // allow sniper & marksman rifle
        return true;
        
    switch(weapon)
    {
       	case "throwingknife_mp":
            return true;
        default:
            return false;        
    }
}

perstovector(pers)
{
    keys = strtok(pers, ",");
    return (float(keys[0]), float(keys[1]), float(keys[2]));
}

list(key) 
{
    output = strtok(key, ",");
    return output;
}

randomize(key)
{
    arr = strtok(key, ", ");
    random = randomint(arr.size);
    output = arr[random];
    return output;
}

is_true(variable)
{
    if (isdefined(variable) && variable)
    {
        return true;
    }

    return false;
}

toggle(variable)
{
    return isdefined(variable) && variable;
}

get_players()
{
    return level.players;
}

button_monitor(button) 
{
    self endon("disconnect");

    self.button_pressed[button] = false;
    self NotifyOnPlayerCommand("button_pressed_" + button, button);

    for(;;)
    {
        self waittill("button_pressed_" + button);
        self.button_pressed[button] = true;
        wait .01;
        self.button_pressed[button] = false;
    }
}

isbuttonpressed(button)
{
    return self.button_pressed[button];
}

monitor_buttons() 
{
    if (isdefined(self.now_monitoring))
        return;

    self.now_monitoring = true;
    
    if (!isdefined(self.button_actions))
        self.button_actions = ["+sprint", "+melee", "+melee_zoom", "+melee_breath", "+stance", "+gostand", "weapnext", "+actionslot 1", "+actionslot 2", "+actionslot 3", "+actionslot 4", "+forward", "+back", "+moveleft", "+moveright"];
    if (!isdefined(self.button_pressed))
        self.button_pressed = [];
    
    for(a=0 ; a < self.button_actions.size ; a++)
        self thread button_monitor(self.button_actions[a]);
}

create_notify()
{
    foreach(value in strtok("+sprint,+actionslot 1,+actionslot 2,+actionslot 3,+actionslot 4,+frag,+smoke,+melee,+melee_zoom,+stance,+gostand,+switchseat,+usereload", ",")) 
    {
        self NotifyOnPlayerCommand(value, value);
    }
}

bullet_trace() 
{
    point = bullettrace(self geteye(), self geteye() + anglestoforward(self getplayerangles()) * 1000000, 0, self)["position"];
    return point;
}

get_name()
{
    name = self.name;
    if (name[0] != "[")
        return name;

    for(i = (name.size - 1); i >= 0; i--)
        if (name[i] == "]")
            break;

    return getsubstr(name, (i + 1));
}

israising()
{
    if (israisingpan() == 1)
        return true;

    return false;
}

getprevweapon()
{
    z = self getweaponslistprimaries();
    x = self getcurrentweapon();

    for(i = 0 ; i < z.size ; i++)
    {
        if (x == z[i])
        {
            y = i - 1;
            if (y < 0)
            y = z.size - 1;

            if (isdefined(z[y]))
            return z[y];
            else
            return z[0];
        }
    }
}

getnextweapon()
{
    z = self getweaponslistprimaries();
    x = self getcurrentweapon();
    for(i = 0 ; i < z.size ; i++)
    {
        if (x == z[i])
        {
            if (isdefined(z[i + 1]))
            return z[i + 1];
            else
            return z[0];
        }
    }
}

getcurrentweaponname()
{
    return self weapname(self getcurrentweapon());
}

getnextweaponname()
{
    return self weapname(self getnextweapon());
}

takeweapongood(gun)
{
    self.getgun[gun] = gun;
    self.getclip[gun] =  self getweaponammoclip(gun);
    self.getstock[gun] = self getweaponammostock(gun);
    self takeweapon(gun);
}

giveweapongood(gun)
{
    self giveweapon(self.getgun[gun]);
    self setweaponammoclip(self.getgun[gun], self.getclip[gun]);
    self setweaponammostock(self.getgun[gun], self.getstock[gun]);
}

removecamo()
{
    x = self getcurrentweapon();
    self takeweapon(x);
    if (issubstr(x,"camo"))
    {
        keys = strtok(x, "_");
        base = keys[0];
        for(i=1;i<keys.size;i++)
        {
            if (!issubstr(keys[i],"camo"))
            base = base + "_" + keys[i];
        }
        x = base;
    }
    self giveweapon(x);
    self setspawnweapon(x);
}

removecamonext()
{
    x = self getcurrentweapon();
    self takeweapon(x);
    if (issubstr(x,"camo"))
    {
        keys = strtok(x, "_");
        base = keys[0];
        for(i=1;i<keys.size;i++)
        {
            if (!issubstr(keys[i],"camo"))
            base = base + "_" + keys[i];
        }
        x = base;
    }
    self giveweapon(x);
}

setcamo(camo)
{   
    x = self getcurrentweapon();

    if (x == "none" || getweaponclass(x) == "weapon_pistol" || getweaponclass(x) == "weapon_machine_pistol" || getweaponclass(x) == "weapon_projectile")
        return;

    self takeweapon(x);
    if (issubstr(x, "camo"))
    {
        keys = strtok(x, "_");
        base = keys[0];
        for(i=1; i < keys.size; i++)
        {
            if (!issubstr(keys[i],"camo"))
            base = base + "_" + keys[i];
        }
        x = base;
    }
    self giveweapon(x + "_camo" + camo);
    self setspawnweapon(x + "_camo" + camo);
}

setcamobot(camo)
{   
    x = self getcurrentweapon();

    if (x == "none" || getweaponclass(x) == "weapon_pistol" || getweaponclass(x) == "weapon_machine_pistol" || getweaponclass(x) == "weapon_projectile")
        return;

    self takeweapon(x);
    if (issubstr(x, "camo"))
    {
        keys = strtok(x, "_");
        base = keys[0];
        for(i=1; i < keys.size; i++)
        {
            if (!issubstr(keys[i],"camo"))
            base = base + "_" + keys[i];
        }
        x = base;
    }
    self giveweapon(x + "_camo" + camo);
    self switchtoweapon(x + "_camo" + camo);
    self setspawnweapon(x + "_camo" + camo);
}

setdropcamo(weapons, camo)
{
    x = weapons;

    if (x == "none" || getweaponclass(x) == "weapon_pistol" || getweaponclass(x) == "weapon_machine_pistol" || getweaponclass(x) == "weapon_projectile")
        return;

    self takeweapon(x);
    if (issubstr(x, "camo"))
    {
        keys = strtok(x, "_");
        base = keys[0];
        for(i=1; i < keys.size; i++)
        {
            if (!issubstr(keys[i],"camo"))
            base = base + "_" + keys[i];
        }
        x = base;
    }
    
    self giveweapon(x + "_camo" + camo);
    self dropitem(x + "_camo" + camo);
}

setcamonext(camo)
{
    x = self getnextweapon();
    
    if (x == "none" || getweaponclass(x) == "weapon_pistol" || getweaponclass(x) == "weapon_machine_pistol" || getweaponclass(x) == "weapon_projectile")
        return;

    self takeweapon(x);
    if (issubstr(x, "camo"))
    {
        keys = strtok(x, "_");
        base = keys[0];
        for(i=1; i < keys.size; i++)
        {
            if (!issubstr(keys[i],"camo"))
            base = base + "_" + keys[i];
        }
        x = base;
    }
    self giveweapon(x + "_camo" + camo);
}

setup_teams()
{
    if (isbot(self) == true)
    {
        self maps\mp\gametypes\_menus::addToTeam("axis");
        self.pers["class"] = undefined;
        self.class = undefined;
        self maps\mp\gametypes\_menus::beginClassChoice();
    }
    else
    {
        self maps\mp\gametypes\_menus::addToTeam("allies");
        self.pers["class"] = undefined;
        self.class = undefined;
        self maps\mp\gametypes\_menus::beginClassChoice();
    }
}

auto_plant() // player is always attacker
{
    level endon("stop_auto_plant");

    // revert time if timer pause so it still auto plants
    if (isdefined(level.saved_time))
        time = level.saved_time;
    else
        time = 0;

    for(;;)
    {
        time++;
        level.saved_time = time;
        if (time == 148)
        {
            players = level.players;
            foreach (player in players)
            {
                if (!isdefined(player) || !isalive(player))
                    continue;

                if (player.pers["team"] == "allies")
                {
                    if (isdefined(level.bombplanted) && !level.bombplanted)
                    {
                        level thread maps\mp\gametypes\sr::bombplanted(level.bombzones[1], player[0]);
                        level thread teamPlayerCardSplash("callout_bombplanted", player[0]);
                        return;
                    }
                }
            }
        }
        wait 1;
    }
}

set_random_rounds()
{
    random_round_axis = randomint(3);
    random_round_ally = randomint(3);
    rounds_played = random_round_axis + random_round_ally;
    level waittill("final_killcam_done"); // set on final_killcam_done so it doesnt reset at first round end
    game["roundsWon"]["axis"] = random_round_axis;
    game["roundsWon"]["allies"] = random_round_ally;
    game["roundsplayed"] = rounds_played;
    game["teamScores"]["allies"] = random_round_ally;
    game["teamScores"]["axis"] = random_round_axis;
}

drop_weapon()
{
    self dropitem(self getcurrentweapon());
}

take_weapon()
{
    self takeweapon(self getcurrentweapon());
}

set_position(origin, angles)
{
    self setorigin(origin);
    self setplayerangles(angles);
}

getcrosshair()
{
    point = bullettrace(self geteye(), self geteye() + anglestoforward(self getplayerangles()) * 1000000, 0, self)["position"];
    return point;
}

set_perks()
{
    foreach(perk in self.pers["my_perks"])
    {
        if (self.pers["my_perks"].size == 0)
            return;

        self _setperk(perk, false);
    }
}

weapname(weap)
{
    array = strtok(getweaponbasename(weap), "_");
    if (issubstr(array[0], "iw6"))
        return array[1];
    else 
        return array[0];
}

spawnbot()
{
    executecommand("spawnbot");
    wait 5; // give time for bot to spawn in
    players = level.players;
    foreach (player in level.players)
    {
        if(is_true(player getpers("freeze_bots")))
        {
            player thread load_bots(); // in case a save is set b4 bot spawn lol
            return;
        } else {
            return;
        }
    }
}

genie(a, b) 
{
    genie = [];
    genie[0] = a;
    genie[1] = b;
    output = genie[randomint(genie.size)];
    return output;
}

isinarray(array, text)
{
    for(i=0; i < array.size; i++)
        if (array[i] == text)
            return true;
    return false;
}

handle_camo()
{
    self setcamo(self getpers("camo"));
    self setcamonext(self getpers("camo"));
}

kick_player(player)
{
    if (player ishost())
    {
        self iprintln("unable to kick host");
        return;
    }

    kick(player getentitynumber());
}

kick_bots()
{
    foreach(player in level.players)
        if (isbot(player))
            kick(player getentitynumber());
}

me_to_player(player)
{
    self set_position(player.origin, player getplayerangles());
}

player_to_cross(player)
{
    player setorigin(self getcrosshair());
}

player_to_me(player)
{
    player set_position(self.origin, self getplayerangles());
}

player_to_sniper(player)
{
    if (!isbot(player))
    {
        self iprintln("player must be a bot");
        return;
    }

    player maps\mp\killstreaks\_helisniper::tryUseHeliSniper(player.pers["deaths"] , "heli_sniper");
}

change_player_team(player)
{
    if (player ishost())
    {
        self iprintln("unable to change host team");
        return;
    }

    if (player.team == "allies")
    {
        player.team = "axis";
        player.sessionstate = "spectator";
        waitframe();
        player notify("luinotifyserver", "team_select", 0);
        waitframe();
        player notify("luinotifyserver", "class_select", player.class);
        waitframe();
        player.sessionstate = "playing";
    }
    else
    {
        player.team = "allies";
        player.sessionstate = "spectator";
        waitframe();
        player notify("luinotifyserver", "team_select", 1);
        waitframe();
        player notify("luinotifyserver", "class_select", player.class);
        waitframe();
        player.sessionstate = "playing";
    }
}

get_printed_position()
{
    return (self.origin + ", " + self getPlayerAngles() + "\n");
}

get_position(player)
{
    return (player.origin + ", " + player getPlayerAngles());
}

bypass_intro()
{
    self.introscreen_overlay destroy();
}

canswap()
{
    x = self getcurrentweapon();
    self takeweapongood(x);
    self giveweapongood(x);
    self switchtoweapon(x);
}

g_weapon(weapon) // give weapon with camo
{
    self giveweapon(weapon);
    self switchtoweapon(weapon);
    self setcamo(self getpers("camo"));
}

print_positions()
{
    print(getdvar("mapname") + " ");
    print(self get_printed_position());
}

pickup_bomb()
{
    wait 1;
    self thread [[level.sdBomb.onPickup]](self); 
    level.sdBomb maps\mp\gametypes\_gameobjects::setVisibleTeam("none");
}

drop_bomb()
{
    self thread [[level.sdBomb.onDrop]](self);
    level.sdBomb maps\mp\gametypes\_gameobjects::setVisibleTeam("friendly");
}

reload_bomb()
{
    if (getdvarint("timer_paused") == 1)
    {
        level thread maps\mp\gametypes\_gamelogic::pausetimer();
        level notify("stop_auto_plant"); // stop auto plant
    }
}

fileread(file)
{
    filesetdvar(file);
    return getdvar("panelafile");
}

save_file_watch()
{
    for(;;)
    {
        self waittill_any("opened_menu", "exit_menu", "selected_option");
        
        foreach(pers,value in level.saveddvars)
            filewrite("bliss/" + self.name + "/" + pers, "" + self getpers(pers));

        foreach(dvar,value in level.savedvar)
            filewrite("bliss/" + dvar, getdvar(dvar));
    }
}

setpersifuni(pers, value) // needs fixingggg
{
    value = "" + value;

    if (!isdefined(level.saveddvars))
        level.saveddvars = [];

    if (fileexists("bliss/" + self.name + "/" + pers) == -1)
        filewrite("bliss/" + self.name + "/" + pers, value);

    self.pers[pers] = fileread("bliss/" + self.name + "/" + pers);
    level.saveddvars[pers] = fileread("bliss/" + self.name + "/" + pers);
}

setdvarifuni(dvar, value)
{   
    if (!isdefined(level.savedvar))
        level.savedvar = [];

    if (fileexists("bliss/" + dvar) == -1)
        filewrite("bliss/" + dvar, value);

    setdvar(dvar, fileread("bliss/" + dvar));

    level.savedvar[dvar] = value;
    waitframe();
}

toggle_pers(pers)
{
    if (!isdefined(self.pers[pers])) self.pers[pers] = false;
    self.pers[pers] = !self.pers[pers];
}

setpers(key, value)
{
    self.pers[key] = value;
    print(key + " to" + value + "\n ");
}

getpers(key)
{
    return self.pers[key];
}

setpersifuniold(key, value)
{
    if (!isdefined(self.pers[key]))
        self.pers[key] = value;
}

setup_bind(pers, value, func)
{
    for(i = 0; i < 4; i++) 
    {
        bind = "+actionslot " + (i + 1);
        index = i + 1;
        new_pers = pers + "_" + index;

        self setpersifuniold(new_pers, value);

        if (is_true(self getpers(new_pers)))
        {
            self thread [[func]](bind, pers);
        }
    }
}

setup_pers(pers, func, arg)
{
    if (is_true(self getpers(pers)))
        self thread [[func]](arg);
}

random_message()
{
    name = self get_name();
    weapon_name = self weapname(self getcurrentweapon());
    m = [];
    m[m.size] = name;
    m[m.size] = "by @nyli2b";
    m[m.size] = "made with <3";
    m[m.size] = "iw6x";
    m[m.size] = "playing as " + name;
    m[m.size] = "holding a " + weapon_name;  

    return m[randomint(m.size)];
}

switchto(weapon)
{
    current = self getcurrentweapon();

    self takeweapongood(current);
    self giveweapon(weapon);
    self switchtoweapon(weapon);
    waitframe();
    self giveweapongood(current);
}

unstuck()
{
    self setorigin(self getpers("unstuck"));
}

clean_killcam()
{
    level endon("final_killcam_done"); // make sure it still ends at some point in case 
    for(;;)
    {
        self setclientomnvar("ui_killcam_killedby_killstreak",-1);
        self setclientomnvar("ui_killcam_killedby_weapon",-1);
        self setclientomnvar("ui_killcam_killedby_attachment1",-1);
        self setclientomnvar("ui_killcam_killedby_attachment2",-1);
        self setclientomnvar("ui_killcam_killedby_attachment3",-1);
        self setclientomnvar("ui_killcam_killedby_attachment4",-1);
        self setclientomnvar("ui_killcam_killedby_abilities1", -1);
        wait 0.05;
    }
}

getangles()
{
    return self.angles;
}