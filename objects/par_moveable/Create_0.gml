event_inherited()

ghost = 0
platformtarget = noone
on_ground = 0
facing = 1

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
    show_debug_message($"actor {id} got squished!")
}

_oncollide_h = function()
{
    hsp = 0
}
_oncollide_v = function()
{
    vsp = 0
}

movex = function(_x, _oncollide = _oncollide_h)
{
    rx += _x
    mx = round(rx)
    if(abs(mx))
    {
        rx -= mx
        var s = sign(mx)
        if(ghost || (place_meeting(x + mx, y, par_solid) && instance_place(x + mx, y, par_solid).ghost))
            x += mx
        else repeat(abs(mx))
        {
            if(place_meeting(x + s, y, par_solid))
            {
                if(!place_meeting(x + s, y - 1, par_solid))
                {
                    y -= 1
                    x += s
                    continue
                }
                else
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
    }
    mx = 0
}
movey = function(_y, _oncollide = _oncollide_v)
{
    ry += _y
    my = round(ry)
    if(abs(my))
    {
        ry -= my
        var s = sign(my)
        if(ghost || (place_meeting(x, y + my, par_solid) && instance_place(x, y + my, par_solid).ghost))
            y += my
        else repeat(abs(my))
        {
            if(place_meeting(x, y + s, par_solid))
            {
                if(!place_meeting(x + 1, y + s, par_solid))
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
                else
                    _oncollide()
                break
            }
            else
                y += s
        }
    }
    my = 0
}
