if(team != other.team)
{
	damage_event(parent, other, proctype.onhit, damage, proc)

	if(destroy_on_hit)
		instance_destroy()
}
