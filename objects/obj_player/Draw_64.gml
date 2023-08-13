draw_set_font(fnt_console)
display_set_gui_size(320, 180)

draw_text(1, 1, $"x: {x}")
draw_text(1, 11, $"y: {y}")
draw_text(1, 21, $"state: {state}")
draw_text(1, 31, $"platformtarget: {platformtarget}")

if(instance_exists(platformtarget))
{
    draw_set_alpha(0.5)
    draw_set_color(c_lime)
    draw_line_width(32, 36, platformtarget.x - obj_camera._x - 1, platformtarget.y - obj_camera._y - 1, 1)
    draw_set_alpha(1)
    draw_set_color(c_white)
}
