if(canHurt(self, other) && other != parent && (!mustHitTarget || (mustHitTarget && instance_exists(target) && other.id == target.id)))
{
	if(context == noone)
		DamageEvent(new DamageEventContext(parent, other, damage, proc).forceCrit(crit))
	else
		DamageEvent(context)

	if(destroy_on_hit)
		instance_destroy()
}
