var a = 0.01

for (var i = 0; i < rope_points_count - 1; i++)
{
    var x1 = round(rope_points[i].pos.x / a) * a
    var y1 = round(rope_points[i].pos.y / a) * a
    var x2 = round(rope_points[i + 1].pos.x / a) * a
    var y2 = round(rope_points[i + 1].pos.y / a) * a

    draw_line_width_colour(x1, y1, x2, y2, 4, c_black, c_black)
    draw_circle_color(x2, y2, 2, c_black, c_black, 0)
    if i == 0
        draw_circle_color(x1, y1, 2, c_black, c_black, 0)
    if i == rope_points_count - 2
        draw_circle_color(x2 + lengthdir_x(1, point_direction(x1, y1, x2, y2)), y2 + lengthdir_y(1, point_direction(x1, y1, x2, y2)), 1, c_black, c_black, 0)
}
for (var i = 0; i < rope_points_count - 1; i++)
{
    var x1 = round(rope_points[i].pos.x / a) * a
    var y1 = round(rope_points[i].pos.y / a) * a
    var x2 = round(rope_points[i + 1].pos.x / a) * a
    var y2 = round(rope_points[i + 1].pos.y / a) * a

    draw_line_width_colour(x1, y1, x2, y2, 2, rope_colors[i % array_length(rope_colors)], rope_colors[i % array_length(rope_colors)])
    if i == 0
        draw_circle_color(x1, y1, 1, rope_colors[i % array_length(rope_colors)], rope_colors[i % array_length(rope_colors)], 0)
    draw_circle_color(x2, y2, 1, rope_colors[i % array_length(rope_colors)], rope_colors[i % array_length(rope_colors)], 0)
}
