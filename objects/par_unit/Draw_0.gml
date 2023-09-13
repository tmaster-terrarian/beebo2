if(flash > 0)
	shader_set(sh_flash)

draw_self()

if(shader_current() != -1)
	shader_reset()
