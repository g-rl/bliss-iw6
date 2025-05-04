#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\_utils;
#include scripts\_functions;
#include scripts\_menu;
#include scripts\_binds;

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
    credits = "made with <3 by @nyli2b";

    switch(menu)
    {
    case "bliss":
        self.is_bind_menu = false;
        // self add_menu("bliss - " + random_message());
        self add_menu("bliss");
        self add_option("toggles", credits, ::new_menu, "toggles");
        self add_option("lobby", credits, ::new_menu, "lobby");
        self add_option("weapons", credits, ::new_menu, "weapons");
        self add_option("clients", credits, ::new_menu, "all clients");
        self add_option("menu info", credits, ::new_menu, "menu info");
        break;
    case "teleports":
        self.is_bind_menu = false;
        map = getdvar("mapname");
        self add_menu("teleports - " + getdvar("mapname"));
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
    case "binds":
        self add_menu(menu);
        self add_bind_index("sprint loop");
        self add_bind_index("lunge");
        self add_bind_index("smooth");
        self add_bind_index("mala");
        self add_bind_index("illusion");
        self add_bind_index("glide");
        self add_bind_index("care package stall");
        self add_bind_index("tilt screen");
        // self add_bind_index("gunlock");
        break;
    case "weapons":
        self.is_bind_menu = false;
        self add_menu("weapons - " + first_weapon + " & " + next_weapon);
        self add_increment("set camo", increment_controls, ::change_camo, int(self getpers("camo")), 10, 46, 1);
        self add_array("settings", slider_controls, ::weapon_settings, list("refill ammo,drop canswap,drop weapon,take weapon"));
        self add_array("perks", slider_controls, ::toggle_perk, list("specialty_fastsprintrecovery,specialty_fastreload,specialty_lightweight,specialty_marathon,specialty_pitcher,specialty_sprintreload,specialty_quickswap,specialty_bulletaccuracy,specialty_quickdraw,specialty_silentkill,specialty_blindeye,specialty_quieter,specialty_incog,specialty_gpsjammer,specialty_paint,specialty_scavenger,specialty_detectexplosive,specialty_selectivehearing,specialty_comexp,specialty_falldamage,specialty_regenfaster,specialty_sharp_focus,specialty_stun_resistance,specialty_explosivedamage"));
        self add_array("killstreaks", slider_controls, ::give_certain_streak, list("fill all,care package,ammo crate,vests,kem strike,oracle,odin"));
        break;
    case "lobby":
        map = getdvar("mapname");
        self.is_bind_menu = false;
        self add_menu("lobby - " + getdvar("mapname"));
        if (is_true(self.bliss["teleports"][map][3])) // add all teleports from utils
            self add_option("map teleports (" + self.bliss["teleports"][map][0].size + ")", undefined, ::new_menu, "teleports");
        self add_toggle("freeze & teleport bots", undefined, ::toggle_freeze_bots, self.pers["freeze_bots"]);
        self add_option("spawn bot", undefined, ::spawnbot);
        self add_toggle("pause timer", undefined, ::pause_timer, getdvarint("timer_paused"), undefined, "dvar");
        self add_option("pickup bomb", undefined, ::pickup_bomb);
        self add_array("bounces", slider_controls, ::manage_bounce, list("spawn,delete"));
        // self add_array("helicopters", slider_controls, ::manage_heli, list("spawn,delete"));
        self add_option("give vish", undefined, ::give_vish);
        self add_option("give cowboy", undefined, ::give_cowboy);
        self add_option("unstuck", "go back to your first spawn", ::unstuck);
        if (is_true(level.is_debug) && self get_name() == "catchet")
            self add_option("print position", undefined, ::print_positions);
        self add_increment("gravity", increment_controls, ::change_gravity, getdvarint("g_gravity"), 400, 800, 25);
        self add_increment("move speed", increment_controls, ::change_speed, getdvarint("g_speed"), 190, 800, 10);
        self add_increment("killcam time", increment_controls, ::change_killcam_time, getdvarfloat("scr_killcam_time"), 1, 10, 0.5);
        self add_increment("timescale", increment_controls, ::change_timescale, getdvarfloat("timescale"), 0.25, 10, 0.25);
        break;
    case "toggles":
        self.is_bind_menu = false;
        self add_menu("toggles");
        self add_option("binds", "my lazy binds menu lol", ::new_menu, "binds");
        self add_toggle("set spawnpoint", "save where you spawn next round", ::toggle_saved_pos, self.pers["is_saved"]);
        self add_toggle("instashoots", "only works on snipers", ::toggle_reg_instashoots, self.pers["instashoots_reg"]);
        self add_toggle("instashoots [inphect]", "for all weapons", ::toggle_instashoots, self.pers["instashoots"]);
        self add_toggle("instant pumps", undefined, ::toggle_instant_pump, self.pers["insta_pumps"]);
        self add_toggle("smooth canswap", undefined, ::toggle_smooth_canswaps, self.pers["smooth_canswaps"]);
        self add_increment("smooth canswap time", increment_controls, ::smooth_can_time, float(self getpers("smooth_can_time")), 0.1, 1, 0.1);
        self add_toggle("always canswap", undefined, ::toggle_always_canswap, self.pers["always_canswap"]);
        self add_toggle("equipment swaps", undefined, ::toggle_eq_swap, self.pers["eq_swap"]);
        self add_toggle("instant equipment", undefined, ::toggle_instant_eq, self.pers["instant_eq"]);
        self add_toggle("auto prone", undefined, ::toggle_auto_prone, self.pers["auto_prone"]);
        self add_toggle("auto prone (game end)", "only prones at end of round", ::toggle_game_end_prone, self.pers["game_end_prone"]);
        self add_toggle("auto reload", undefined, ::toggle_auto_reload, self.pers["auto_reload"]);
        self add_toggle("elevators", "crouch + [{+speed_throw}] to use", ::toggle_elevators, self.pers["elevators"]);
        self add_toggle("alt swaps", "only gives a third weapon", ::toggle_alt_swaps, self.pers["alt_swap"]);
        self add_toggle("better weapon spread", undefined, ::toggle_pink, self.pers["pink"]);
        break;
    case "all clients":
        self.is_bind_menu = false;
        self add_menu(menu);
        players = level.players;
        foreach (player in players)
        {
            option_text = player get_name();
            self add_option(option_text, undefined, ::new_menu, "player option");
        }
        break;
    case "menu info":
        self.is_bind_menu = false;
        self add_menu(menu);
        opt = list("auto load camos on both guns,options save through rounds,auto round resetting,always auto plant,perks save through classes,dvars & camo save on game quit,teleports on some maps,auto set ranks");
        foreach(option in opt)
        {
            self add_category(option);
        }
        break;
    default:
        if (is_true(self.is_bind_menu))
        {
            self bind_index(menu);
        } else {
            self player_index(menu, self.select_player);
        }
        break;
    }
}

bind_index(menu) 
{
    if (!isdefined(menu))
        menu = "unassigned";

    switch(menu) 
    {
        case "sprint loop":
            self add_bind_menu(menu, ::toggle_sprint_loop, "sprint_loop");
            break;
        case "lunge":
            self add_bind_menu(menu, ::toggle_lunge_bind, "lunge");
            break;
        case "mala":
            self add_bind_menu(menu, ::toggle_mala, "mala");
            break;
        case "illusion":
            self add_bind_menu(menu, ::toggle_illusion, "illusion");
            break;
        case "smooth":
            self add_bind_menu(menu, ::toggle_smooth, "smooth");
            break;
        case "gunlock":
            self add_bind_menu(menu, ::toggle_gunlock, "gunlock");
            break;
        case "glide":
            self add_bind_menu(menu, ::toggle_glide, "glide");
            break;
        case "care package stall":
            self add_bind_menu(menu, ::toggle_stall, "stall");
            break;
        case "tilt screen":
            self add_bind_menu(menu, ::toggle_tilt, "tilt");
            break;
        case "unassigned":
            self add_menu(menu);
            self add_option("this menu is unassigned");
            break;
        default:
            is_error = true;
            if (is_error) 
            {
                self add_menu("error");
                self add_option(("unable to load bind menu " + menu));
            }
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

add_bind_menu(name, func, pers, end_on) // lol im so lazy bro idc
{
    self add_menu(name);

    for(i = 0; i < 4; i++) 
    {
        option = name + " > " + "[{+actionslot " + (i + 1) + "}]";
        bind = "+actionslot " + (i + 1);
        index = i + 1;
        prev_index = index - 1;
        end_on = pers;
        self add_toggle( option, undefined, func, self.pers[pers + "_" + index], undefined, bind, index, end_on, prev_index);
    }
}

add_bind_index( menu)
{
    self.is_bind_menu = true;
    self add_option(menu, undefined, ::new_menu, menu);
}