event_inherited()
stats =
{
    hp_max : 180,
    regen_rate : 1,
    curse : 1,
    spd : 2,
    jumpspd : -3.7,
    firerate : 5,
    spread : 4,
    damage : 10,
    ground_accel : 0.12,
    ground_fric : 0.08,
    air_accel : 0.07,
    air_fric : 0.02,
    jumps_max : 1,
    grv : 0.2
}
level_stats =
{
    hp_max: 30,
    damage: 2.4
}
_apply_stats()

depth = 50

xp_max = 50
xp = 0

can_attack = 1
can_jump = 1
can_walljump = 1
can_dodge = 1

vsp_max = 20

hascontrol = 1
lasthsp = 0
lastvsp = 0
duck = 0
lookup = 0
run = 0
landTimer = 0
wallslideTimer = 0
shake = 0
image_speed = 0
image_index = 0
ded = 0
attack = 0
up = 0

lastSafeX = x
lastSafeY = y

jump_buffer = 0
jump_buffer2 = 0
dashtimer = 0

firing = 0
firedelay = 0
recoil = 0

_sp =
{
    m_default: mask_player,
    m_duck: mask_player_duck,
    m_ledgegrab: mask_player_ledgegrab,
    idle: spr_player,
    idle_lookup: spr_player_lookup,
    crawl: spr_player_crawl,
    duck: spr_player_duck,
    dead: spr_player_dead,
    jump: spr_player_jump,
    run: spr_player_run,
    wallslide: spr_player_wallslide,
    ledgegrab: spr_player_ledgegrab
}
sprite_index = _sp.idle

_oncollide_h = function()
{
    if(!place_meeting(x + sign(hsp), y - 4, par_solid))
    {
        for(var i = 0; i < 4; i++)
        {
            y -= 1
            if(!place_meeting(x + sign(hsp), y, par_solid))
            {
                x += sign(hsp);
                break
            }
        }
    }
    else
    {
        if (abs(hsp) >= 1)
        {
            audio_play_sound(sn_player_land, 0, false)
            for (var i = 0; i < 3; i++)
            {
                with(instance_create_depth((x + (4 * sign(facing))), random_range((bbox_bottom - 12), (bbox_bottom - 2)), (depth - 1), fx_dust))
                {
                    sprite_index = spr_fx_dust2
                    vz = 0
                }
            }
        }
        hsp = 0
    }
}
_oncollide_v = function()
{
    var input_dir = 0
    input_dir = sign
    (
        gamepad_axis_value(0, gp_axislh)
        + (gamepad_button_check(0, gp_padr) - gamepad_button_check(0, gp_padl))
        + (keyboard_check(ord("D")) - keyboard_check(ord("A")))
    )
    if (state == "normal")
    {
        landTimer = 8
        sprite_index = _sp.jump
        image_index = 0
    }
    if (vsp > 0.2)
        audio_play_sound(sn_player_land, 0, false)
    if (vsp >= 0)
    {
        for (var i = 0; i < 4; i++)
        {
            with (instance_create_depth((bbox_left + random(8)), random_range(bbox_bottom, bbox_bottom), (depth - 1), fx_dust))
            {
                sprite_index = spr_fx_dust2
                vx = other.hsp
                vz = 0
            }
        }
    }
    vsp = 0
}

_squish = function()
{
    x = xstart
    y = ystart
    state = "normal"
    timer0 = 0
    ghost = 0
}

items = []

states =
{
    braindead : function()
    {with(obj_player){
        fxtrail = 0
        can_jump = 0
        can_walljump = 0
        hsp = 0
        vsp = 0
    }},
    normal : function()
    {with(obj_player){
        can_walljump = 1
        ghost = 0
        if (duck > 0)
            mask_index = _sp.m_duck
        else
            mask_index = _sp.m_default
        if (input_dir == 1)
        {
            if (hsp < 0)
            {
                hsp = approach(hsp, 0, fric)
            }
            else if (on_ground && vsp >= 0)
            {
                if (duck == 0 && !landTimer)
                {
                    sprite_index = _sp.run
                }
                else if(duck)
                {
                    sprite_index = _sp.crawl
                }
            }
            if(abs(hsp) > spd * 1.3)
                run = 7
            else
                run = 0
            if (hsp < spd)
                hsp = approach(hsp, spd, accel)
            if (hsp > spd) && on_ground
                hsp = approach(hsp, spd, fric/2)
            if on_ground
            {
                running = 1
                facing = 1
            }
            else
                facing = 1
        }
        else if (input_dir == -1)
        {
            if (hsp > 0)
            {
                hsp = approach(hsp, 0, fric)
            }
            else if (on_ground && vsp >= 0)
            {
                if (duck == 0 && !landTimer)
                {
                    sprite_index = _sp.run
                }
                else if(duck)
                {
                    sprite_index = _sp.crawl
                }
            }
            if(abs(hsp) > spd * 1.3)
                run = 7
            else
                run = 0
            if (hsp > -spd)
                hsp = approach(hsp, -spd, accel)
            if (hsp < -spd) && on_ground
                hsp = approach(hsp, -spd, fric/2)
            if on_ground
            {
                running = 1
                facing = -1
            }
            else
                facing = -1
        }
        else
        {
            running = 0
            hsp = approach(hsp, lasthsp, fric * 2)
            if (abs(hsp) < spd)
            {
                if run
                    run--
            }
            if (abs(hsp) < 0.5 && on_ground && !landTimer)
            {
                up = (keyboard_check(ord("W")) || gamepad_button_check(0, gp_padu))
                sprite_index = _sp.idle
                if duck
                {
                    sprite_index = _sp.duck
                    image_index = duck
                    lookup = -0.5
                }
                else if up
                {
                    sprite_index = _sp.idle_lookup
                    lookup = 1
                }
                else
                {
                    lookup = 0
                }
            }
        }
        if ((keyboard_check(ord("S")) || gamepad_axis_value(0, gp_axislv) > 0 || gamepad_button_check(0, gp_padd)) && on_ground)
            duck = approach(duck, 3, 1)
        else if (!(place_meeting(x, (y - 6), par_solid)))
            duck = approach(duck, 0, 1)
        if (!on_ground)
        {
            lookup = 0

            if (vsp >= -0.5)
            {
                if place_meeting((x + (2 * input_dir)), y, par_solid)
                {
                    wallslideTimer++
                    var _a = 1
                    var _w = instance_place(x + (2 * input_dir), y, par_solid)
                    if(!position_meeting((input_dir == 1) ? _w.bbox_left + 1 : _w.bbox_right - 1, _w.bbox_top - 1, par_solid) && round(_w.image_angle / 90) * 90 == _w.image_angle)
                    {
                        _a = sign(bbox_top - _w.bbox_top)

                        if(_a <= 0 && !place_meeting(x, _w.bbox_top - 1, par_solid) && !place_meeting(x, y + 2, par_solid))
                        {
                            y = _w.bbox_top
                            x = (input_dir == 1) ? _w.bbox_left : _w.bbox_right
                            facing = (input_dir != 0) ? sign(_w.x - x) : facing
                            timer0 = 0
                            state = "ledgegrab"
                            mask_index = _sp.m_ledgegrab
                            sprite_index = _sp.ledgegrab
                            hsp = 0
                            vsp = 0
                            platformtarget = _w
                        }
                    }
                }
            }
            else
                wallslideTimer = 0
            if (wallslideTimer >= 5)
                state = "wallslide"

            if jump_buffer
                jump_buffer--

            sprite_index = _sp.jump
            if (vsp >= 0.1)
                vsp = approach(vsp, vsp_max, grv)
            if (vsp < 0)
                vsp = approach(vsp, vsp_max, grv)
            else if (vsp < 2)
                vsp = approach(vsp, vsp_max, grv * 0.25)
            if (vsp < 0)
                image_index = approach(image_index, 1, 0.2)
            else if (vsp >= 0.5)
                image_index = approach(image_index, 5, 0.5)
            else
                image_index = 3
        }
        else
        {
            wallslideTimer = 0
            lasthsp = 0
            lastvsp = 0
            jump_buffer = 10
            jumps = jumps_max
        }
        if (running)
            image_index += abs(hsp / 6)
        else if (duck)
            image_index += abs(hsp / 4)
        landTimer = approach(landTimer, 0, 1)

        if(abs(hsp) > spd * 1.3)
        {
            fxtrail = 1
        }
        else fxtrail = 0
    }},
    wallslide: function()
    {with(obj_player){
        jumps = jumps_max
        can_walljump = 1
        if (vsp < 0)
            vsp = approach(vsp, vsp_max, 0.5)
        else
            vsp = approach(vsp, vsp_max / 3, grv / 3)
        if (!(place_meeting(x + (input_dir * 2), y, par_solid)))
        {
            state = "normal"
            wallslideTimer = 0
        }
        else
        {
            var _a = 1
            var _w = instance_place(x + (2 * input_dir), y, par_solid)
            if(!position_meeting((input_dir == 1) ? _w.bbox_left + 1 : _w.bbox_right - 1, _w.bbox_top - 1, par_solid) && round(_w.image_angle / 90) * 90 == _w.image_angle)
            {
                _a = sign(bbox_top - _w.bbox_top)

                if(_a <= 0 && !place_meeting(x, y - 1, par_solid) && !place_meeting(x, y + 1, par_solid))
                {
                    wallslideTimer = 0
                    y = _w.bbox_top
                    x = (input_dir == 1) ? _w.bbox_left : _w.bbox_right
                    facing = (input_dir != 0) ? sign(_w.x - x) : facing
                    timer0 = 0
                    state = "ledgegrab"
                    mask_index = _sp.m_ledgegrab
                    sprite_index = _sp.ledgegrab
                    hsp = 0
                    vsp = 0
                    platformtarget = _w
                }
            }
        }
        sprite_index = _sp.wallslide
        var n = choose(0, 1, 0, 1, 1, 0, 0, 0)
        if n
            with (instance_create_depth(x + 4 * sign(facing), random_range(bbox_bottom - 12, bbox_bottom), depth - 1, fx_dust))
            {
                vz = 0
                sprite_index = spr_fx_dust2
            }
        if (input_dir == 0 || on_ground)
        {
            state = "normal"
            wallslideTimer = 0
        }
        if (sign(input_dir) == -sign(facing))
        {
            state = "normal"
            wallslideTimer = 0
            facing = sign(input_dir)
        }
        vsp = clamp(vsp, -99, 2)
    }},
    ledgegrab: function()
    {with(obj_player){
        duck = 0
        can_jump = 1
        can_walljump = 0
        ghost = 0
        if(timer0 == 0)
        {
            if(facing == 0)
            {
                facing = 1
            }
            hsp = 0
            vsp = 0
            image_speed = 0
            image_index = 0
            sprite_index = _sp.ledgegrab
            mask_index = _sp.m_ledgegrab
        }
        // if(place_meeting(x, y, par_solid))
        // {
        //     y = platformtarget.bbox_top
        //     platformtarget = noone
        //     state = "normal"
        //     sprite_index = _sp.jump
        //     mask_index = _sp.m_default
        //     x += 8 * facing
        //     ghost = 0
        // }
        if(!place_meeting(x + 1, y, platformtarget) && !place_meeting(x - 1, y, platformtarget))
        {
            platformtarget = noone
            state = "normal"
            sprite_index = _sp.jump
            mask_index = _sp.m_default
            movex(-4 * facing)
            movey(12)
            ghost = 0
        }
    }}
}
state = "normal"

_dbkey = vk_lcontrol
