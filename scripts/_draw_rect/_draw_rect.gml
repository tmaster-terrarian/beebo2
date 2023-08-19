function _draw_rect(x1, y1, x2, y2, _c = c_white, _a = 1, _o = 0)
{
	_o = clamp(floor(_o), 0, 1)
	var __c = draw_get_color()
	var __a = draw_get_alpha()

	draw_set_color(_c)
	draw_set_alpha(_a)

	draw_rectangle(x1 + _o, y1 + _o, x2 - _o, y2 - _o, _o)

	draw_set_color(__c)
	draw_set_alpha(__a)
}

function _draw_line(x1, y1, x2, y2, _w, _c = c_white, _a = 1)
{
	var __a = draw_get_alpha()
	draw_set_alpha(_a)

	draw_line_width_color(x1, y1, x2, y2, _w, _c, _c)

	draw_set_alpha(__a)
}
