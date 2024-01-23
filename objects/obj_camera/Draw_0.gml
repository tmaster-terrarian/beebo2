if(global.draw_debug)
{
    draw_line_width_color(x, y, tx, ty, 1, c_aqua, c_aqua)
    if(instance_exists(target))
        draw_line_width_color(target.x, target.y, tx, ty, 1, c_aqua, c_aqua)
}
