if(fucked && other.team == team)
{
	flash = 4
	if(!other.fucked)
	{
		other.fucked += 10
		other.fucker = fucker
		other.hsp = hsp
		other.hp -= (bbox_right - bbox_left) * 0.75 // ouch
		audio_play_sound(sn_heavyHit, 0, false)
		screen_shake_set(8, 20)
		hsp *= -1
		vsp = -1.5
		other.vsp = vsp
	}
	else
	{
		audio_play_sound(sn_heavyHit, 1, false)
		audio_play_sound(sn_bomb_explosion, 0, false)
		screen_shake_set(10, 30)
		with(instance_create_depth(x, y, depth - 1, obj_empty, {_size: 1.5, _dmg: (bbox_right - bbox_left) / 2, _fps: 0.5, proc: 1, parent: fucker, team: Team.player, killtimer: 16 / 0.5}))
		{
		    sprite_index = spr_fx_explosion
		    image_speed = _fps
		    image_xscale = _size
		    image_yscale = _size

		    crit = 1

		    with(par_unit)
		    {
		        if(place_meeting(x, y, other) && team != other.team)
		        {
		            damage_event(new DamageEventContext(other.parent, id, proctype.onhit, other._dmg * (1 + other.crit * 0.5), other.proc, 1, 1))
		        }
		    }
		}
		hsp *= -1
		vsp = -1.5
	}
}
