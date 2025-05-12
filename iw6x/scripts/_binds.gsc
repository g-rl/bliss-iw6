#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\_utils;
#include scripts\_menu;
#include scripts\_functions;

// add mantle & ladder checks for crash safety (anims)

reload_snl()
{
    self thread save_pos_bind();
    self thread load_pos_bind();
}

save_pos_bind()
{
    self endon("stopsavepos");
    level endon("game_ended");
    for(;;)
    {
        self waittill("+actionslot 3");
        if(!self in_menu() && self getstance() == "crouch")
        {
            self save_position();
            self IPrintLnBold("position saved");
        }
    }
}

load_pos_bind()
{
    self endon("stoploadpos");
    level endon("game_ended");
    for(;;)
    {
        self waittill("+actionslot 2");
        if(!self in_menu() && self getstance() == "crouch")
            self load_position();
    }
}

toggle_stall(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
    {
        self thread care_package_stall(bind, pers);
    }
    else
    {
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
        self thread stz_tilt_bind(bind, pers);
    }
    else
    {
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
        self thread glidebind(bind, pers);
    }
    else
    {
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
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
    {
        self thread sprintloopbind(bind, pers);
    }
    else
    {
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
        self thread malabind(bind, pers);
    }
    else
    {
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
        self thread illusioncanswapbind(bind, pers);
    }
    else
    {
        self notify("stop" + pers);
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

toggle_gunlock(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
    {
        self thread gunlockbind(bind, pers);
    }
    else
    {
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
            self switchtoweaponimmediate("alt_" + self GetCurrentWeapon());
            waitframe();
            self canswap();
        }
        wait 0.1;
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
        self thread smoothbind(bind, pers);
    }
    else
    {
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

toggle_lunge_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
    {
        self thread lungebind(bind, pers);
    }
    else
    {
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

illusion()
{
    instashoot();
}