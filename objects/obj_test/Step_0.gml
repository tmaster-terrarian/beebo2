if(keyboard_check_pressed(ord("R")))
    game_restart()

var inputdir = keyboard_check(vk_right) - keyboard_check(vk_left)

if(on_ground)
{
    platformtarget = instance_place((bbox_left + bbox_right)/2, bbox_bottom + 2, par_solid)
}

var accel = 0.12
var fric = 0.08
if(!on_ground)
{
    accel = 0.07
    fric = 0.02
}

if(inputdir == 1)
{
    if(hsp < 0)
        hsp = approach(hsp, 0, fric)
    if(hsp < 2)
        hsp = approach(hsp, 2, accel)

    if(place_meeting(x + 1, y, par_solid))
    {
        var w = instance_place(x + 1, y, par_solid)
        if(w)
        {
            var _diff = bbox_top - w.bbox_top
            if(_diff <= 8 && _diff > -4) && !position_meeting(w.bbox_left, w.bbox_top - 1, par_solid) && !object_is_ancestor(w.object_index, par_jumpthru)
            {
                vsp = 0
                while(position_meeting(bbox_right + 1, bbox_top, w))
                {
                    y--
                }
                x = w.bbox_left
                y = w.bbox_top
            }
        }
    }
}
else if(inputdir == -1)
{
    if(hsp > 0)
        hsp = approach(hsp, 0, fric)
    if(hsp > -2)
        hsp = approach(hsp, -2, accel)

    if(place_meeting(x - 1, y, par_solid))
    {
        var w = instance_place(x - 1, y, par_solid)
        if(w)
        {
            var _diff = bbox_top - w.bbox_top
            if(_diff <= 8 && _diff > -4) && !position_meeting(w.bbox_right, w.bbox_top - 1, par_solid) && !object_is_ancestor(w.object_index, par_jumpthru)
            {
                vsp = 0
                while(position_meeting(bbox_left - 1, bbox_top, w))
                {
                    y--
                }
                x = w.bbox_right
                y = w.bbox_top
            }
        }
    }
}
else
{
    hsp = approach(hsp, 0, fric * 2)
}

vsp = approach(vsp, vsp_max, grv)

if(keyboard_check_pressed(ord("Z")))
{
    if(on_ground)
    {
        platformtarget = noone
        var p = instance_place(x, y + 1, par_solid)
        if(p && !p.ghost && !p.nocollide)
        {
            vsp = -3.7
            hsp += p.hsp
            if(p.vsp < 0)
                vsp += p.vsp / 2
        }
    }
    else
    {
        if(place_meeting(x + 2, y, par_solid))
        {
            hsp = -2
            vsp = -2.75
        }
        else if(place_meeting(x - 2, y, par_solid))
        {
            hsp = 2
            vsp = -2.75
        }
    }
}

if(keyboard_check(vk_control))
{
    hsp = 0
    vsp = 0
    x = mouse_x
    y = mouse_y
}
