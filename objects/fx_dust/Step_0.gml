event_inherited()
PAUSECHECK

vx = approach(vx, 0, fric * global.dt)
vy = approach(vy, 0, fric * global.dt)
vz = approach(vz, 0, fric * global.dt)
image_xscale = approach(image_xscale, 0, 0.025 * global.dt)
image_yscale = approach(image_yscale, 0, 0.025 * global.dt)
life -= 0.099 * global.dt
if (life <= 0) || (image_xscale == 0 && image_yscale == 0)
    instance_destroy()
