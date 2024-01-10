for(var i = 0; i < array_length(particles); i++)
{
    var p = particles[i]
    draw_sprite_ext(sprite_index, floor(abs(p.img)) * sign(p.img), p.x + x * !posGlobal, p.y + y * !posGlobal, p.scale, p.scale, p.angle, p.color, p.alpha)

    if global.draw_debug
        draw_line_color(p.x + x * !posGlobal, p.y + y * !posGlobal, p.x + p.spdX + lengthdir_x(p.spd, p.dir) + x * !posGlobal, p.y + p.spdY + lengthdir_y(p.spd, p.dir) + y * !posGlobal, c_blue, c_blue)
}
