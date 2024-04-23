

if(!instance_exists(parent))
{
	instance_destroy()
	return;
}

image_xscale = approach(image_xscale, 1, 0.5 * global.dt)
image_yscale = approach(image_yscale, 1, 0.5 * global.dt)
image_angle += 10
