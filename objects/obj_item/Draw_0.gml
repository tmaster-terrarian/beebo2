draw_sprite_flat_ext(
    _sprite_index, 0,
    x + lengthdir_x(2, t*2),
    y + lengthdir_y(2, t*2) + round(sin(t / 40) * 2 - 2),
    1, 1,
    0,
    global.enumColors.rarity_colors[getdef(item_id, DefType.item).rarity],
    sin(t / 30) * 0.25 + 0.5
)
draw_sprite_flat_ext(
    _sprite_index, 0,
    x + lengthdir_x(-2, t*2),
    y + lengthdir_y(-2, t*2) + round(sin(t / 40) * 2 - 2),
    1, 1,
    0,
    global.enumColors.rarity_colors[getdef(item_id, DefType.item).rarity],
    sin(t / 30) * 0.25 + 0.5
)

if(flash)
	shader_set(sh_flash)

draw_sprite(_sprite_index, 0, x, y + round(sin(t / 40) * 2 - 2))

if(flash)
	shader_reset()
