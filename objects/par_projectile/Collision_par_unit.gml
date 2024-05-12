if(canHurt(self, other) && other.id != parent.id && (!mustHitTarget || (mustHitTarget && other.id == target)))
{
	if(context == noone)
		DamageEvent(new DamageEventContext(parent, other, damage, proc).forceCrit(crit))
	else
		DamageEvent(context)

	if(destroy_on_hit)
		instance_destroy()
}
