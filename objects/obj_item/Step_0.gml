t += global.dt
if(!on_ground)
{
	vsp = approach(vsp, 20, grv * global.dt)
}
