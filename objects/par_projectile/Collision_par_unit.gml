if(team != other.team && other.id != parent)
{
	damage_event(new DamageEventContext(parent, other, proctype.onhit, damage, proc))

	if(destroy_on_hit)
		instance_destroy()
}
