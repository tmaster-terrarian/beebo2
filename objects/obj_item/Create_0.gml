event_inherited()
depth = 60
image_speed = 0
grv = 0.2
t = 0
flash = 0

var spr = asset_get_index("spr_item_" + item_id)
if(spr != -1)
	sprite_index = spr

if(!variable_struct_exists(global.itemdefs, item_id))
{
	item_id = "unknown"
	Log("Main/WARN", "Item object " + self + " created with invalid item id, reverted to unknown.")
}
