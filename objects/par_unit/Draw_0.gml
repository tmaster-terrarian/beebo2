if(elite)
{
	shader_set(sh_flash)
	draw_set_alpha(0.5)
	var ib = image_blend
	var _x = x
	var _y = y
	var ox = cos(2 * (get_timer() / 1000000) * pi) + 1

	image_blend = c_red

	x = _x + ox
	draw_self()
	x = _x - ox
	draw_self()

	y = _y - 1
	draw_self()
	y = _y + 1
	draw_self()

	shader_reset()
	draw_set_alpha(1)
	image_blend = ib
	x = _x
	y = _y
}

if(flash > 0)
	shader_set(sh_flash)

draw_self()

if(flash > 0)
	shader_reset()

var w = ceil(clamp(hp_max * 0.2, 24, 56))

if(drawhp) && (hp > 0) && team == Team.enemy
{
    var c = c_black
    // var avgx = (bbox_left + bbox_right) / 2
    var avgx = x

	if(elite)
    	draw_rectangle_color(avgx - floor(w/2) - 2, bbox_top - 5, avgx + ceil(w/2) + 1, bbox_top - 13, c,c,c,c,false)

    c = (elite ? c_white : c_black)
    draw_rectangle_color(avgx - floor(w/2) - 1, bbox_top - 6, avgx + ceil(w/2), bbox_top - 12, c,c,c,c,false)

    draw_sprite_ext(spr_enemyhpbar, 0, avgx - floor(w/2), bbox_top - 10, w, 1, 0, c_white, 1)

    draw_sprite_ext(spr_enemyhpbar, 3, avgx - floor(w/2), bbox_top - 10, ceil((hp_change / total_hp_max) * w), 1, 0, c_white, 1)
    draw_sprite_ext(spr_enemyhpbar, 1, avgx - floor(w/2), bbox_top - 10, ceil((hp / total_hp_max) * w), 1, 0, c_white, 1)
    draw_sprite_ext(spr_enemyhpbar, 4, avgx - floor(w/2) + ceil((hp / total_hp_max) * w), bbox_top - 10, ceil(((shield / max_shield) * max_shield / total_hp_max) * w), 1, 0, c_white, 1)
    if(ceil(hp_change) < ceil(hp))
    {
        draw_sprite_ext(spr_enemyhpbar, 2, avgx - floor(w/2) + ceil((hp / total_hp_max) * w), bbox_top - 10, ceil(-(hp - hp_change)), 1, 0, c_white, 1)
    }
}

var buffoffsi = 0
if(hp > 0) && team == Team.enemy
for(var i = 0; i < array_length(buffs); i++)
{
	var buff = buffs[i]
    var buffsx = x - w/2 + 5
    var buffsy = bbox_top - 18
    if(buff.stacks > 0)
    {
        var spr = asset_get_index("spr_buff_" + buff.buff_id)
        draw_sprite((spr != -1) ? spr : spr_buff_missing, 0, buffsx + (10 * (i + buffoffsi)), buffsy)
        if(buff.stacks > 1)
        {
            draw_set_font(fnt_itemdesc); draw_set_halign(fa_right); draw_set_valign(fa_bottom)
            draw_text(buffsx + 1 + (10 * (i + buffoffsi)), buffsy + 1, string(buff.stacks))
        }
    }
    else buffoffsi--
}
