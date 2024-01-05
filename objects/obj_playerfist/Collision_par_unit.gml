if(canHurt(self, other) && other.id != parent && !array_contains(alreadyHit, other))
{
	array_push(alreadyHit, other)

	damage_event(new DamageEventContext(parent, other, proctype.onhit, damage, 1, 1, -1, 1))

	if(instance_exists(other))
	{
		other.movex(3 * (sign(facing) * 1/(other.mass/10)))

		// if(abs(other.hsp) < 3)
		// {
		// 	other.hsp = 3 * sign(facing)
		// }
		// else
		// 	other.hsp += 1 * sign(facing)

		// other.fucked = 10
		// other.fucker = parent
	}
}
