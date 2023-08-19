draw_self()

if(global.draw_debug)
{
    _draw_rect(bbox_left, bbox_top, bbox_right - 1, bbox_bottom - 1, c_red, 1, 1)

    for(var i = 0; i < array_length(collision_checks); i++)
    {
        var _c = collision_checks[i]
        _draw_rect(_c.x, _c.y, _c.x + _c.w, _c.y + _c.h, (_c.value) ? c_lime : c_red, 0.75)
    }

    array_clear(collision_checks)
}
