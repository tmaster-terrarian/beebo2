PAUSECHECK

vx = approach(vx, 0, 0.01 * global.dt)
vy = approach(vy, 0, 0.01 * global.dt)

life -= global.dt
if(life < 0)
	instance_destroy()
