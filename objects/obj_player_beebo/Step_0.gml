event_inherited();

PAUSECHECK

ponytail_visible = 1
gun_behind = 0
if(running && sprite_index != _sp.crawl)
{
    ponytail_visible = 1
    switch(floor(image_index))
    {
        case 0:
            gun_pos.x = -3; gun_pos.y = -6;
            break;
        case 1:
            gun_pos.x = -3; gun_pos.y = -5;
            break;
        case 2:
            gun_pos.x = -3; gun_pos.y = -5;
            break;
        case 3:
            gun_pos.x = -3; gun_pos.y = -6;
            break;
        case 4:
            gun_pos.x = -3; gun_pos.y = -6;
            break;
        case 5:
            gun_pos.x = -3; gun_pos.y = -5;
            break;
        case 6:
            gun_pos.x = -3; gun_pos.y = -5;
            break;
        case 7:
            gun_pos.x = -3; gun_pos.y = -6;
            break;
    }
}
else if(sprite_index == _sp.crawl)
{
    ponytail_visible = 0
    gun_behind = 1
    switch(floor(image_index))
    {
        case 0:
            gun_pos.x = -4; gun_pos.y = -5;
            break;
        case 1:
            gun_pos.x = -4; gun_pos.y = -4;
            break;
        case 2:
            gun_pos.x = -4; gun_pos.y = -4;
            break;
        case 3:
            gun_pos.x = -4; gun_pos.y = -4;
            break;
        case 4:
            gun_pos.x = -4; gun_pos.y = -4;
            break;
        case 5:
            gun_pos.x = -4; gun_pos.y = -4;
            break;
        case 6:
            gun_pos.x = -4; gun_pos.y = -5;
            break;
        case 7:
            gun_pos.x = -4; gun_pos.y = -5;
            break;
    }
}
else if(sprite_index == _sp.idle || sprite_index == _sp.idle_lookup)
{
    ponytail_visible = 0
    switch(floor(image_index))
    {
        case 0:
            gun_pos.x = -3; gun_pos.y = -6;
            break
        case 1:
            gun_pos.x = -3; gun_pos.y = -6;
            break;
        case 2:
            gun_pos.x = -3; gun_pos.y = -6;
            break;
        case 3:
            gun_pos.x = -3; gun_pos.y = -7;
            break;
        case 4:
            gun_pos.x = -3; gun_pos.y = -7;
            break;
        case 5:
            gun_pos.x = -3; gun_pos.y = -7;
            break;
    }
}
else if(state == "wallslide")
{
    ponytail_visible = 1
    gun_pos.x = 3;
    gun_pos.y = -7;
}
else if(state == "ledgegrab")
{
    gun_behind = 0
    ponytail_visible = 1
    gun_pos.x = -4;
    gun_pos.y = 3;
}
else if(state == "ledgeclimb")
{
    gun_behind = 1
    ponytail_visible = (timer0 <= 5)
    gun_pos.x = -4;
    gun_pos.y = -5;
}
else if(duck)
{
    ponytail_visible = 0
    gun_pos.x = (-3 + (1/3 * duck));
    gun_pos.y = -5 + duck;
}
else
{
    gun_behind = 0
    ponytail_visible = 1
    gun_pos.x = -3;
    gun_pos.y = -7;
}

if(has_gun)
{
    if(gamepad)
    {
        var __aimx = gamepad_axis_value(gp_id, gp_axisrh)
        var __aimy = gamepad_axis_value(gp_id, gp_axisrv)
        var _aimx = gamepad_axis_value(gp_id, gp_axislh)
        var _aimy = gamepad_axis_value(gp_id, gp_axislv)
        aimx = (abs(__aimx) == 0 && abs(__aimy) == 0) ? _aimx : __aimx
        aimy = (abs(__aimx) == 0 && abs(__aimy) == 0) ? _aimy : __aimy

        fire_angle = point_direction(0, 0, aimx, aimy)
    }
    else
        fire_angle = point_direction(x, y - 8, mouse_x, mouse_y)

    recoil = approach(recoil, 0, 1 * global.dt)
    bombdelay = approach(bombdelay, 0, 1 * global.dt)

    if(duck)
    {
        if(fire_angle > 180 && fire_angle <= 270)
            fire_angle = 180
        if(fire_angle < 360 && fire_angle > 270)
            fire_angle = 0
    }

    if(gamepad && (abs(aimx) > 0 || abs(aimy) > 0))
    {
        gun_flip = (fire_angle <= 270 && fire_angle > 90) ? -1 : 1
        if(state == "normal")
            facing = gun_flip
    }
    else if(gamepad)
    {
        gun_flip = facing

        fire_angle = (facing > 0) ? 0 : 180
    }
    else
    {
        gun_flip = (fire_angle <= 270 && fire_angle > 90) ? -1 : 1
        if(state == "normal")
            facing = gun_flip
    }

    if(attack_state != "primary" && cool_delay == 0)
    {
        heat = approach(heat, 0, cool_rate * global.dt)
        if(heat % 8 > 8 - round(global.dt))
        {
            var dist = random_range(0.1, 1) * 12
            with(instance_create_depth(x + lengthdir_x(dist, fire_angle) + gun_pos.x * sign(facing), y - 2 + lengthdir_y(dist, fire_angle) + gun_pos.y, depth - 1, fx_dust))
            {
                vy = random_range(-1.5, -1) + other.vsp
                vx += other.hsp
            }
            audio_play_sound(sn_steam, 1, false, heat/heat_max)
        }
    }
    cool_delay = approach(cool_delay, 0, global.dt)
}
