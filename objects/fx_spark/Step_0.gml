vsp += grv * global.dt

if(place_meeting(x + hsp, y, par_solid) || (place_meeting(x + hsp, y, par_moveable) && !place_meeting(x, y, par_moveable) && collide))
{
    if(bounces < bounce_max)
    {
        bounces++
        hsp = -hsp * 0.8
    }
    else
        instance_destroy()
}
x += hsp * global.dt

if(place_meeting(x, y + vsp, par_solid) || (place_meeting(x, y + vsp, par_moveable) && !place_meeting(x, y, par_moveable) && collide))
{
    if(bounces < bounce_max)
    {
        bounces++
        vsp = -vsp * 0.5
    }
    else
        instance_destroy()
}
y += vsp * global.dt

image_angle = point_direction(0, 0, hsp, vsp)
image_xscale = ceil(point_distance(0, 0, hsp, vsp)) + 2
