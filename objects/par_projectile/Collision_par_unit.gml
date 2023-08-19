if(_team != other._team)
{
	damage_event(parent, other, proctype.onhit, damage, proc)
    
	instance_destroy()
}
