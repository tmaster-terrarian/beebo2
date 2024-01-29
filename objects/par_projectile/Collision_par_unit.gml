if(canHurt(self, other) && other.id != parent && (!mustHitTarget || (mustHitTarget && other.id == target)))
{
	if(context == noone)
		damage_event(new DamageEventContext(parent, other, proctype.onhit, damage, proc).forceCrit(crit))
	else
		damage_event(context)

	if(destroy_on_hit)
		instance_destroy()
}
