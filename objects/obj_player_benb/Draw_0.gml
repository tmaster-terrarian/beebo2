if(flash > 0)
    shader_set(sh_flash)

// scarffff
var px = x - 4 * facing
if(facing < 0)
var px = x - 1 - 4 * facing
var py = y - 9 * squash
if(running)
{
    var f = floor(image_index)
    if(f == 1 || f == 2 || f == 4 || f == 5)
    {
        py += 1
    }
}
if(sprite_index == _sp.jump)
{
    px = x - 1 - 2 * facing
    py = y - 10
}
if(sprite_index == _sp.ledgegrab)
{
    px = x - 1
    py = y - 1
}
if(sprite_index == _sp.punch_1 || sprite_index == _sp.punch_2)
{
    px += facing * min(image_index + 1, 3) - (image_index == 3) - (facing == 1)
}
if(sprite_index == _sp.ledgeclimb)
{
    switch(floor(timer0))
    {
        case 0: case 1:
        {
            px = x - 1 - 12 * facing
            py = y + 1
            break;
        }
        case 2: case 3:
        {
            px = x - 1 - 9 * facing
            py = y
            break;
        }
        case 4:
        {
            px = x - 1 - 6 * facing
            py = y - 1
            break;
        }
    }
}
py += duck
px += (ceil(duck) / 4) * facing - (ceil(duck) / 4) * (facing < 0)
ponytail_points[0] = [px, py]
if(!global.pause)
for (i = 0; i < ponytail_points_count - 1; i++) // slimepunk magic
{
    magnitude = 1
    pointA = ponytail_points[i]
    pointB = ponytail_points[i + 1]
    vector = [(pointB[0] - pointA[0]), (pointB[1] - pointA[1])]
    if (!collision_point(pointB[0], pointB[1], par_solid, 1, 0))
        vector[1] += grv * 2 - (0.09 * clamp(abs(hsp), 0, 1))
    vector[1] += random_range(-0.01, 0)
    magnitude = point_distance(0, 0, vector[0], vector[1])
    normal_vec = [vector[0] / magnitude, vector[1] / magnitude]
    normal_vec = [vector[0] / magnitude, vector[1] / magnitude]
    corrected_vec = [normal_vec[0] * ponytail_segment_len[i], normal_vec[1] * ponytail_segment_len[i]]
    ponytail_points[i + 1] = [pointA[0] + corrected_vec[0], pointA[1] + corrected_vec[1]]
}
ponytail_points[0] = [px, py]
if(ponytail_visible)
{
    for (var i = 0; i < ponytail_points_count - 1; i++)
    {
        draw_line_width_colour(ponytail_points[i, 0], ponytail_points[i, 1], ponytail_points[i + 1, 0], ponytail_points[i + 1, 1], 3, c_black, c_black)
        if i == ponytail_points_count - 2
            draw_line_width_colour(ponytail_points[i, 0], ponytail_points[i, 1], ponytail_points[i + 1, 0] + lengthdir_x(1, point_direction(ponytail_points[i, 0], ponytail_points[i, 1], ponytail_points[i + 1, 0], ponytail_points[i + 1, 1])), ponytail_points[i + 1, 1] + lengthdir_y(1, point_direction(ponytail_points[i, 0], ponytail_points[i, 1], ponytail_points[i + 1, 0], ponytail_points[i + 1, 1])), 1, c_black, c_black)
    }
    for (var i = 0; i < ponytail_points_count - 1; i++)
    {
        draw_line_width_colour(ponytail_points[i, 0], ponytail_points[i, 1], ponytail_points[i + 1, 0], ponytail_points[i + 1, 1], 1, ponytail_colors[i], ponytail_colors[i])
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

drawMyShit()
