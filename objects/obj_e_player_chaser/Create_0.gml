event_inherited()
grv = 0

target = noone
depth = -10
image_speed = 0
_image_xscale = -1000

_pos = function(_x, _y, _sprite_index, _image_index, _mask_index, xscale, yscale, angle)
{
	return {x:_x, y:_y, sprite_index:_sprite_index, image_index:_image_index, mask_index:_mask_index, xscale, yscale, angle}
}

positions = array_create(delay, _pos(x, y, sprite_index, image_index, mask_index, image_xscale, image_yscale, image_angle))
