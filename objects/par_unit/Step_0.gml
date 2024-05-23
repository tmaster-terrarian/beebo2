if(fucked > 0)
	fucked = approach(fucked, 0, global.dt / 6)
else
	fucker = noone

if(y > room_height + 48)
    hp = 0

if(!on_ground)
    vsp = approach(vsp, 20, grv * global.dt)

if(hp <= 0) && !ded
{
    ded = 1
    instance_destroy()
}
