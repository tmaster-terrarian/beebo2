if(lastcheck != place_meeting(x, y, objecttarget))
{
	if(trigger_once && !triggered)
	{
		triggered = 1
		event_perform(ev_other, ev_user0)
	}
	else
	{
		event_perform(ev_other, ev_user0)
	}
}
