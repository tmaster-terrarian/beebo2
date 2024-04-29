event_inherited()

if(instance_exists(target))
{
    hsp = approach(hsp, lengthdir_x(spd, point_direction(x, y, target.x, target.y - 16)), air_accel)
    vsp = approach(vsp, lengthdir_y(spd, point_direction(x, y, target.x, target.y - 16)), air_accel)
}

if(!instance_exists(target) || sqrt(sqr(hsp) + sqr(vsp)) > spd)
{
    hsp = approach(hsp, 0, air_fric)
    vsp = approach(vsp, 0, air_fric)
}

ghost = 1
