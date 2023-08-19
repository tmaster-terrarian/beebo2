function _d_colcheck(_x, _y, _w, _h, _v) constructor
{
	x = _x
	y = _y
	w = _w
	h = _h
	value = _v
}

function _place_meeting(_x, _y, _obj)
{
	var result = place_meeting(_x, _y, _obj)
	if(global.draw_debug)
		array_push(collision_checks, new _d_colcheck(_x - (sprite_get_xoffset(mask_index) - sprite_get_bbox_left(mask_index)), _y - (sprite_get_yoffset(mask_index) - sprite_get_bbox_top(mask_index)), sprite_get_bbox_right(mask_index) - sprite_get_bbox_left(mask_index), sprite_get_bbox_bottom(mask_index) - sprite_get_bbox_top(mask_index), result))
	return result
}
function _instance_place(_x, _y, _obj)
{
	var result = _instance_place(_x, _y, _obj)
	if(global.draw_debug)
		array_push(collision_checks, new _d_colcheck(_x - (sprite_get_xoffset(mask_index) - sprite_get_bbox_left(mask_index)), _y - (sprite_get_yoffset(mask_index) - sprite_get_bbox_top(mask_index)), sprite_get_bbox_right(mask_index) - sprite_get_bbox_left(mask_index), sprite_get_bbox_bottom(mask_index) - sprite_get_bbox_top(mask_index), (result != noone)))
	return result
}

function _position_meeting(_x, _y, _obj)
{
	var result = position_meeting(_x, _y, _obj)
	if(global.draw_debug)
		array_push(collision_checks, new _d_colcheck(_x - 1, _y - 1, 1, 1, result))
	return result
}

enum checkType
{
	any,
	all,
	none
}

function compound_meeting(checks = [], _type = checkType.any)
{
	if(array_length(checks) == 0)
		return

	var result = 0

	switch(_type)
	{
		case 0:
		{
			var sum = 0
			for(var i = 0; i < array_length(checks); i++)
			{
				sum += checks[i]
			}
			result =  (sum != 0)
			break;
		}
		case 1:
		{
			var sum = 1
			for(var i = 0; i < array_length(checks); i++)
			{
				sum *= checks[i]
				if(checks[i] == 0)
					break
			}
			result = (sum != 0)
			break;
		}
		case 2:
		{
			var sum = 0
			for(var i = 0; i < array_length(checks); i++)
			{
				sum += checks[i]
			}
			result = (sum == 0)
			break;
		}
	}
}
