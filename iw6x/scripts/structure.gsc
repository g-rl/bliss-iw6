#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include scripts\utils;
#include scripts\functions;
#include scripts\menu;

// menu structure
render_menu_options()
{
    menu = self get_menu();

    if (!isdefined(menu))
        menu = "unassigned";

    // change options msg
    increment_controls = "[{+actionslot 3}] / [{+actionslot 4}] to use slider, no jump needed to select";
    slider_controls = "[{+actionslot 3}] / [{+actionslot 4}] to use slider, [{+gostand}] to select";
    current_camo = "current camo: " + self getpers("camo");
    first_weapon = self weapname(self getcurrentweapon());
    next_weapon = self weapname(self getnextweapon());

    switch(menu)
    {
    case "bliss":
        map = getdvar("mapname");
        self add_menu("bliss - " + random_message());
        self add_option("toggles", undefined, ::new_menu, "toggles");
        self add_option("lobby", "bots & extra stuff", ::new_menu, "lobby");
        self add_option("weapons", undefined, ::new_menu, "weapons");
        if (is_true(self.bliss["teleports"][map][3]))
            self add_option("teleports", undefined, ::new_menu, "teleports");
        
        self add_option("clients", "manage all players", ::new_menu, "all clients");
        break;
    case "teleports":
        map = getdvar("mapname");
        self add_menu("teleports");
        for(i = 0; i < self.bliss["teleports"][map][0].size; i++) 
        {
            self add_option(self.bliss["teleports"][map][0][i], undefined, ::set_position, self.bliss["teleports"][map][1][i], self.bliss["teleports"][map][2][i]);
        }
        break;
    case "camos":
        self add_menu("camos");
        foreach(camo in level.camoarray)
            self add_option("camo " + camo, current_camo, ::change_camo, camo);
        break;
    case "weapons":
        self add_menu("weapons - " + first_weapon + " & " + next_weapon);
        self add_option("camos", "change camo for both guns", ::new_menu, "camos");
        self add_array("weapon settings", slider_controls, ::weapon_settings, list("refill ammo,drop canswap,drop weapon,take weapon"));
        self add_array("perks", slider_controls, ::toggle_perk, list("specialty_fastsprintrecovery,specialty_fastreload,specialty_lightweight,specialty_marathon,specialty_pitcher,specialty_sprintreload,specialty_quickswap,specialty_bulletaccuracy,specialty_quickdraw,specialty_silentkill,specialty_blindeye,specialty_quieter,specialty_incog,specialty_gpsjammer,specialty_paint,specialty_scavenger,specialty_detectexplosive,specialty_selectivehearing,specialty_comexp,specialty_falldamage,specialty_regenfaster,specialty_sharp_focus,specialty_stun_resistance,specialty_explosivedamage"));
        self add_array("streaks", slider_controls, ::give_certain_streak, list("fill all,care package,ammo crate,vests,kem strike,oracle,odin"));
        break;
    case "lobby":
        self add_menu("lobby - " + getdvar("mapname"));
        self add_toggle("freeze & teleport bots", "also saves bot position", ::toggle_freeze_bots, self.pers["freeze_bots"]);
        self add_option("spawn bot", undefined, ::spawnbot);
        self add_toggle("pause timer", undefined, ::pause_timer, getdvarint("timer_paused"), undefined, "dvar");
        self add_option("pickup bomb", undefined, ::pickup_bomb);
        self add_array("helicopters", slider_controls, ::manage_heli, list("spawn,delete"));
        self add_array("bounces", slider_controls, ::manage_bounce, list("spawn,delete"));
        self add_option("give vish", undefined, ::give_vish);
        self add_option("give cowboy", undefined, ::give_cowboy);
        self add_option("unstuck", "go back to your first spawn", ::unstuck);
        if(is_true(level.is_debug))
            self add_option("print position", undefined, ::print_positions);
        self add_increment("gravity", undefined, ::change_gravity, getdvarint("g_gravity"), 400, 800, 25);
        self add_increment("move speed", undefined, ::change_speed, getdvarint("g_speed"), 190, 800, 10);
        self add_increment("killcam time", undefined, ::change_killcam_time, getdvarfloat("scr_killcam_time"), 1, 10, 0.5);
        self add_increment("timescale", undefined, ::change_timescale, getdvarfloat("timescale"), 0.25, 10, 0.25);
        break;
    case "toggles":
        self add_menu("toggles");
        self add_toggle("set spawnpoint", "save where you spawn next round", ::toggle_saved_pos, self.pers["is_saved"]);
        // self add_toggle("automatic secondary camo", undefined, ::toggle_automatic_camo, self.pers["secondary_camo"]);
        self add_toggle("instashoots", "only works on snipers", ::toggle_reg_instashoots, self.pers["instashoots_reg"]);
        self add_toggle("instashoots [inphect]", "for all weapons", ::toggle_instashoots, self.pers["instashoots"]);
        self add_toggle("smooth canswap", undefined, ::toggle_smooth_canswaps, self.pers["smooth_canswaps"]);
        self add_increment("smooth canswap time", undefined, ::smooth_can_time, self getpers("smooth_can_time"), 0.1, 1, 0.1);
        self add_toggle("always canswap", undefined, ::toggle_always_canswap, self.pers["always_canswap"]);
        self add_toggle("alt swaps", "only gives a third weapon", ::toggle_alt_swaps, self.pers["alt_swap"]);
        self add_toggle("equipment swaps", undefined, ::toggle_eq_swap, self.pers["eq_swap"]);
        self add_toggle("instant equipment", "throw & place equipment automatically", ::toggle_instant_eq, self.pers["instant_eq"]);
        self add_toggle("auto prone", "always auto prone", ::toggle_auto_prone, self.pers["auto_prone"]);
        self add_toggle("auto prone (game end)", "only prones at end of round", ::toggle_game_end_prone, self.pers["game_end_prone"]);
        self add_toggle("auto reload", "reloads at end of round", ::toggle_auto_reload, self.pers["auto_reload"]);
        self add_toggle("fake elevators", "crouch + [{+speed_throw}] to use", ::toggle_elevators, self.pers["elevators"]);
        self add_toggle("better weapon spread", undefined, ::toggle_pink, self.pers["pink"]);
        self add_toggle("care package stalls ([{+actionslot 1}])", undefined, ::toggle_stall_bind, self.pers["stall"]);
        self add_toggle("tilt screen ([{+actionslot 1}])", undefined, ::toggle_stz_tilt, self.pers["stz_tilt"]);
        break;
    case "all clients":
        self add_menu(menu);
        players = level.players;
        foreach (player in players)
        {
            option_text = player get_name();
            self add_option(option_text, undefined, ::new_menu, "player option");
        }
        break;
    default:
        self player_index(menu, self.select_player);
        break;
    }
}

player_index(menu, player)
{
    if (!isdefined(player) || !isplayer(player))
        menu = "unassigned";

    switch(menu)
    {
    case "player option":
        self add_menu(player get_name());
        self add_option("teleport to crosshair", undefined, ::player_to_cross, player);
        self add_option("teleport to me", undefined, ::player_to_me, player);
        self add_option("teleport to them", undefined, ::me_to_player, player);
        self add_option("change team", undefined, ::change_player_team, player);
        self add_option("set to heli sniper", undefined, ::player_to_sniper, player);
        self add_option("kick", undefined, ::kick_player, player);
        break;
    case "unassigned":
        self add_menu(menu);
        self add_option("this menu is unassigned");
        break;
    default:
        self add_menu("error");
        self add_option("unable to load " + menu);
        break;
    }
}