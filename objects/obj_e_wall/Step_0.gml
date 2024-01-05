with(walled)
    other.on_ground = (place_meeting(x, y + 1, par_solid) && !instance_place(x, y + 1, par_solid).ghost && !instance_place(x, y + 1, par_solid).nocollide)
event_inherited()

if(on_ground)
{
    accel = ground_accel
    fric = ground_fric
}
else
{
    accel = air_accel
    fric = air_fric
}

states[$ state]()

if(input_dir != 0)
    facing = input_dir

with(walled)
{
    image_xscale = other.image_xscale
    image_yscale = other.image_yscale
}
