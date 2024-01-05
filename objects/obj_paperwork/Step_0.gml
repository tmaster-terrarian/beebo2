sp = ceil(4 * (pmax/64))

if(dir > 90 && dir < 270)
{
    flip = -1
}
else
{
    flip = 1
}

if(p < pmax / 2)
{
    p += sp * global.dt

    var _h = -(h / (0.25 * sqr(pmax)) * flip) * p * (p - pmax)
    var _h2 = -(h / (0.25 * sqr(pmax)) * flip) * (p + sp * global.dt) * ((p + sp * global.dt) - pmax)

    x = xstart + lengthdir_x(p, dir) + lengthdir_x(_h, dir + 90)
    y = ystart + lengthdir_y(p, dir) + lengthdir_y(_h, dir + 90)

    image_angle = point_direction(x, y, xstart + lengthdir_x(p + sp * global.dt, dir) + lengthdir_x(_h2, dir + 90), ystart + lengthdir_y(p + sp * global.dt, dir) + lengthdir_y(_h2, dir + 90))
}
else
{
    if(instance_exists(target))
    {
		var ty = (target.bbox_bottom + target.bbox_top) / 2
        x += (target.x - x) * 0.25 * global.dt
        y += (ty - y) * 0.25 * global.dt
    }
    else instance_destroy()
}
