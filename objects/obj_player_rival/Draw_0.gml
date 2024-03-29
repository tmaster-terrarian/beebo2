// sworded
if(draw_sword)
{
    if(flash > 0)
        shader_set(sh_flash)

    var sx = swordpos.x * facing * stretch
    var sy = swordpos.y * squash

    var ax = lengthdir_x(point_distance(0, 0, sx, sy), point_direction(0, 0, sx, sy) + image_angle)
    var ay = lengthdir_y(point_distance(0, 0, sx, sy), point_direction(0, 0, sx, sy) + image_angle)

    draw_sprite_outlined_ext(spr_anime_sword, sword_nohand, x + ax, y + ay, sword_xscale, sword_yscale * squash, _sword_angle + image_angle, c_white, c_black, 1, 1, 0)

    if(flash > 0)
        shader_reset()
}

if(flash > 0)
    shader_set(sh_flash)

// hairs
var px1 = x - 5 * facing
if(facing < 0)
var px1 = x - 1 - 5 * facing
var py1 = y - 13 * squash
if(running)
{
    var f = floor(image_index)
    if(image_number == 8)
    {
        if(f == 1 || f == 2 || f == 4 || f == 5)
        {
            py1 += 1
        }
    }
    else if(image_number == 6)
    {
        px1 += 1 * facing
        if(f == 1 || f == 4)
        {
            py1 += 1
        }
    }
}
if(sprite_index == _sp.jump)
{
    px1 = x - 1 - 4 * facing
    py1 = y - 13
}
if(sprite_index == _sp.idle || sprite_index == _sp.idle_lookup)
{
    var f = floor(image_index)
    if(f == 0 || f == 1 || f == 2)
    {
        py1 += 1
    }
}
if(sprite_index == _sp.ledgegrab)
{
    px1 = x - 1
    py1 = y - 2
}
if(sprite_index == _sp.ledgeclimb)
{
    switch(floor(timer0))
    {
        case 0: case 1:
        {
            px1 = x - 1 - 13 * facing
            py1 = y - 2
            break;
        }
        case 2: case 3:
        {
            px1 = x - 1 - 10 * facing
            py1 = y - 3
            break;
        }
        case 4:
        {
            px1 = x - 1 - 7 * facing
            py1 = y - 4
            break;
        }
    }
}
py1 += duck
hair1_points[0] = [px1, py1]
if(!global.pause)
for (i = 0; i < hair1_points_count - 1; i++)
{
    magnitude = 1
    pointA = hair1_points[i]
    pointB = hair1_points[i + 1]
    vector = [(pointB[0] - pointA[0]), (pointB[1] - pointA[1])]
    if (!collision_point(pointB[0], pointB[1], obj_wall, 1, 0))
        vector[1] += grv * 2 - (0.36 * clamp(abs(hsp), 0, 1))
    vector[1] += random_range(-0.01, 0)
    magnitude = point_distance(0, 0, vector[0], vector[1])
    normal_vec = [vector[0] / magnitude, vector[1] / magnitude]
    normal_vec = [vector[0] / magnitude, vector[1] / magnitude]
    corrected_vec = [normal_vec[0] * hair1_segment_len[i], normal_vec[1] * hair1_segment_len[i]]
    hair1_points[i + 1] = [pointA[0] + corrected_vec[0], pointA[1] + corrected_vec[1]]
}
hair1_points[0] = [px1, py1]
if(ponytail_visible)
{
    for (var i = 0; i < hair1_points_count - 1; i++)
    {
        draw_line_width_colour(hair1_points[i, 0], hair1_points[i, 1], hair1_points[i + 1, 0], hair1_points[i + 1, 1], 3, c_black, c_black)
        if i == hair1_points_count - 2
            draw_line_width_colour(hair1_points[i, 0], hair1_points[i, 1], hair1_points[i + 1, 0] + lengthdir_x(1, point_direction(hair1_points[i, 0], hair1_points[i, 1], hair1_points[i + 1, 0], hair1_points[i + 1, 1])), hair1_points[i + 1, 1] + lengthdir_y(1, point_direction(hair1_points[i, 0], hair1_points[i, 1], hair1_points[i + 1, 0], hair1_points[i + 1, 1])), 1, c_black, c_black)
    }
    for (var i = 0; i < hair1_points_count - 1; i++)
    {
        draw_line_width_colour(hair1_points[i, 0], hair1_points[i, 1], hair1_points[i + 1, 0], hair1_points[i + 1, 1], 1, hair1_colors[i], hair1_colors[i])
    }
}

// hairs 2
var px2 = x + 3 * facing
if(facing < 0)
var px2 = x - 1 + 3 * facing
var py2 = y - 13 * squash
if(running)
{
    var f = floor(image_index)
    if(image_number == 8)
    {
        if(f == 1 || f == 2 || f == 4 || f == 5)
        {
            py2 += 1
        }
    }
    else if(image_number == 6)
    {
        px2 += 1 * facing
        if(f == 1 || f == 4)
        {
            py2 += 1
        }
    }
}
if(sprite_index == _sp.jump)
{
    px2 = x + 2 * facing
    py2 = y - 13
}
if(sprite_index == _sp.idle || sprite_index == _sp.idle_lookup)
{
    var f = floor(image_index)
    if(f == 0 || f == 1 || f == 2)
    {
        py2 += 1
    }
}
if(sprite_index == _sp.ledgegrab)
{
    px2 = x - 1 - 7 * facing
    py2 = y - 2
}
if(sprite_index == _sp.ledgeclimb)
{
    switch(floor(timer0))
    {
        case 0: case 1:
        {
            px2 = x - 1 - 7 * facing
            py2 = y - 2
            break;
        }
        case 2: case 3:
        {
            px2 = x - 1 - 4 * facing
            py2 = y - 3
            break;
        }
        case 4:
        {
            px2 = x - 1 - 1 * facing
            py2 = y - 4
            break;
        }
    }
}
py2 += duck
hair2_points[0] = [px2, py2]
if(!global.pause)
for (i = 0; i < hair2_points_count - 1; i++)
{
    magnitude = 1
    pointA = hair2_points[i]
    pointB = hair2_points[i + 1]
    vector = [(pointB[0] - pointA[0]), (pointB[1] - pointA[1])]
    if (!collision_point(pointB[0], pointB[1], obj_wall, 1, 0))
        vector[1] += grv * 2 - (0.36 * clamp(abs(hsp), 0, 1))
    vector[1] += random_range(-0.01, 0)
    magnitude = point_distance(0, 0, vector[0], vector[1])
    normal_vec = [vector[0] / magnitude, vector[1] / magnitude]
    normal_vec = [vector[0] / magnitude, vector[1] / magnitude]
    corrected_vec = [normal_vec[0] * hair2_segment_len[i], normal_vec[1] * hair2_segment_len[i]]
    hair2_points[i + 1] = [pointA[0] + corrected_vec[0], pointA[1] + corrected_vec[1]]
}
hair2_points[0] = [px2, py2]
if(ponytail_visible)
{
    for (var i = 0; i < hair2_points_count - 1; i++)
    {
        draw_line_width_colour(hair2_points[i, 0], hair2_points[i, 1], hair2_points[i + 1, 0], hair2_points[i + 1, 1], 3, c_black, c_black)
        if i == hair2_points_count - 2
            draw_line_width_colour(hair2_points[i, 0], hair2_points[i, 1], hair2_points[i + 1, 0] + lengthdir_x(1, point_direction(hair2_points[i, 0], hair2_points[i, 1], hair2_points[i + 1, 0], hair2_points[i + 1, 1])), hair2_points[i + 1, 1] + lengthdir_y(1, point_direction(hair2_points[i, 0], hair2_points[i, 1], hair2_points[i + 1, 0], hair2_points[i + 1, 1])), 1, c_black, c_black)
    }
    for (var i = 0; i < hair2_points_count - 1; i++)
    {
        draw_line_width_colour(hair2_points[i, 0], hair2_points[i, 1], hair2_points[i + 1, 0], hair2_points[i + 1, 1], 1, hair2_colors[i], hair2_colors[i])
    }
}

var sx = image_xscale
var sy = image_yscale
image_xscale *= stretch
image_yscale *= squash

draw_self()

image_xscale = sx
image_yscale = sy

if(flash > 0)
    shader_reset()
