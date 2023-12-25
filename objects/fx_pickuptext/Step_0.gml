if(t <= 4)
{
	image_alpha = t/4
	yoff = (1 - (t/4)) * 2
}
else if(t < 16)
{
	image_alpha = 1
	yoff = 0
}
if(t > 300)
{
	image_alpha -= 0.2 * global.dt
	if(image_alpha <= 0)
		instance_destroy()
}
t += global.dt
