if(object_get_parent(other.object_index) == obj_player)
{
	item_add_stacks(item_id, other, stacks, true)
	instance_destroy()
}
