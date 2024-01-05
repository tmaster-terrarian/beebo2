walled.ghost = 1
walled.nocollide = 1
instance_deactivate_object(walled)

event_inherited();

instance_activate_object(walled)

with(walled)
{
    var r = instance_position(bbox_right + 1, bbox_bottom - 1, par_unit)
    var l = instance_position(bbox_left - 2, bbox_bottom - 2, par_unit)
    var pushx = 0

    if(r)
    {
        pushx -= (r.input_dir == -1)
    }
    if(l)
    {
        pushx += (l.input_dir == 1)
    }

    other.movex(pushx * global.dt * 0.2, noone)

    ghost = 0
    nocollide = 0
    x = other.x
    y = other.y
}
