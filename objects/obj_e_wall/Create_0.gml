event_inherited();

walled = instance_create_depth(x, y, depth, par_solid, {sprite_index: spr_tough_wall2})
walled.move = function(_x, _y) {ghost = 0}
walled.depth = 70

_image_xscale = 2
image_yscale = 2

y -= 18

bounces = 2

_oncollide_v = function() {
    vsp = 0
}
_oncollide_h = function() {
    hsp = 0
}

states = {
    normal: function() { with(other) {
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
    }}
}
state = "normal"
