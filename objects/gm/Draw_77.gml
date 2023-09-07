if(global.pause)
{
    application_surface_draw_enable(0)
    shader_set(sh_blur)
    draw_surface_ext(application_surface, 0, 0, global.sc * global.zoom, global.sc * global.zoom, 0, c_white, 1)
    shader_reset()
}
