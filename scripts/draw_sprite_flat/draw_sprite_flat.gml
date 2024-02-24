function draw_sprite_flat(_sprite, _subimg, _x, _y)
{
	shader_set(sh_flash)
	draw_sprite_ext(_sprite, _subimg, _x, _y, 1, 1, 0, draw_get_color(), draw_get_alpha())
	shader_reset()
}

function draw_sprite_flat_ext(_sprite, _subimg, _x, _y, _xscale, _yscale, _rot, _color, _alpha)
{
	shader_set(sh_flash)
	draw_sprite_ext(_sprite, _subimg, _x, _y, _xscale, _yscale, _rot, _color, _alpha)
	shader_reset()
}

function draw_sprite_outlined(spr, subimg, _x, _y, outlincol = c_white, outlinalpha = 1, square = 0)
{
	var sh = shader_current()

	#region draw outline on first surface
	var sf1 = surface_create(room_width, room_height)
	surface_set_target(sf1)
	draw_clear_alpha(c_white, 0)

	shader_set(shd_solid)
	draw_sprite_ext(spr, subimg, _x + 1, _y, 1, 1, 0, c_white, 1)
	draw_sprite_ext(spr, subimg, _x - 1, _y, 1, 1, 0, c_white, 1)
	draw_sprite_ext(spr, subimg, _x, _y + 1, 1, 1, 0, c_white, 1)
	draw_sprite_ext(spr, subimg, _x, _y - 1, 1, 1, 0, c_white, 1)
	if(square)
	{
		draw_sprite_ext(spr, subimg, _x + 1, _y + 1, 1, 1, 0, c_white, 1)
		draw_sprite_ext(spr, subimg, _x - 1, _y + 1, 1, 1, 0, c_white, 1)
		draw_sprite_ext(spr, subimg, _x + 1, _y - 1, 1, 1, 0, c_white, 1)
		draw_sprite_ext(spr, subimg, _x - 1, _y - 1, 1, 1, 0, c_white, 1)
	}
	shader_reset()

	surface_reset_target()
	#endregion

	#region draw first surface and sprite to second surface
	var sf2 = surface_create(room_width, room_height)
	surface_set_target(sf2)
	draw_clear_alpha(c_white, 0)

	draw_surface_ext(sf1, 0, 0, 1, 1, 0, outlincol, outlinalpha)

	draw_sprite_ext(spr, subimg, _x, _y, 1, 1, 0, draw_get_color(), 1)

	surface_reset_target()
	#endregion

	#region draw second surface (with shader support!)
	if(sh != -1)
		shader_set(sh)

	draw_surface_ext(sf2, 0, 0, 1, 1, 0, c_white, draw_get_alpha())

	if(sh != -1)
		shader_reset()

	surface_free(sf1)
	surface_free(sf2)
	#endregion
}

function draw_sprite_outlined_ext(spr, subimg, _x, _y, xscale = 1, yscale = 1, rot = 0, col = c_white, outlincol = c_white, alpha = 1, outlinalpha = 1, square = 0)
{
	var sh = shader_current()

	#region draw outline on first surface
	var sf1 = surface_create(room_width, room_height)
	surface_set_target(sf1)
	draw_clear_alpha(c_white, 0)

	shader_set(shd_solid)
	draw_sprite_ext(spr, subimg, _x + 1, _y, xscale, yscale, rot, c_white, 1)
	draw_sprite_ext(spr, subimg, _x - 1, _y, xscale, yscale, rot, c_white, 1)
	draw_sprite_ext(spr, subimg, _x, _y + 1, xscale, yscale, rot, c_white, 1)
	draw_sprite_ext(spr, subimg, _x, _y - 1, xscale, yscale, rot, c_white, 1)
	if(square)
	{
		draw_sprite_ext(spr, subimg, _x + 1, _y + 1, xscale, yscale, rot, c_white, 1)
		draw_sprite_ext(spr, subimg, _x - 1, _y + 1, xscale, yscale, rot, c_white, 1)
		draw_sprite_ext(spr, subimg, _x + 1, _y - 1, xscale, yscale, rot, c_white, 1)
		draw_sprite_ext(spr, subimg, _x - 1, _y - 1, xscale, yscale, rot, c_white, 1)
	}
	shader_reset()

	surface_reset_target()
	#endregion

	#region draw first surface and sprite to second surface
	var sf2 = surface_create(room_width, room_height)
	surface_set_target(sf2)
	draw_clear_alpha(c_white, 0)

	draw_surface_ext(sf1, 0, 0, 1, 1, 0, outlincol, outlinalpha)

	draw_sprite_ext(spr, subimg, _x, _y, xscale, yscale, rot, col, 1)

	surface_reset_target()
	#endregion

	#region draw second surface (with shader support!)
	if(sh != -1)
		shader_set(sh)

	draw_surface_ext(sf2, 0, 0, 1, 1, 0, c_white, alpha)

	if(sh != -1)
		shader_reset()

	surface_free(sf1)
	surface_free(sf2)
	#endregion
}
