event_inherited()
stats = variable_clone(global.chardefs.beebo.stats)
level_stats = variable_clone(global.chardefs.beebo.level_stats)
_apply_stats()

skills = variable_clone(global.chardefs.beebo.skills)
attack_states = variable_clone(global.chardefs.beebo.attack_states)

depth = 50

xpTarget = 155
xp = 0
money = 0

can_attack = 1
can_jump = 1
can_walljump = 1
can_dodge = 1
can_ledgegrab = 1

vsp_max = 20

hascontrol = 1
lasthsp = 0
lastvsp = 0
duck = 0
lookup = 0
run = 0
landTimer = 0
wallslideTimer = 0
ledgegrabTimer = 0
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
bombdelay = 0
recoil = 0
fire_angle = 0

team = Team.player

gp_id = global.perPlayerInput[player_id].playerIndex
gamepad = (gp_id >= 0) // true if this player is using a gamepad

global.players[player_id] = self

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
    ledgegrab: spr_player_ledgegrab,
    ledgeclimb: spr_player_ledgeclimb
}
sprite_index = _sp.idle

gun_spr = spr_player_gun
gun_spr_ind = 0
gun_pos = {x: -3, y: -7}
gun_behind = 0
gun_flip = 1
draw_gun = 1
has_gun = 1

_p = self

input =
{
    left: function() {return ((other._p.gp_id >= 0) && gamepad_axis_value(other._p.gp_id, gp_axislh) < 0) || global.perPlayerInput[other._p.player_id].buttons.left.check()},
    right: function() {return ((other._p.gp_id >= 0) && gamepad_axis_value(other._p.gp_id, gp_axislh) > 0) || global.perPlayerInput[other._p.player_id].buttons.right.check()},
    up: function() {return ((other._p.gp_id >= 0) && gamepad_axis_value(other._p.gp_id, gp_axislv) < -0.5) || global.perPlayerInput[other._p.player_id].buttons.up.check()},
    down: function() {return ((other._p.gp_id >= 0) && gamepad_axis_value(other._p.gp_id, gp_axislv) > 0.5) || global.perPlayerInput[other._p.player_id].buttons.down.check()},
    jump: function() {return global.perPlayerInput[other._p.player_id].buttons.jump.checkPressed()},
    unjump: function() {return global.perPlayerInput[other._p.player_id].buttons.jump.checkReleased()},
    primary: function() {return global.perPlayerInput[other._p.player_id].buttons.skill1.check()},
    secondary: function() {return global.perPlayerInput[other._p.player_id].buttons.skill2.check()},
    utility: function() {return global.perPlayerInput[other._p.player_id].buttons.skill3.check()},
    special: function() {return global.perPlayerInput[other._p.player_id].buttons.skill4.check()},
    primaryPressed: function() {return global.perPlayerInput[other._p.player_id].buttons.skill1.checkPressed()},
    secondaryPressed: function() {return global.perPlayerInput[other._p.player_id].buttons.skill2.checkPressed()},
    utilityPressed: function() {return global.perPlayerInput[other._p.player_id].buttons.skill3.checkPressed()},
    specialPressed: function() {return global.perPlayerInput[other._p.player_id].buttons.skill4.checkPressed()}
}

_oncollide_h = function()
{
    var input_dir = input.right() - input.left()

    if(state == "dead")
    {
        hsp = -hsp * 0.9
    }
    else repeat(round(max(global.dt, 1)))
    {
        if(abs(input_dir) && !place_meeting(x + input_dir, y - 2, par_solid))
        {
            movey(-2)
            movex(input_dir * 2)
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
                        vy = (abs(other.vsp) > 0.6) ? other.vsp * 0.5 : vy
                        vz = 0
                    }
                }
            }
            hsp = 0
            break
        }
    }
}

_oncollide_v = function()
{
    if (state == "normal")
    {
        landTimer = 8
        sprite_index = _sp.jump
        image_index = 0
    }
    if (vsp > 0.2)
        audio_play_sound(sn_player_land, 0, false)
    if (vsp > 0)
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
    x = lastSafeX
    y = lastSafeY
    state = "normal"
    timer0 = 0
}

draw_hud = 1

state = "normal"
states =
{
    _p : other,
    braindead : function()
    {with(other){
        fxtrail = 0
        can_jump = 0
        can_walljump = 0
        hsp = 0
        vsp = 0
    }},
    intro : function()
    {with(other){
        if(timer0 == 0)
        {
            instance_create_depth(-8, 112, 0, fx_exploder, {image_xscale: 7, image_yscale: 6, lifetime: 60, interval: 6})
        }
        with(obj_player)
        {
            state = "braindead"
            duck = 0
            fxtrail = 0
            can_jump = 0
            can_walljump = 0
            ghost = 0
            hsp = 0
            vsp = 0
            has_gun = 0
            image_alpha = 0
        }
        state = "intro"
        if(timer0 < 60)
            timer0 = approach(timer0, 60, global.dt)
        if(timer0 == 60)
        {
            with(obj_player)
            {
                timer0 = 0
                state = "normal"
                image_alpha = 1
                has_gun = 1
                hsp = 2 + random(1.5)
                vsp = -2 - random(1)
            }
            audio_play_sound(sn_walljump, 2, 0)
            audio_play_sound(sn_walljump, 2, 0)
            audio_play_sound(sn_walljump, 2, 0)
        }
    }},

    normal : function()
    {with(other){
        can_walljump = 1
        can_jump = 1
        ghost = 0
        if (duck > 0)
            mask_index = _sp.m_duck
        else
            mask_index = _sp.m_default
        if (input_dir == 1)
        {
            if (hsp < 0)
            {
                if(hsp < -spd * 0.8)
                    skidding = 1
                else
                    skidding = 0
                hsp = approach(hsp, 0, fric * global.dt)
            }
            else if (on_ground && vsp >= 0)
            {
                skidding = 0
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
                hsp = approach(hsp, spd, accel * global.dt)
            if (hsp > spd) && on_ground
                hsp = approach(hsp, spd, fric/2 * global.dt)
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
                if(hsp > spd * 0.8)
                    skidding = 1
                else
                    skidding = 0
                hsp = approach(hsp, 0, fric * global.dt)
                skidding = 1
            }
            else if (on_ground && vsp >= 0)
            {
                skidding = 0
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
                hsp = approach(hsp, -spd, accel * global.dt)
            if (hsp < -spd) && on_ground
                hsp = approach(hsp, -spd, fric/2 * global.dt)
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
            skidding = 0
            running = 0
            hsp = approach(hsp, lasthsp, fric * 2 * global.dt)
            if (abs(hsp) < spd)
            {
                if run
                    run--
            }
            if (abs(hsp) < 1.5 && on_ground && !landTimer)
            {
                up = input.up()
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
        if (input.down() && on_ground)
            duck = approach(duck, 3, 1 * global.dt)
        else if (!(place_meeting(x, y - 6, par_solid)))
        {
            if(duck)
                _place_meeting(x, y - 6, par_solid)
            duck = approach(duck, 0, 1 * global.dt)
        }
        if (!on_ground)
        {
            lookup = 0

            if (vsp >= -0.5)
            {
                if place_meeting((x + (2 * input_dir)), y, par_solid)
                {
                    wallslideTimer += global.dt
                    var _a = 1
                    var _w = instance_place(x + (2 * input_dir), y, par_solid)
                    if(can_ledgegrab && ledgegrabTimer <= 0)
                    if(!_position_meeting((input_dir == 1) ? _w.bbox_left + 1 : _w.bbox_right - 1, _w.bbox_top - 1, par_solid) && !_position_meeting((input_dir == 1) ? _w.bbox_left - 2 : _w.bbox_right + 2, _w.bbox_top + 10, par_solid) && (round(_w.image_angle / 90) * 90 == _w.image_angle) && (_w.bbox_top >= 4))
                    {
                        _a = sign(bbox_top - _w.bbox_top)

                        if(_a <= 0 && !_place_meeting(x, _w.bbox_top - 1, par_solid) && !_place_meeting(x, y + 2, par_solid) && y - _w.bbox_top > 4)
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

            jump_buffer = approach(jump_buffer, 0, 1 * global.dt)

            sprite_index = _sp.jump
            if (vsp >= 0.1)
                vsp = approach(vsp, vsp_max, grv * global.dt)
            if (vsp < 0)
                vsp = approach(vsp, vsp_max, grv * global.dt)
            else if (vsp < 2)
                vsp = approach(vsp, vsp_max, grv * global.dt * 0.25)
            if (vsp < 0)
                image_index = approach(image_index, 1, 0.2 * global.dt)
            else if (vsp >= 0.5)
                image_index = approach(image_index, 5, 0.5 * global.dt)
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

            if(!place_meeting(x + 1, y + 1, par_solid) || !place_meeting(x - 1, y + 1, par_solid))
            {
                vsp += 0.1
            }
        }
        if (running)
            image_index += abs(hsp / 6) * global.dt
        else if (duck)
            image_index += abs(hsp / 4) * global.dt
        landTimer = approach(landTimer, 0, 1 * global.dt)

        if(abs(hsp) > spd * 1.3)
        {
            fxtrail = 1
        }
        else fxtrail = 0
    }},
    wallslide: function()
    {with(other){
        can_walljump = 1
        if (vsp < 0)
            vsp = approach(vsp, vsp_max, 0.5 * global.dt)
        else
            vsp = approach(vsp, vsp_max / 3, grv / 3 * global.dt)
        if (!(place_meeting(x + (input_dir * 2), y, par_solid)))
        {
            state = "normal"
            wallslideTimer = 0
        }
        else
        {
            var _a = 1
            var _w = instance_place(x + (2 * input_dir), y, par_solid)
            if(can_ledgegrab && ledgegrabTimer == 0)
            if(!_position_meeting((input_dir == 1) ? _w.bbox_left + 1 : _w.bbox_right - 1, _w.bbox_top - 1, par_solid) && !_position_meeting((input_dir == 1) ? _w.bbox_left - 2 : _w.bbox_right + 2, _w.bbox_top + 10, par_solid) && (round(_w.image_angle / 90) * 90 == _w.image_angle) && (_w.bbox_top >= 4))
            {
                _a = sign(bbox_top - _w.bbox_top)

                if(_a <= 0 && !_place_meeting(x, _w.bbox_top - 1, par_solid) && !_place_meeting(x, y + 2, par_solid))
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
                if(instance_exists(other.platformtarget))
                    vx += other.platformtarget.hsp
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
    {with(other){
        duck = 0
        can_jump = 1
        can_walljump = 0
        ghost = 0
        hsp = 0
        vsp = 0
        if(timer0 == 0)
        {
            if(facing == 0)
            {
                facing = 1
            }
            image_speed = 0
            image_index = 0
            sprite_index = _sp.ledgegrab
            mask_index = _sp.m_ledgegrab
            timer0++
        }

        if(abs(input_dir) && !_place_meeting(x + 4 * facing, platformtarget.bbox_top - 10, par_solid))
        {
            timer0 = approach(timer0, 16, 1 * global.dt)
            if(timer0 == 16)
            {
                hsp = 0
                vsp = 0
                state = "ledgeclimb"
                x += 4 * facing
                timer0 = 0
                return
            }
        }
        else
            timer0 = 1

        if(!place_meeting(x + 1, y, platformtarget) && !place_meeting(x - 1, y, platformtarget))
        {
            platformtarget = noone
            state = "normal"
            timer0 = 0
            sprite_index = _sp.jump
            mask_index = _sp.m_default
            movex(-4 * facing, _oncollide_h, 0)
            movey(12, _oncollide_h, 0)
            ghost = 0
        }
    }},
    ledgeclimb: function()
    {with(other){
        duck = 0
        can_jump = 1
        can_walljump = 0
        ghost = 0
        hsp = 0
        vsp = 0
        if(timer0 == 0)
        {
            y++
            if(facing == 0)
            {
                facing = 1
            }
            image_speed = 0
            image_index = 0
            sprite_index = _sp.ledgeclimb
            mask_index = _sp.m_duck
        }
        if(timer0 < 8)
        {
            if(timer0 == 5)
            {
                sprite_index = _sp.duck
                image_index = 0
            }
            if(timer0 < 5)
            {
                image_index = approach(image_index, 2, 0.5 * global.dt)
                timer0 = approach(timer0, 5, 1 * global.dt)
            }
            else
            {
                image_index = approach(image_index, 3, 1 * global.dt)
                timer0 = approach(timer0, 8, 1 * global.dt)
            }
        }
        if(timer0 == 8)
        {
            timer0 = 0

            state = "normal"
            sprite_index = _sp.idle
            mask_index = _sp.m_default
            image_index = 0
        }
    }},
    dead: function()
    {with(other){
        duck = 0
        fxtrail = 0
        can_jump = 0
        can_walljump = 0
        ghost = 0
        sprite_index = _sp.dead
        image_index = on_ground + (on_ground && rand)

        if(on_ground)
            hsp = approach(hsp, 0, fric * 2 * global.dt)
        else
            vsp = approach(vsp, 20, grv * global.dt)
    }}
}

_dbkey = vk_lcontrol

collision_checks = []

var c1 = make_color_rgb(52, 28, 39)
var c2 = make_color_rgb(96, 44, 44)
ponytail_colors = [c1,c2,c1,c2,c1,c2,c1]
ponytail_points_count = 7
ponytail_segment_len = []
ponytail_points = []
ponytail_visible = 1
for(var a = 0; a < ponytail_points_count; a++)
{
    ponytail_points[a] = [0, 0]
    if a % 2 == 0
        ponytail_segment_len[a] = 1
    else
        ponytail_segment_len[a] = 2
}

hair_visible = 1

skidding = 0
