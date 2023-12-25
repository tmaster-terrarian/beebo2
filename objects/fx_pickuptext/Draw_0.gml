var txt = scribble("[fnt_basic][d#" + string(global.itemdata.rarity_colors[getdef(item_id, deftype.item).rarity]) + "]" + name + "[/color]\n[fnt_itemdesc][c_ltgray]" + shortdesc + "[/color]")
.starting_format("fnt_itemdesc", c_ltgray)
.blend(c_white, image_alpha)
.wrap(168)

draw_set_alpha(0.5)
draw_rectangle_color(x - 94, y + 51, x + 94, y + 51 + txt.get_height(), c_black, c_black, c_black, c_black, false)
draw_set_alpha(1)

txt.flash(c_black, 1).draw(x - 71, y + 51)
txt.flash(c_black, 0).draw(x - 72, y + 50)

var _spr = asset_get_index("spr_item_" + item_id)
draw_sprite_outlined_ext((_spr != -1) ? _spr : spr_buff_missing, 0, x - 84, y + 62, 1, 1, 0, c_white, (_spr != -1) ? global.itemdata.rarity_colors[getdef(item_id, deftype.item).rarity] : global.itemdata.rarity_colors[0], image_alpha, image_alpha, 0)
