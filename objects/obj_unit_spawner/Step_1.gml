image_index += 0.5 * global.dt

yOffset += (0 - yOffset) * 0.125

spawntimer = approach(spawntimer, 0, global.dt)

if(spawntimer == 0)
	event_perform(ev_alarm, 0)
