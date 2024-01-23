var z = global.zoom - global.zoom * 0.5 * (array_length(global.players) > 2 && global.usesplitscreen)

if(global.pause)
{
    application_surface_draw_enable(0)
    if(!surface_exists(pauseSurface))
    {
        if(pauseSurface == -1)
        {
            instance_deactivate_all(true)
        }

        pauseSurface = surface_create(SC_W / z, SC_H / z)

        surface_set_target(pauseSurface)

        if(global.blurOnPause)
            shader_set(sh_blur)

        draw_surface_ext(application_surface, 0, 0, z, z, 0, c_white, 1)

        if(global.blurOnPause)
            shader_reset()

        surface_reset_target()

        draw_surface_ext(pauseSurface, 0, 0, global.sc * global.zoom, global.sc * global.zoom, 0, c_white, 1);
    }
    else
    {
        draw_surface_ext(pauseSurface, 0, 0, global.sc * global.zoom, global.sc * global.zoom, 0, c_white, 1);
    }
}
