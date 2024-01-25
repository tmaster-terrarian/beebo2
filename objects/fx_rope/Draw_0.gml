rope_points[0] = [x, y]
rope_points[array_length(rope_points) - 1] = [x + x2, y + y2]
for (r = 0; r < array_length(rope_points) * 2; r++)
{
    magnitude = 1
    choice = random_range(0, rope_points_count - 1)
    if (choice > 0)
    {
        pointA = rope_points[choice]
        pointB = rope_points[choice + 1]
        vector = [(pointB[0] - pointA[0]), (pointB[1] - pointA[1])]
        if (!collision_point(pointB[0], pointB[1], par_solid, 1, 0))
        {
            vector[0] += lengthdir_x(0.1, point_direction(pointB[0], pointB[1], rope_points[array_length(rope_points) - 1, 0], rope_points[array_length(rope_points) - 1, 1]))
            vector[1] += lengthdir_y(0.1, point_direction(pointB[0], pointB[1], rope_points[array_length(rope_points) - 1, 0], rope_points[array_length(rope_points) - 1, 1]))
            // vector[1] += grv * vector[0] - (0.18 * clamp(abs(hsp), 0, 1))
        }
        magnitude = point_distance(0, 0, vector[0], vector[1])
        normal_vec = [vector[0] / magnitude, vector[1] / magnitude]
        corrected_vec = [normal_vec[0], normal_vec[1]]
        rope_points[choice + 1] = [pointA[0] + corrected_vec[0], pointA[1] + corrected_vec[1]]
        rope_points[array_length(rope_points) - 1] = [x + x2, y + y2]
    }
}
rope_points[0] = [x, y]
rope_points[array_length(rope_points) - 1] = [x + x2, y + y2]

for (var i = 0; i < rope_points_count - 1; i++)
{
    draw_line_width_colour(rope_points[i, 0], rope_points[i, 1], rope_points[i + 1, 0], rope_points[i + 1, 1], 3, c_black, c_black)
    if i == rope_points_count - 2
        draw_line_width_colour(rope_points[i, 0], rope_points[i, 1], rope_points[i + 1, 0] + lengthdir_x(1, point_direction(rope_points[i, 0], rope_points[i, 1], rope_points[i + 1, 0], rope_points[i + 1, 1])), rope_points[i + 1, 1] + lengthdir_y(1, point_direction(rope_points[i, 0], rope_points[i, 1], rope_points[i + 1, 0], rope_points[i + 1, 1])), 1, c_black, c_black)
}
for (var i = 0; i < rope_points_count - 1; i++)
{
    draw_line_width_colour(rope_points[i, 0], rope_points[i, 1], rope_points[i + 1, 0], rope_points[i + 1, 1], 1, rope_colors[i % array_length(rope_colors)], rope_colors[i % array_length(rope_colors)])
}
