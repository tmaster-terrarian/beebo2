event_inherited()

nocollide = 0

move = function(_x, _y)
{
    rx += _x
    ry += _y
    mx = round(rx)
    my = round(ry)
    if(abs(mx) || abs(my))
    {
        ghost = 1
        if(abs(mx))
        {
            rx -= mx
            x += mx
            if(mx > 0)
            {
                if(!nocollide)
                with(par_moveable)
                {
                    if(place_meeting(x, y, other.id))
                    {
                        movex(other.bbox_right - bbox_left, _squish)
                    }
                    else if(_is_riding(other.id) || platformtarget == other.id)
                    {
                        movex(other.mx)
                    }
                }
            }
            else
            {
                if(!nocollide)
                with(par_moveable)
                {
                    if(place_meeting(x, y, other.id))
                    {
                        movex(other.bbox_left - bbox_right, _squish)
                    }
                    else if(_is_riding(other.id) || platformtarget == other.id)
                    {
                        movex(other.mx)
                    }
                }
            }
        }
        if(abs(my))
        {
            ry -= my
            y += my
            if(my > 0)
            {
                if(!nocollide)
                with(par_moveable)
                {
                    if(place_meeting(x, y, other.id))
                    {
                        movey(other.bbox_bottom - bbox_top, _squish)
                    }
                    else if(_is_riding(other.id) || platformtarget == other.id)
                    {
                        vsp = 0
                        movey(other.my)
                    }
                }
            }
            else
            {
                if(!nocollide)
                with(par_moveable)
                {
                    if(place_meeting(x, y, other.id))
                    {
                        movey(other.bbox_top - bbox_bottom, _squish)
                    }
                    else if(_is_riding(other.id) || platformtarget == other.id)
                    {
                        vsp = 0
                        movey(other.my)
                    }
                }
            }
        }
        ghost = 0
    }
    mx = 0
    my = 0
}
