var a = 0.01

for (var i = 0; i < rope_points_count - 1; i++)
{
    var x1 = round(rope_points[i].pos.x / a) * a
    var y1 = round(rope_points[i].pos.y / a) * a
    var x2 = round(rope_points[i + 1].pos.x / a) * a
    var y2 = round(rope_points[i + 1].pos.y / a) * a

    draw_sprite_ext(spr_fx_chain, 0, x1, y1, point_distance(x1, y1, x2, y2)/6, -1, point_direction(x1, y1, x2, y2), c_white, 1)

    if i == rope_points_count - 2
        draw_sprite_ext(spr_fx_lamp, 0, x2, y2, 1, -1, point_direction(x1, y1, x2, y2), c_white, 1)
}
