if(global.pause)
{
    application_surface_draw_enable(0)
    if(!surface_exists(pauseSurface))
    {
        if(pauseSurface == -1)
        {
            instance_deactivate_all(true)
        }
        pauseSurface = surface_create(SC_W / global.zoom, SC_H / global.zoom)
        surface_set_target(pauseSurface)
        shader_set(sh_blur)
        draw_surface_ext(application_surface, 0, 0, global.zoom, global.zoom, 0, c_white, 1)
        shader_reset()
        surface_reset_target()
    }
    else
    {
        draw_surface_ext(pauseSurface, 0, 0, global.sc * global.zoom, global.sc * global.zoom, 0, c_white, 1);
    }
}
