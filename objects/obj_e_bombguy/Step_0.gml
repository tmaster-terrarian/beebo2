event_inherited();


if(instance_exists(target))
{
    if(state == "normal")
        input_dir = sign(target.x - x)
    else
        input_dir = 0

    if(abs(target.x - x) < 64)
    {
        INPUT.FIRE = 1
    }
}

if(INPUT.FIRE && firedelay <= 0)
{
    firedelay = firerate
    state = "attack"
    timer0 = 0
}

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

if(place_meeting(x + input_dir * 12, y, par_solid) && state != "attack")
    INPUT.JUMP = 1

if(INPUT.JUMP && can_jump)
{
    // state = "normal"
    // image_index = 0
    // sprite_index = jump
    var c = collision_point(x, y + 2, par_solid, 1, 1)
    if c
    {
        lasthsp = c.hsp
        lastvsp = c.vsp
        hsp += c.hsp
        if(c.vsp < 0)
            vsp = c.vsp
    }
    vsp = jumpspd
    // s = audio_play_sound(sn_jump, 0, false)
}

if(input_dir != 0)
    facing = input_dir

INPUT.JUMP = 0
INPUT.FIRE = 0
