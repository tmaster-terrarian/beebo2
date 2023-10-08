event_inherited();

ponytail_visible = 1
gun_behind = 0
if(running)
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

if(has_gun && !global.pause)
{
    fire_angle = point_direction(x, y - 8, mouse_x, mouse_y);
    fire_angle = round(fire_angle / 10) * 10;

    recoil = approach(recoil, 0, 1 * global.dt)
    firedelay = approach(firedelay, 0, 1 * global.dt)
    bombdelay = approach(bombdelay, 0, 1 * global.dt)

    if(duck)
    {
        if(fire_angle > 180 && fire_angle <= 270)
            fire_angle = 180
        if(fire_angle < 360 && fire_angle > 270)
            fire_angle = 0
    }

    gun_flip = (fire_angle <= 270 && fire_angle > 90) ? -1 : 1

    if(state == "normal")
        facing = gun_flip

    if(mouse_check_button(mb_left) && firedelay <= 0)
    {
        firing = 1;

        screen_shake_set(1, 5)

        recoil = 2;
        firedelay = firerate;

        if(gun_upgrade != "")
            getdef(gun_upgrade, 3).fire(id)
        else
            getdef("base", 3).fire(id)
    }

    if(mouse_check_button(mb_right) && bombdelay <= 0)
    {
        audio_play_sound(sn_throw, 0, 0)

        firing = 1;

        screen_shake_set(2, 10)

        recoil = 4;
        bombdelay = bombrate;

        if(gun_upgrade != "")
            getdef(gun_upgrade, 3).fire_bomb(id)
        else
            getdef("base", 3).fire_bomb(id)
    }
}
