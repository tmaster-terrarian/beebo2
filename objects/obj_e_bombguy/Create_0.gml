event_inherited();

states =
{
    normal: function()
    {with(other){
        if (input_dir == 1)
        {
            if (hsp < 0)
            {
                hsp = approach(hsp, 0, fric * global.dt)
            }
            else if (on_ground && vsp >= 0)
            {
                // moving sprite
            }
            if(abs(hsp) > spd * 1.3)
                run = 7
            else
                run = 0
            if (hsp < spd)
                hsp = approach(hsp, spd, accel * global.dt)
            if (hsp > spd) && on_ground
                hsp = approach(hsp, spd, fric/2 * global.dt)
            if on_ground
            {
                facing = 1
            }
            else
                facing = 1
        }
        else if (input_dir == -1)
        {
            if (hsp > 0)
            {
                hsp = approach(hsp, 0, fric * global.dt)
            }
            else if (on_ground && vsp >= 0)
            {
                // moving sprite
            }
            if(abs(hsp) > spd * 1.3)
                run = 7
            else
                run = 0
            if (hsp > -spd)
                hsp = approach(hsp, -spd, accel * global.dt)
            if (hsp < -spd) && on_ground
                hsp = approach(hsp, -spd, fric/2 * global.dt)
            if on_ground
            {
                facing = -1
            }
            else
                facing = -1
        }
        else
        {
            hsp = approach(hsp, lasthsp, fric * 2 * global.dt)
        }
    }},
    attack: function()
    {with(other){
        if(timer0 == 0)
        {
            hsp = 0
            vsp = 0
            timer0++
            // set sprites and such
        }
        if(timer0 < 20)
            timer0 = approach(timer0, 20, global.dt * attack_speed)
        else if(timer0 < 40)
            timer0 = approach(timer0, 40, global.dt * attack_speed)
        if(timer0 == 20 || timer0 == 40)
        {
            var left = (timer0 == 20)
            with(instance_create_depth(x + (7 * left) + (-5 * !left), y - 4, depth - 1, obj_bombguy_bomb))
            {
                hsp = 2 * other.facing
                vsp = -1.8

                parent = other
                damage = other.damage
                team = other.team
                _team = other.team
            }
        }
        if(timer0 >= 40 && timer0 < 70)
            timer0 = approach(timer0, 70, global.dt * attack_speed)
        if(timer0 == 70)
        {
            state = "normal"
            timer0 = 0
        }
    }}
}
