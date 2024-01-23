if(touched && image_alpha > 0)
{
	image_alpha = approach(image_alpha, 0, 0.05 * global.dt)
}
if(image_alpha <= 0.85)
{
	var u = instance_place(x, y - 1, fx_revealer), 
		d = instance_place(x, y + 1, fx_revealer),
		l = instance_place(x - 1, y, fx_revealer),
		r = instance_place(x + 1, y, fx_revealer)

	if(u)
		u.touched = 1
	if(d)
		d.touched = 1
	if(l)
		l.touched = 1
	if(r)
		r.touched = 1
}
if(image_alpha <= 0)
{
	if(!persist)
		instance_destroy()
}
