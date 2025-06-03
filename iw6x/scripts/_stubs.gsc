#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\gametypes\sr;
#include scripts\_menu;
#include scripts\_functions;
#include scripts\_utils;

damage_stub(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, boneIndex)
{
    if (sMeansofDeath != "MOD_FALLING" && sMeansofDeath != "MOD_TRIGGER_HURT" && sMeansofDeath != "MOD_SUICIDE") 
    {
        if (is_valid_weapon(sWeapon)) 
            iDamage = 999;

        if (sMeansofDeath == "MOD_FALLING")
            iDamage = 0;

        xp = int(eattacker.plant_xp);

        if (getdvar("g_gametype") == "sr" && is_valid_weapon(sWeapon)) // online point popup
            // eattacker thread maps\mp\gametypes\_rank::xpPointsPopup(eattacker.plant_xp);
            eattacker setclientomnvar("ui_points_popup", xp); // try this instead

        [[level.original_damage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, boneIndex);
    }
}

spawndogtags_stub(victim, attacker, position) // allows custom positions
{
    if (isagent(victim))
        return;

    if (victim maps\mp\killstreaks\_killstreaks::isusinghelisniper())
        return;

    if (isagent(attacker))
        attacker = attacker.owner;

    enemy_team = getotherteam(victim.team);

    pos = victim.origin + (0, 0, 14);
    cross = position + (0, 0, 14);

    if (is_true(level.dogtags[victim.guid]))
    {
        playfx(level.conf_fx["vanish"], level.dogtags[victim.guid].curOrigin);
        level.dogtags[victim.guid] notify("reset");	
    }
    else
    {
        visuals[0] = spawn("script_model", cross);
        visuals[0] setclientowner(victim);
        visuals[0] setmodel("prop_dogtags_foe_iw6");
        visuals[1] = spawn("script_model", cross);
        visuals[1] setclientowner(victim);
        visuals[1] setmodel("prop_dogtags_friend_iw6");
        
        trigger = spawn("trigger_radius", cross, 0, 32, 32);
        
        level.dogtags[victim.guid] = maps\mp\gametypes\_gameobjects::createuseobject("any", trigger, visuals, (0, 0, 16));
        
        maps\mp\gametypes\_objpoints::deleteobjpoint(level.dogtags[victim.guid].objPoints["allies"]);
        maps\mp\gametypes\_objpoints::deleteobjpoint(level.dogtags[victim.guid].objPoints["axis"]);		
        
        level.dogtags[victim.guid] maps\mp\gametypes\_gameobjects::setusetime(0);
        level.dogtags[victim.guid].onUse = ::onuse_stub;
        level.dogtags[victim.guid].victim = victim;
        level.dogtags[victim.guid].victimTeam = victim.team;
        
        level thread clearonvictimdisconnect(victim);
        victim thread tagteamupdater(level.dogtags[victim.guid]);
    }	

    level.dogtags[victim.guid].curOrigin = cross;
    level.dogtags[victim.guid].trigger.origin = cross;
    level.dogtags[victim.guid].visuals[0].origin = cross;
    level.dogtags[victim.guid].visuals[1].origin = cross;
    level.dogtags[victim.guid] maps\mp\gametypes\_gameobjects::initializetagpathvariables();

    level.dogtags[victim.guid] maps\mp\gametypes\_gameobjects::allowuse("any");	
            
    level.dogtags[victim.guid].visuals[0] thread showtoteam(level.dogtags[victim.guid], getotherteam(victim.team));
    level.dogtags[victim.guid].visuals[1] thread showtoteam(level.dogtags[victim.guid], victim.team);
    level.dogtags[victim.guid].attacker = attacker;

    objective_icon(level.dogtags[victim.guid].teamObjIds[victim.team], "waypoint_dogtags_friendlys" );
    objective_position(level.dogtags[victim.guid].teamObjIds[victim.team], cross);
    objective_state(level.dogtags[victim.guid].teamObjIds[victim.team], "active");
    objective_team(level.dogtags[victim.guid].teamObjIds[victim.team], victim.team);

    objective_icon(level.dogtags[victim.guid].teamObjIds[enemy_team], "waypoint_dogtags");
    objective_position(level.dogtags[victim.guid].teamObjIds[enemy_team], cross);
    objective_state(level.dogtags[victim.guid].teamObjIds[enemy_team], "active");
    objective_team(level.dogtags[victim.guid].teamObjIds[enemy_team], enemy_team);	

    playsoundatpos(cross, "mp_killconfirm_tags_drop");

    // need to make it so the other player doesnt show up as dead
    victim.extrascore1 = 1; // way to tell client we're downed
    // level notify( "sr_player_killed", victim );
    victim.tagAvailable = true;

    level.dogtags[victim.guid].visuals[0] scriptmodelplayanim("mp_dogtag_spin");
    level.dogtags[victim.guid].visuals[1] scriptmodelplayanim("mp_dogtag_spin");
}

onuse_stub(player)
{		
    if (is_true(player.owner))
        player = player.owner;

    self.trigger playsound("mp_killconfirm_tags_pickup");

    event = "kill_confirmed";

    player incplayerstat("killsconfirmed", 1);
    player incpersstat("confirmed", 1);
    player maps\mp\gametypes\_persistence::statsetchild("round", "confirmed", player.pers["confirmed"]);

    if (is_true(self.victim))
    {
        self.victim thread maps\mp\gametypes\_hud_message::splashnotify("sr_eliminated");
        level notify("sr_player_eliminated", self.victim);
    }

    sr_notifyteam("sr_ally_eliminated", "sr_enemy_eliminated", self.victim);

    if (is_true(self.victim))
    {
        if (!level.gameEnded)
        {
            self.victim setlowermessage("spawn_info", game["strings"]["spawn_next_round"]);
            self.victim thread maps\mp\gametypes\_playerlogic::removespawnmessageshortly(3.0);
        }
        
        self.victim.tagAvailable = undefined;
        self.victim.extrascore1 = 2;
    }

    if (self.attacker != player)
        self.attacker thread ontagspickup(event);

    player ontagspickup(event);
    player leaderdialogonplayer("kill_confirmed");
    player maps\mp\gametypes\_missions::processchallenge("ch_hideandseek");	

    self resettags();	
}

onpickup_stub(player) // no longer sets 2d / 3d icons due to console errors
{
	player.isBombCarrier = true;
	player incplayerstat("bombscarried", 1);
	player thread maps\mp\_matchdata::loggameevent("pickup", player.origin);
	
	player setclientomnvar("ui_carrying_bomb", true);
	setomnvar("ui_bomb_carrier", player getentitynumber());
	
	if (is_true(level.sd_loadout) && is_true(level.sd_loadout[player.team]))
		player thread applybombcarrierclass();

	if (!is_true(level.bombDefused))
	{
		teamplayercardsplash("callout_bombtaken", player, player.team);		
		leaderdialog("bomb_taken", player.pers["team"]);
	}

	maps\mp\_utility::playsoundonplayers(game["bomb_recovered_sound"], game["attackers"]);
}
