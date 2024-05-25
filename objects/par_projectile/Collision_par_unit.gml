if(canHurt(self, other))
{
	if(mustHitTarget && (instance_exists(target) ? other.id != target.id : true)) exit;
	if(instance_exists(parent) && other.id == parent.id) exit;

	if(context == noone)
		DamageEvent(new DamageEventContext(parent, other, damage, proc).forceCrit(crit))
	else
		DamageEvent(context)

	if(destroy_on_hit)
		instance_destroy()
}
