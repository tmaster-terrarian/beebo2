t += global.dt
flash = approach(flash, 0, global.dt)
if(!on_ground)
{
	vsp = approach(vsp, 20, grv * global.dt)
}
else if(flash == -1)
{
	flash = 3
}
