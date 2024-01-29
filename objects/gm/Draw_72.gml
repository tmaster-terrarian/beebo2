if(!global.pause)
{
    if(global.usesplitscreen)
    for(var i = 0; i < array_length(global.players); i++)
    {
        view_set_visible(i, 1)
    }
    application_surface_draw_enable(1)
}
var z = (global.zoom - global.zoom * 0.5 * (array_length(global.players) > 2 && global.usesplitscreen))
surface_resize(application_surface, ceil(SC_W / z), ceil(SC_H / z))
