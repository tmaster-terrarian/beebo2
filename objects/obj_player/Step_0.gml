if(sprite_index == spr_player || sprite_index == spr_player_lookup)
    image_index += 0.2 * global.dt

running = (sprite_index == spr_player_run) || (sprite_index == spr_player_run_rev)

if(state != "ledgeclimb")
    ledgegrabTimer = approach(ledgegrabTimer, 0, 1 * global.dt)

input_dir = 0
input_dir = sign
(
    gamepad_axis_value(0, gp_axislh)
    + (gamepad_button_check(0, gp_padr) - gamepad_button_check(0, gp_padl))
    + (keyboard_check(ord("D")) - keyboard_check(ord("A")))
) * hascontrol

if(on_ground && state != "ledgegrab")
{
    platformtarget = instance_place((bbox_left + bbox_right)/2, bbox_bottom + 2, par_solid)
}
else if(_place_meeting(x + 2 * input_dir, y, par_solid) && state == "wallslide")
{
    platformtarget = instance_place(x + 2 * input_dir, y, par_solid)
}
else if(jump_buffer < 10 && state != "ledgegrab")
{
    platformtarget = noone
}

if(place_meeting(x, y, par_solid) && !ghost) y -= 1 * global.dt;

if(!on_ground)
    duck = 0
if(duck)
{
    spd *= 0.5
    if(abs(hsp) > spd)
        hsp = approach(hsp, spd * input_dir, 0.25 * global.dt)
}

if(on_ground)
{
    accel = ground_accel;
    fric = ground_fric;
}
else
{
    accel = air_accel;
    fric = air_fric;
    if(abs(hsp) > spd * 1.3)
        fric *= 0.1
}

states[$ state]()

if (keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1)) && can_jump
{
    if(on_ground) || (jump_buffer && vsp > 0) || (jumps - 1 && state != "ledgegrab")
    {
        platformtarget = noone
        var s = noone
        if(!duck)
        {
            state = "normal"
            image_index = 0
            sprite_index = _sp.jump
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
            s = audio_play_sound(sn_jump, 0, false)
        }
        else
        {
            state = "normal"
            c = collision_point(x, y + 2, par_solid, 1, 1)
            if c
            {
                lasthsp = c.hsp
                lastvsp = c.vsp
                hsp += c.hsp
                if(c.vsp < 0)
                    vsp = c.vsp
            }
            vsp += jumpspd / 2
            s = audio_play_sound(sn_jump, 0, false)
        }

        if(!on_ground)
        {
            if _place_meeting(x + spd, y, par_solid) && can_walljump
            {
                state = "normal"
                hsp = -spd
                vsp = jumpspd
                facing = -1
                audio_stop_sound(s)
                audio_play_sound(sn_walljump, 0, false)
            }
            else if _place_meeting(x - spd, y, par_solid) && can_walljump
            {
                state = "normal"
                hsp = spd
                vsp = jumpspd
                facing = 1
                audio_stop_sound(s)
                audio_play_sound(sn_walljump, 0, false)
            }
            else if(jump_buffer)
            {
                for (var i = 0; i < 4; i++)
                {
                    with (instance_create_depth((bbox_left + random(8)), random_range(bbox_bottom, bbox_bottom), (depth - 1), fx_dust))
                    {
                        sprite_index = spr_fx_dust2
                        vx = random_range(-0.5, 0.5)
                        vz = random_range(-0.2, 0)
                    }
                }
            }
            else if jumps
            {
                for (var i = 0; i < 4; i++)
                {
                    with (instance_create_depth((bbox_left + random(8)), random_range(bbox_bottom, bbox_bottom), (depth - 1), fx_dust))
                    {
                        sprite_index = spr_fx_dust2
                        vx = random_range(-0.5, 0.5)
                        vz = random_range(-0.2, 0)
                    }
                }
                jumps--
                state = "normal"
                image_index = 0
                sprite_index = _sp.jump
                vsp = jumpspd
                audio_stop_sound(s)
                audio_play_sound(sn_walljump, 0, false)
            }
        }
    }
    else if(state == "ledgegrab" || state == "ledgeclimb")
    {
        ledgegrabTimer = 15
        ghost = 0
        var c = platformtarget
        if c
        {
            lasthsp = c.hsp
            lastvsp = c.vsp
            hsp = c.hsp
            if(c.vsp < 0)
                vsp = c.vsp
        }

        mask_index = _sp.m_default
        timer0 = 0

        if(abs(input_dir)) // if input then jump off with some horizontal speed
        {
            hsp += spd * 0.8 * input_dir + (0.4 * -facing)

            if(!_place_meeting(x, (c) ? c.bbox_top : y, par_solid)) // if theres space jump as normal
                vsp -= 2.7
            else // else displace the player first
            {
                if(state == "ledgegrab")
                    x -= 4 * facing
                y += 12
                vsp -= 2.7
                sprite_index = _sp.jump
                image_index = 0
            }
		    audio_play_sound(sn_walljump, 0, false)
        }
        else // otherwise just hop off
        {
            if(state == "ledgegrab")
                x -= 4 * facing
            y += 12
            vsp -= 2.7
            sprite_index = _sp.jump
            image_index = 0
		    audio_play_sound(sn_walljump, 0, false)
        }
        state = "normal"
    }
    else if(can_walljump)
    {
        if _place_meeting(x + spd, y, par_solid)
        {
            platformtarget = noone
            state = "normal"
            hsp = -spd
            vsp = jumpspd
            facing = -1
            audio_play_sound(sn_walljump, 0, false)
        }
        else if _place_meeting(x - spd, y, par_solid)
        {
            platformtarget = noone
            state = "normal"
            hsp = spd
            vsp = jumpspd
            facing = 1
            audio_play_sound(sn_walljump, 0, false)
        }
    }
}

if(keyboard_check(_dbkey))
{
    hsp = 0
    vsp = 0
    x = mouse_x
    y = mouse_y
}

if _position_meeting(x, y + 1, par_solid)
{
    var footsound = choose(sn_stepgrass1, sn_stepgrass2, sn_stepgrass3)
    if(running && (ceil(image_index) == 5 || ceil(image_index) == 1))
    {
        if (!audio_is_playing(footsound))
            audio_play_sound(footsound, 8, false)
    }
    if(running && run && abs(hsp) >= spd && ceil(image_index) % 2 == 0)
    {
        with(instance_create_depth(x, bbox_bottom, (depth - 10), fx_dust))
        {
            sprite_index = spr_fx_dust2;
            vx = random_range(-0.1, 0.1);
            vy = random_range(-0.5, -0.1);
            vz = 0;
        }
    }
}

fire_angle = point_direction(x, y - 8, mouse_x, mouse_y);
fire_angle = round(fire_angle / 10) * 10;

spd = stats.spd