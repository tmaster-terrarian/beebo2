

if(life <= 0)
	instance_destroy()

life = approach(life, 0, image_speed * global.dt)

image_alpha = 1 - image_index/4

vx = approach(vx, 0, 0.05 * global.dt)
vy = approach(vy, 0, 0.05 * global.dt)

x += vx * global.dt
y += vy * global.dt
