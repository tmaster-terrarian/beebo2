event_inherited()

ghost = 0
platformtarget = noone
on_ground = 0
facing = 1

ignoreJumpthrus = false

lasthsp = 0
lastvsp = 0

_is_riding = function(_id)
{
    var s = instance_place((bbox_left + bbox_right)/2, bbox_bottom + 2, par_solid)
    if(s)
    {
        if(s.ghost)
            return 0
    }
    return (s == _id)
}

_squish = function()
{
    hsp = 0
    vsp = 0
    LogInfo($"actor {id} got squished!")
}

_oncollide_h = function()
{
    hsp = 0
}
_oncollide_v = function()
{
    vsp = 0
}

movex = function(_x, _oncollide = noone, _dt = 0)
{
    rx += _x // * ((_dt) ? global.dt : 1)
    var mx = round(rx)
    if(abs(mx))
    {
        if(place_meeting(x, y, par_jumpthru) || ignoreJumpthrus)
            instance_deactivate_object(par_jumpthru)
        rx -= mx
        var s = sign(mx)
        if(ghost || (place_meeting(x + mx, y, par_solid) && instance_place(x + mx, y, par_solid).ghost))
            x += mx
        else repeat(abs(mx))
        {
            if(place_meeting(x + s, y, par_solid))
            {
                if(instance_place(x + s, y, par_solid).ghost || place_meeting(x + s, y, par_jumpthru))
                {
                    x += s
                    continue
                }
                else if(!place_meeting(x + s, y - 1, par_solid))
                {
                    y -= 1
                    x += s
                    continue
                }
                else if(_oncollide != noone)
                    _oncollide()
                break
            }
            else
            {
                if(on_ground && abs(hsp > 1))
                {
                    if(!place_meeting(x + s, y + 1, par_solid) && !place_meeting(x + s, y + 2, par_solid))
                        y += 1
                }
                x += s
            }
        }
        instance_activate_object(par_jumpthru)
    }
}
movey = function(_y, _oncollide = noone, _dt = 0)
{
    ry += _y // * ((_dt) ? global.dt : 1)
    var my = round(ry)
    if(abs(my))
    {
        if(my < 0 || ignoreJumpthrus)
        {
            instance_deactivate_object(par_jumpthru)
        }
        ry -= my
        var s = sign(my)
        if(ghost || (place_meeting(x, y + my, par_solid) && instance_place(x, y + my, par_solid).ghost))
            y += my
        else repeat(abs(my))
        {
            if(place_meeting(x, y + s, par_solid))
            {
                if(instance_place(x, y + s, par_solid).ghost)
                {
                    y += s
                    continue
                }
                else if(!place_meeting(x + 1, y + s, par_solid))
                {
                    x += 1
                    y += s
                    continue
                }
                else if(!place_meeting(x - 1, y + s, par_solid))
                {
                    x -= 1
                    y += s
                    continue
                }
                else if(_oncollide != noone)
                    _oncollide()
                break
            }
            else
                y += s
        }
        instance_activate_object(par_jumpthru)
    }
}
