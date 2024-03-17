var xx = x
var yy = y
_image_xscale = sign(_image_xscale)

if(instance_exists(target))
{
	array_push(positions, _pos(
		target.x,
		target.y,
		target.sprite_index,
		target.image_index,
		target.mask_index,
		(target.input_dir != 0 ? target.input_dir : _image_xscale) * target.stretch,
		target.image_yscale * target.squash,
		target.image_angle
	))

	var pos = array_shift(positions)

	x = pos.x
	y = pos.y
	sprite_index = pos.sprite_index
	switch(pos.sprite_index)
	{
		case spr_player: sprite_index = spr_anime; break;
		case spr_player_lookup: sprite_index = spr_anime_lookup; break;
		case spr_player_crawl: sprite_index = spr_anime_crawl; break;
		case spr_player_duck: sprite_index = spr_anime_duck; break;
		case spr_player_dead: sprite_index = spr_anime_dead; break;
		case spr_player_jump: sprite_index = spr_anime_jump; break;
		case spr_player_run: sprite_index = spr_anime_run; break;
		case spr_player_run_fast: break;
		case spr_player_wallslide: sprite_index = spr_anime_wallslide; break;
		case spr_player_ledgegrab: sprite_index = spr_anime_ledgegrab; break;
		case spr_player_ledgeclimb: sprite_index = spr_anime_ledgeclimb; break;
		case spr_player_ghost: sprite_index = spr_anime_ghost; break;
	}

	image_index = pos.image_index
	mask_index = pos.mask_index
	_image_xscale = pos.xscale
	image_xscale = pos.xscale
	image_yscale = pos.yscale
	image_angle = pos.angle
}

ghost = 1
hsp = 0
vsp = 0

event_inherited();

ghost = 0
hsp = x - xx
vsp = y - yy
