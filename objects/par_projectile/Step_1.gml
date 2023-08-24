if(max_instances && instance_number(object_index) > max_instances)
{
	proc = 0
	damage = 0
	instance_destroy()
}

if(lifetime)
	lifetime--
if(lifetime == 0)
{
	instance_destroy()
}

rx += lengthdir_x(_speed * global.dt, direction)
ry += lengthdir_y(_speed * global.dt, direction)
var mx = round(rx)
var my = round(ry)
rx -= mx
ry -= my

repeat(abs(mx))
{
	if(!place_meeting(x + sign(mx), y, par_solid))
	{
		x += sign(mx)
		continue
	}
	else
		event_perform(ev_collision, par_solid)
	break
}
repeat(abs(my))
{
	if(!place_meeting(x, y + sign(my), par_solid))
	{
		y += sign(my)
		continue
	}
	else
		event_perform(ev_collision, par_solid)
	break
}
