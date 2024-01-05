event_inherited()
depth = 60
image_speed = 0
grv = 0.2
t = 0
flash = 0

var spr = asset_get_index("spr_item_" + item_id)
if(spr != -1)
	sprite_index = spr
else
	item_id = "unknown"
