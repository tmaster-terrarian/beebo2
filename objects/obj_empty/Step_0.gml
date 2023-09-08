PAUSECHECK
if(killtimer > 0)
	killtimer = approach(killtimer, 0, global.dt)
if(killtimer == 0)
	instance_destroy()
