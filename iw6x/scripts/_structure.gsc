#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\_utils;
#include scripts\_functions;
#include scripts\_menu;
#include scripts\_binds;

structure()
{
    menu = self get_menu();
    if (!isdefined(menu)) menu = "unassigned";

    increment_controls = "[{+actionslot 3}] / [{+actionslot 4}] to use slider, no jump needed to select";
    slider_controls = "[{+actionslot 3}] / [{+actionslot 4}] to use slider, [{+gostand}] to select";
    credits = "made with ^:<3^7 by @nyli2b";
    current_camo = "current camo: " + self getpers("camo");
    menu_info = list("auto load camos on both guns,options save through rounds,auto round resetting,always auto plant,perks save through classes,dvars & camo save on game quit,teleports on some maps,auto set ranks");
    my_weapons = self getcurrentweaponname() + " & " + self getnextweaponname();
    bind_list = list("sprint loop,lunge,smooth,mala,illusion,glide,care package stall,tilt screen");

    switch(menu)
    {
    case "bliss":
        self.is_bind_menu = false;
        self add_menu("bliss");
        self add_option("toggles", credits, ::new_menu, "toggles");
        self add_option("lobby", credits, ::new_menu, "lobby");
        self add_option("weapons", credits, ::new_menu, "weapons");
        self add_option("clients", credits, ::new_menu, "all clients");
        self add_option("menu info", credits, ::new_menu, "menu info");
        break;
    case "toggles":
        self.is_bind_menu = false;
        self add_menu("toggles");
        self add_option("binds", "some might crash ur game", ::new_menu, "binds");
        if (!is_true(self getpers("save_and_load")) && getdvarint("enable_cheats") == 1) self add_toggle("set spawnpoint", "save where you spawn next round", ::toggle_saved_pos, self.pers["is_saved"]);
        self add_toggle("always pickup bomb", undefined, ::always_pickup_bomb, getdvarint("pickup_bomb"));
        if (!is_true(self getpers("instashoots"))) self add_toggle("instashoots", "only works on snipers", ::toggle_reg_instashoots, self.pers["instashoots_reg"]);
        if (!is_true(self getpers("instashoots_reg"))) self add_toggle("instashoots (inphect)", "for all weapons", ::toggle_instashoots, self.pers["instashoots"]);
        self add_toggle("knife lunges", undefined, ::toggle_knife_lunge, self.pers["knife_lunge"]);
        self add_toggle("instant pumps", undefined, ::toggle_instant_pump, self.pers["insta_pumps"]);
        self add_toggle("smooth canswap", undefined, ::toggle_smooth_canswaps, self.pers["smooth_canswaps"]);
        self add_increment("smooth canswap time", increment_controls, ::smooth_can_time, float(self getpers("smooth_can_time")), 0.1, 1, 0.1);
        self add_toggle("always canswap", undefined, ::toggle_always_canswap, self.pers["always_canswap"]);
        self add_toggle("equipment swaps", undefined, ::toggle_eq_swap, self.pers["eq_swap"]);
        self add_toggle("instant equipment", undefined, ::toggle_instant_eq, self.pers["instant_eq"]);
        if (!is_true(self getpers("game_end_prone"))) self add_toggle("auto prone", undefined, ::toggle_auto_prone, self.pers["auto_prone"]);
        if (!is_true(self getpers("auto_prone"))) self add_toggle("auto prone (game end)", "only prones at end of round", ::toggle_game_end_prone, self.pers["game_end_prone"]);
        self add_toggle("auto reload", undefined, ::toggle_auto_reload, self.pers["auto_reload"]);
        self add_toggle("elevators", "crouch + [{+speed_throw}] to use", ::toggle_elevators, self.pers["elevators"]);
        self add_toggle("alt swaps", "only gives a third weapon", ::toggle_alt_swaps, self.pers["alt_swap"]);
        if (getdvarint("enable_cheats") == 1) self add_toggle("better weapon spread", undefined, ::toggle_pink, self.pers["pink"]);
        if (!is_true(self getpers("is_saved")) && getdvarint("enable_cheats") == 1) self add_toggle("save & load", undefined, ::toggle_save_and_load, self.pers["save_and_load"]);
        break;
    case "lobby":
        map = getdvar("mapname");
        self.is_bind_menu = false;
        self add_menu("lobby");
        if (is_true(self.bliss["teleports"][map][4]) && getdvarint("enable_cheats") == 1) // add teleports from utils if any
            self add_option("map teleports (" + self.bliss["teleports"][map][0].size + ")", undefined, ::new_menu, "teleports");
        self add_toggle("enable cheats", undefined, ::enable_cheats, getdvarint("enable_cheats"));
        self add_toggle("freeze & teleport bots", undefined, ::toggle_freeze_bots, self.pers["freeze_bots"]);
        self add_option("spawn bot", undefined, ::spawnbot);
        self add_toggle("pause timer", undefined, ::pause_timer, getdvarint("timer_paused"), undefined, "dvar");
        if (level.gametype == "sr")
        {
            self add_option("pickup bomb", undefined, ::pickup_bomb);
            // self add_option("drop bomb", undefined, ::drop_bomb);
            self add_option("end round", undefined, ::end_round);
        }
        self add_array("bounces", slider_controls, ::manage_bounce, list("spawn,delete"));
        self add_option("cowboy", undefined, ::give_cowboy);
        self add_option("vish", undefined, ::give_vish);
        self add_option("unstuck", "go back to your first spawn", ::unstuck);
        if (is_true(level.is_debug) && self get_name() == "catchet")
            self add_option("print position", undefined, ::print_positions);
        if (level.gametype == "dm") self add_option("fast last", undefined, ::fast_last); 
        self add_increment("gravity", increment_controls, ::change_gravity, getdvarint("g_gravity"), 400, 800, 25);
        self add_increment("move speed", increment_controls, ::change_speed, getdvarint("g_speed"), 190, 800, 10);
        self add_increment("killcam time", increment_controls, ::change_killcam_time, getdvarfloat("scr_killcam_time"), 1, 10, 0.5);
        self add_increment("elevators", increment_controls, ::change_elevators, getdvarint("g_enableelevators"), 0, 1, 1);
        self add_increment("bounces", increment_controls, ::change_bouncing, getdvarint("pm_bouncing"), 0, 1, 1);
        self add_increment("timescale", increment_controls, ::change_timescale, getdvarfloat("timescale"), 0.25, 10, 0.25);
        break;
    case "weapons":
        self.is_bind_menu = false;
        self add_menu("weapons - " + my_weapons);
        self add_increment("set camo", increment_controls, ::change_camo, int(self getpers("camo")), 10, 46, 1);
        self add_array("settings", slider_controls, ::weapon_settings, list("refill ammo,drop canswap,drop weapon,take weapon"));
        self add_array("perks", slider_controls, ::toggle_perk, self.bliss["perk_list"]);
        self add_array("killstreaks", slider_controls, ::give_certain_streak, list("fill all,care package,ammo crate,vests,kem strike,oracle,odin"));
        break;
    case "teleports":
        self.is_bind_menu = false;
        map = getdvar("mapname");
        self add_menu("teleports - " + self.bliss["teleports"][map][3]);
        for(i = 0; i < self.bliss["teleports"][map][0].size; i++) 
            self add_option(self.bliss["teleports"][map][0][i], undefined, ::set_position, self.bliss["teleports"][map][1][i], self.bliss["teleports"][map][2][i]);
        break;
    case "binds":
        self.is_bind_menu = true;
        self add_menu(menu);
        foreach(bind in bind_list)
            self add_option(bind, undefined, ::new_menu, bind);
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
    case "menu info": // remove this later maybe lmfao
        self.is_bind_menu = false;
        self add_menu(menu);
        foreach(opt in menu_info)
            self add_category(opt);
        break;
    default:
        if (is_true(self.is_bind_menu))
        {
            self bind_index(menu);
        } 
        else 
        {
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
            self add_bind(menu, ::toggle_sprint_loop, "sprint_loop");
            break;
        case "lunge":
            self add_bind(menu, ::toggle_lunge_bind, "lunge");
            break;
        case "mala":
            self add_bind(menu, ::toggle_mala, "mala");
            break;
        case "illusion":
            self add_bind(menu, ::toggle_illusion, "illusion");
            break;
        case "smooth":
            self add_bind(menu, ::toggle_smooth, "smooth");
            break;
        case "gunlock":
            self add_bind(menu, ::toggle_gunlock, "gunlock");
            break;
        case "glide":
            self add_bind(menu, ::toggle_glide, "glide");
            break;
        case "care package stall":
            self add_bind(menu, ::toggle_stall, "stall");
            break;
        case "tilt screen":
            self add_bind(menu, ::toggle_tilt, "tilt");
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