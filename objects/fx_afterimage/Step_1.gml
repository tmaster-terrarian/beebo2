

life = approach(life, 0, global.dt)
image_alpha = alpha_orig * life / maxlife

if(life <= 0)
	instance_destroy()
