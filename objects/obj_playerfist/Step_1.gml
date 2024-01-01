event_inherited();

if(instance_exists(parent))
{
	x = parent.x + parent.hsp
	y = parent.y + parent.vsp + parent.duck
}

if(!swung)
{
	parent.movex(1 * sign(facing))
	image_xscale = facing
	
	var e = instance_place(x + 4 * facing, y, par_unit)
	if e
	{
		if e.team != team
		{
			var s = choose(sn_punch_1, sn_punch_2)
			audio_play_sound(s, 1, 0)
		}
	}
}

swung = 1
