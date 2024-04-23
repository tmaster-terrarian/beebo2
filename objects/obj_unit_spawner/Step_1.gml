

spawntimer = approach(spawntimer, 0, global.dt)

if(spawntimer == 0)
	event_perform(ev_alarm, 0)
