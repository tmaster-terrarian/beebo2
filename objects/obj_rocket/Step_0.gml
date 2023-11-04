PAUSECHECK

if(timer < 60 * 0.2)
{
    spd = approach(spd, 2, 1/(60 * 0.2) * global.dt)
}
else
{
    spd = approach(spd, 20, 0.1 * global.dt)
    turnspd = approach(turnspd, 1, 0.15 * global.dt)

    if(instance_exists(target))
    {
        angle = angleRotate(angle, point_direction(x, y, target.x, target.y), turnspd * global.dt);
    }
    else
    {
        angle = angleRotate(angle, angle + 20, turnspd * global.dt);
    }
}

hsp = lengthdir_x(spd, angle)
vsp = lengthdir_y(spd, angle)

image_angle = round(angle / 8) * 8

timer += global.dt

if(timer % (8 / spd + 4) <= 1)
{
    with(instance_create_depth(x + lengthdir_x(-4, image_angle), y + lengthdir_y(-4, image_angle), depth + 2, fx_steam))
    {
        vy = random_range(0.1, 0.5)
    }
}
