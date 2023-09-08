if(global.pause)
    return;

if(hp <= 0) && !ded
{
    ded = 1
    instance_destroy()
}

if(y > room_height + 48)
    hp = 0

if(!on_ground)
    vsp = approach(vsp, 20, grv)
