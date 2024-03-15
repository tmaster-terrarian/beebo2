if(has_gun)
{
    if(input.secondaryPressed() && instance_exists(bomb) && skills.secondary.cooldown > 0)
    {
        bomb.bulleted = 1
        setTimeout(function() {instance_destroy(bomb)}, 0.1)
    }
}

event_inherited();

ponytail_visible = 1
gun_behind = 0
if(sprite_index == _sp.idle || sprite_index == _sp.idle_lookup)
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
else if(sprite_index == _sp.run)
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
else if(sprite_index == _sp.run_fast)
{
    ponytail_visible = 1
    switch(floor(image_index))
    {
        case 0:
            gun_pos.x = -3; gun_pos.y = -6;
            break;
        case 1:
            gun_pos.x = -2; gun_pos.y = -5;
            break;
        case 2:
            gun_pos.x = -1; gun_pos.y = -6;
            break;
        case 3:
            gun_pos.x = -0; gun_pos.y = -6;
            break;
        case 4:
            gun_pos.x = -0; gun_pos.y = -5;
            break;
        case 5:
            gun_pos.x = -1; gun_pos.y = -6;
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

if(ded)
{
    ponytail_visible = 0
    has_gun = 0
    draw_gun = 0
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

        var len = sqrt(aimx * aimx + aimy * aimy)
        aimx /= (len > 0) ? len : 1.0
        aimy /= (len > 0) ? len : 1.0

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
            audio_play_sound(sn_steam, 1, 0, heat/heat_max)
        }
    }
    cool_delay = approach(cool_delay, 0, global.dt)

    if (gun_spr == spr_player_gun_reload)
    {
        var _skill = attack_states[$ "primary"]
        if(cool_delay - 20 < _skill.duration)
        {
            if(gun_spr_ind < 1)
            {
                gun_spr_ind = approach(gun_spr_ind, 1, 0.2 * global.dt)
                if(gun_spr_ind == 1)
                    audio_play_sound(sn_gun_open, 1, 0)
            }
            else if(gun_spr_ind < 2)
            {
                gun_spr_ind = approach(gun_spr_ind, 2, 0.2 * global.dt)
                if(gun_spr_ind == 2)
                {
                    audio_play_sound(sn_steam, 1, 0)
                    for (i = 0; i < 3; i++)
                    { 
                        with(instance_create_depth(x + gun_pos.x + random_range(-1, 1), y + gun_pos.y + random_range(-1, 1), depth - 1, fx_dust))
                        {
                            vy = random_range(-1.5, -0.75)
                            vx = random_range(1.5, 2) * other.gun_flip + other.hsp
                        }
                    }
                }
            }
            else if(gun_spr_ind < 5)
            {
                gun_spr_ind = approach(gun_spr_ind, 5, 0.2 * global.dt)
                if(gun_spr_ind == 5)
                {
                    if(firebomb)
                    {
                        firebomb = 0
                        gun_spr = spr_player_gun
                        gun_spr_ind = 0
                    }
                    else audio_play_sound(snReload, 0, 0)
                }
            }
            else
                gun_spr_ind = approach(gun_spr_ind, 10, 0.2 * global.dt)
            if(gun_spr_ind == 10)
            {
                gun_spr = spr_player_gun
                gun_spr_ind = 0
            }
        }
    }
}
