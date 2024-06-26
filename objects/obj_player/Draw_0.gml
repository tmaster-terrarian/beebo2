if(!surface_exists(drawSurface)) drawSurface = surface_create(room_width, room_height)

surface_set_target(drawSurface)
draw_clear_alpha(c_black, 0)

var drawgun = function(_v)
{
    if(_v && draw_gun && has_gun)
    {
        if(gamepad)
        {
            var d = fire_angle
            var m = point_distance(0, 0, aimx, aimy)

            dist = point_distance(0, 0, lengthdir_x(aimx, fire_angle), lengthdir_y(aimy, fire_angle))

            var nx = lengthdir_x(point_distance(0, 0, aimx, aimy), point_direction(0, 0, aimx, aimy)) * 24
            var ny = lengthdir_y(point_distance(0, 0, aimx, aimy), point_direction(0, 0, aimx, aimy)) * 24

            draw_set_alpha(0.75)

            draw_point_color(x + gun_pos.x * sign(facing) + nx, y + gun_pos.y + ny - 2, c_red)
            draw_point_color(x + gun_pos.x * sign(facing) + nx * 1.5, y + gun_pos.y + ny * 1.5 - 2, c_red)
            draw_point_color(x + gun_pos.x * sign(facing) + nx * 2, y + gun_pos.y + ny * 2 - 2, c_red)
            draw_point_color(x + gun_pos.x * sign(facing) + nx * 2.5, y + gun_pos.y + ny * 2.5 - 2, c_red)
            draw_point_color(x + gun_pos.x * sign(facing) + nx * 3, y + gun_pos.y + ny * 3 - 2, c_red)
            draw_point_color(x + gun_pos.x * sign(facing) + nx * 3.5, y + gun_pos.y + ny * 3.5 - 2, c_red)

            draw_set_alpha(1)

            if(abs(aimx) > 0 || abs(aimy) > 0)
                draw_sprite_ext(spr_player_gun_reticle2, 0, x + gun_pos.x * sign(facing) + (nx * 4), y + gun_pos.y + (ny * 4) - 2, gun_flip, 1, 0, c_white, 1)
        }

        draw_sprite_ext(
            gun_spr,
            gun_spr_ind,
            x + gun_pos.x * sign(facing) * stretch + lengthdir_x(-recoil, round(fire_angle / 10) * 10),
            y + gun_pos.y * squash + lengthdir_y(-recoil, round(fire_angle / 10) * 10),
            1 * stretch,
            1 * gun_flip * squash,
            round(fire_angle / 10) * 10,
            merge_color(c_white, c_red, (heat/heat_max)*0.5),
            1
        )
    }
}

drawgun(gun_behind)

// ponytail
var px = x - 5 * facing
if(facing < 0)
var px = x - 1 - 5 * facing
var py = y - 13 * squash
if(running)
{
    var f = floor(image_index)
    if(image_number == 8)
    {
        if(f == 1 || f == 2 || f == 4 || f == 5)
        {
            py += 1
        }
    }
    else if(image_number == 6)
    {
        px += 1 * facing
        if(f == 1 || f == 4)
        {
            py += 1
        }
    }
}
if(sprite_index == _sp.jump)
{
    px = x - 1 - 3 * facing
    py = y - 13
}
if(sprite_index == _sp.idle || sprite_index == _sp.idle_lookup)
{
    var f = floor(image_index)
    if(f == 0 || f == 1 || f == 2)
    {
        py += 1
    }
}
if(sprite_index == _sp.ledgegrab)
{
    px = x - 1
    py = y - 2
}
if(sprite_index == _sp.ledgeclimb)
{
    switch(floor(timer0))
    {
        case 0: case 1:
        {
            px = x - 1 - 13 * facing
            py = y - 2
            break;
        }
        case 2: case 3:
        {
            px = x - 1 - 10 * facing
            py = y - 3
            break;
        }
        case 4:
        {
            px = x - 1 - 7 * facing
            py = y - 4
            break;
        }
    }
}
py += duck
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

draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * stretch, image_yscale * squash, image_angle, c_white, 1)

drawgun(!gun_behind)

surface_reset_target()


if(flash > 0) shader_set(sh_flash)

draw_surface_ext(drawSurface, 0, 0, 1, 1, 0, image_blend, image_alpha)

if(flash > 0) shader_reset()


if(global.draw_debug)
{
    _draw_rect(bbox_left, bbox_top, bbox_right - 1, bbox_bottom - 1, c_red, 1, 1)

    for(var i = 0; i < array_length(collision_checks); i++)
    {
        var _c = collision_checks[i]
        _draw_rect(_c.x, _c.y, _c.x + _c.w, _c.y + _c.h, (_c.value) ? c_lime : c_red, 0.75)
    }

    array_clear(collision_checks)
}
