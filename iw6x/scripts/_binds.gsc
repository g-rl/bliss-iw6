#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gamelogic;
#include common_scripts\utility;
#include scripts\_utils;
#include scripts\_menu;
#include scripts\_functions;

toggle_stall(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
    {
        self iprintln("care package bind ^2on");
        self thread care_package_stall(bind, pers);
    }
    else
    {
        self iprintln("care package bind ^1off");
        self notify("stop" + pers);
    }
}

care_package_stall(bind, endonstring)
{
    self notify("stop" + endonstring);
    self endon("stop" + endonstring);
    self endon("disconnect");

    for(;;)
    {
        self waittill(bind);
        if (self isonladder() || self ismantling()) continue;
        if (!self in_menu())
        {
            model = spawn("script_model", self.origin);
            model setmodel("tag_origin");
            self playerlinkto(model);
            self thread game_bar();
            wait 0.1;
            self waittill(bind);
            self notify("stopgamebar");
            self setclientomnvar("ui_securing", 0);
            self setclientomnvar("ui_securing_progress", 0);
            self unlink();
            model delete();
        }
        wait 0.01;
    }
}

game_bar()
{
    self endon("stopgamebar");
   	self setclientomnvar("ui_securing", 1);

    progress = 0;

    for(i=0; i<100; i++)
    {
        self setclientomnvar("ui_securing_progress", progress);
        progress += 0.01;
        waitframe();
    }

    self setclientomnvar("ui_securing", 0);
    self setclientomnvar("ui_securing_progress", 0);
}

toggle_tilt(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
    {
        self iprintln("tilt screen bind ^2on");
        self thread stz_tilt_bind(bind, pers);
    }
    else
    {
        self iprintln("tilt screen bind ^1off");
        self setplayerangles((self.angles[0],self.angles[1],0));   
        self.tilting = 0;
        self notify("stop" + pers);
    }
}

stz_tilt_bind(bind, endonstring)
{
    self notify("stop" + endonstring);
    self endon("stop" + endonstring);
    self endon("disconnect");

    for(;;)
    {
        self waittill(bind);

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

toggle_glide(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
    {
        self iprintln("glide bind ^2on");
        self thread glidebind(bind, pers);
    }
    else
    {
        self iprintln("glide bind ^1off");
        self notify("stop" + pers);
    }
}

glidebind(bind, endonstring) 
{
    self notify("stop" + endonstring);
    self endon("stop" + endonstring);
    self endon("disconnect");
   
    for(;;) 
    {
        self waittill(bind);
        if (self isonladder() || self ismantling()) continue;
        if (!self in_menu())
        {
            instashoot();
            setweaponanim(30);
            wait 0.1;
            setweaponanim(31);
        }
        wait 0.1;
    }
}

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
        if (self isonladder() || self ismantling()) continue;
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
        if (self isonladder() || self ismantling()) continue;
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
        if (self isonladder() || self ismantling()) continue;
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
        if (self isonladder() || self ismantling()) continue;
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
        if (self isonladder() || self ismantling()) continue;
        if (!self in_menu())
        {
            self canswap();
            waitframe();
            self illusion();
        }
        wait 0.1;
    }
}

illusion()
{
    instashoot();
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
        if (self isonladder() || self ismantling()) continue;
        if (!self in_menu())
        {
            instashoot();
            setweaponanim(11);
        }
        wait 0.1;
    }
}