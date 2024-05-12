if(object_get_parent(other.object_index) == obj_player)
{
	if(item_id != "")
	{
		item_add_stacks(item_id, other, stacks, true)
		other.flash = 3
	}
	instance_destroy()
}
