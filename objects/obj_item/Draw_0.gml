draw_sprite_flat_ext(
    sprite_index, 0,
    x + lengthdir_x(2, t*2),
    y + lengthdir_y(2, t*2) + round(sin(t / 40) * 2 - 2),
    1, 1,
    0,
    global.itemdata.rarity_colors[getdef(item_id, deftype.item).rarity],
    sin(t / 30) * 0.25 + 0.5
)
draw_sprite_flat_ext(
    sprite_index, 0,
    x + lengthdir_x(-2, t*2),
    y + lengthdir_y(-2, t*2) + round(sin(t / 40) * 2 - 2),
    1, 1,
    0,
    global.itemdata.rarity_colors[getdef(item_id, deftype.item).rarity],
    sin(t / 30) * 0.25 + 0.5
)

if(flash)
	shader_set(sh_flash)

draw_sprite(sprite_index, 0, x, y + round(sin(t / 40) * 2 - 2))

if(flash)
	shader_reset()
