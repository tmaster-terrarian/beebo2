event_inherited();
PAUSECHECK

lifetime = approach(lifetime, 0, global.dt)
if(lifetime == 0)
	instance_destroy()
