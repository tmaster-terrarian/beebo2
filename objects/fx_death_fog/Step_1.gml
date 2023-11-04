PAUSECHECK

t += global.dt

if(!done)
{
    if(global.sctint_alpha < 0.2)
    {
        global.sctint_alpha = approach(global.sctint_alpha, 0.2, 0.005 * global.dt)
    }

    nextparticletimer = approach(nextparticletimer, 0, global.dt)
    if(nextparticletimer == 0)
    {
        nextparticletimer = 6

        var xx = obj_camera.tx - SC_W / 2
        var yy = obj_camera.ty - SC_H / 2
        repeat(2)
        {
            instance_create_depth(random_range(xx, xx + SC_W), random_range(yy, yy + SC_H), -100, fx_death_fog_particle)
        }
    }

    nexthurttimer = approach(nexthurttimer, 0, global.dt)
    if(nexthurttimer == 0)
    {
        nexthurttimer = 15

        with(par_unit)
        {
            if(team == Team.player)
            {
                damage_event(new DamageEventContext(noone, self, proctype.none, self.hp_max * (0.001 * other.t/60), 0).forceCrit(0))
            }
        }
    }
}
else
{
    if(global.sctint_alpha > 0)
    {
        global.sctint_alpha = approach(global.sctint_alpha, 0, 0.01 * global.dt)
    }
    if(global.sctint_alpha == 0)
        instance_destroy()
}
