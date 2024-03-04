event_inherited()
stats = global.chardefs.beebo.stats
level_stats = global.chardefs.beebo.level_stats
_apply_stats()

skills = variable_clone(global.chardefs.beebo.skills)
attack_states = variable_clone(global.chardefs.beebo.attack_states)

deadskill = variable_clone(global.chardefs.dead.skills.primary)
deadskill_state = variable_clone(global.chardefs.dead.attack_states.primary)

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

oneshotprotection = 0

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
stun_immune = 1

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
    ledgeclimb: spr_player_ledgeclimb,
    ghost: spr_player_ghost
}
sprite_index = _sp.idle

gun_spr = spr_player_gun
gun_spr_ind = 0
gun_pos = {x: -3, y: -7}
gun_behind = 0
gun_flip = 1
draw_gun = 1
has_gun = 1
fire = 0
firebomb = 0

draw_hud = 1

_p = self

squash = 1
stretch = 1

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
            if(place_meeting(x + input_dir, y, par_solid))
            {
                movey(-2)
                movex(input_dir * 2)
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
        sprite_index = abs(input_dir) ? _sp.run : _sp.idle
        image_index = 0
    }
    if (vsp > 0.4)
    {
        audio_play_sound(sn_player_land, 0, false)
        squash = 0.9
        stretch = 1.4
    }
    if (vsp > 0.2)
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

drawMyShit = function()
{
    var w = 24

    if(hp >= 0)
    {
        var c = c_black
        // var avgx = (bbox_left + bbox_right) / 2
        var avgx = x

        draw_rectangle_color(avgx - floor(w/2) - 2, bbox_bottom + 5, avgx + ceil(w/2) + 1, bbox_bottom + 11, c,c,c,c,false)

        c = c_white
        draw_rectangle_color(avgx - floor(w/2) - 1, bbox_bottom + 6, avgx + ceil(w/2), bbox_bottom + 10, c,c,c,c,false)

        draw_sprite_ext(spr_enemyhpbar, 0, avgx - floor(w/2), bbox_bottom + 7, w, 1, 0, c_white, 1)

        draw_sprite_ext(spr_enemyhpbar, 3, avgx - floor(w/2), bbox_bottom + 7, ceil(max(hp_change / total_hp_max, 0) * w), 1, 0, c_white, 1)
        draw_sprite_ext(spr_enemyhpbar, 1, avgx - floor(w/2), bbox_bottom + 7, ceil(max(hp / total_hp_max, 0) * w), 1, 0, c_white, 1)
        draw_sprite_ext(spr_enemyhpbar, 4, avgx - floor(w/2) + ceil(max(hp / total_hp_max, 0) * w), bbox_bottom + 7, min(ceil(max(shield / total_hp_max, 0) * w), w - ceil(max(hp / total_hp_max, 0) * w)), 1, 0, c_white, 1)
        if(ceil(hp_change) < ceil(hp))
        {
            draw_sprite_ext(spr_enemyhpbar, 2, avgx - floor(w/2) + ceil(max(hp / total_hp_max, 0) * w), bbox_bottom - 7, ceil(max(-(hp - hp_change) / total_hp_max, 0) * w), 1, 0, c_white, 1)
        }
    }
}

_squish = function()
{
    x = lastSafeX
    y = lastSafeY
    state = "normal"
    timer0 = 0
}

onFrameChange = function()
{
    var f = floor(image_index)
    var c = ceil(image_index)
    if(sprite_index == _sp.run)
    {
        if position_meeting(x, y + 1, par_solid)
        {
            var footsound = choose(sn_stepgrass1, sn_stepgrass2, sn_stepgrass3)
            if(running && (f == 5 || f == 1) && !skidding)
            {
                audio_play_sound(footsound, 8, false)
            }
            if(running && run && abs(hsp) >= spd && c % 3 == 0)
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
    }
}

state = "normal"
states =
{
    _p : other,
    braindead : function()
    {with(other){
        can_use_skills = 0
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
            can_use_skills = 0
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
                can_use_skills = 1
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
                if(-hsp > spd * 0.6)
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
            if(abs(hsp) > 2.6)
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
                if(hsp > spd * 0.6)
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
            if(abs(hsp) > 2.6)
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
            running = 0
            hsp = approach(hsp, lasthsp, fric * 2 * global.dt)
            if (abs(hsp) < spd + abs(lasthsp))
            {
                skidding = 0
                if run
                    run--
            }
            if (abs(hsp) < 1.5 + abs(lasthsp) && on_ground && !landTimer)
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
                    if(can_ledgegrab && ledgegrabTimer <= 0 && instance_exists(_w) && !place_meeting(x, y, par_solid))
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
        if (running && !place_meeting(x + input_dir, y, par_solid))
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
            if(can_ledgegrab && ledgegrabTimer == 0 && instance_exists(_w) && !place_meeting(x, y, par_solid))
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

        if(!instance_exists(platformtarget))
        {
            platformtarget = noone
            state = "normal"
            timer0 = 0
            sprite_index = _sp.jump
            mask_index = _sp.m_default
            movex(-4 * facing, _oncollide_h, 0)
            movey(12, _oncollide_h, 0)
            ghost = 0
            return
        }

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
        image_index = on_ground// + (on_ground && rand) // benbo refrence ?!?!?
        can_use_skills = 0

        if(on_ground)
        {
            hsp = approach(hsp, lasthsp, fric * 2 * global.dt)
            if(timer0 < 60)
                timer0 = approach(timer0, 60, global.dt)
            else
            {
                timer0 = 0
                state = "ghost"
                instance_create_depth(x, y, depth + 1, obj_empty, {sprite_index, image_index, image_xscale, image_angle, image_speed: 0})
                vsp = -2
                mask_index = mask_player

                _items = []
                array_copy(_items, 0, items, 0, array_length(items))
                items = []
            }
        }
        else
            vsp = approach(vsp, vsp_max, grv * global.dt)
    }},

    ghost: function()
    {with(other){
        duck = 0
        fxtrail = 0
        can_jump = 0
        can_walljump = 0
        ghost = 1
        on_ground = 0
        sprite_index = _sp.ghost
        image_alpha = 0.6
        can_use_skills = 0
        running = 0
        fric = 0.04
        accel = 0.06
        var input_dir2 = (input.down() - input.up()) * hascontrol

        if (input_dir == 1)
        {
            if (hsp < 0)
            {
                hsp = approach(hsp, 0, fric * 2 * global.dt)
            }
            else
                hsp = approach(hsp, 2, accel * global.dt)
            facing = 1
        }
        else if (input_dir == -1)
        {
            if (hsp > 0)
            {
                hsp = approach(hsp, 0, fric * 2 * global.dt)
            }
            else
                hsp = approach(hsp, -2, accel * global.dt)
            facing = -1
        }
        else
        {
            hsp = approach(hsp, 0, fric * global.dt)
        }
        if (input_dir2 == 1)
        {
            if (vsp < 0)
            {
                vsp = approach(vsp, 0, fric * 2 * global.dt)
            }
            else
                vsp = approach(vsp, 2, accel * global.dt)
        }
        else if (input_dir2 == -1)
        {
            if (vsp > 0)
            {
                vsp = approach(vsp, 0, fric * 2 * global.dt)
            }
            else
                vsp = approach(vsp, -2, accel * global.dt)
        }
        else
        {
            vsp = approach(vsp, 0, fric * global.dt)
        }

        fire_angle = 180 * (facing == -1)

        var skill = deadskill
        var def = skill.def

        var inputHeld = input.primary()
        var preventSkillSelfInterrupt = attack_state != "primary"
        var higherPriority = (attack_state == noone || skills[$ attack_state].def.priority < skill.def.priority || skills[$ attack_state].def.priority < 0)
        var enoughStocksToFire = (skill.stocks >= def.requiredStock && skill.stocks - def.stockToConsume >= 0)
        if(skill.cooldown <= 0 && inputHeld && preventSkillSelfInterrupt && enoughStocksToFire)
        {
            if(!def.beginCooldownOnEnd)
                skill.cooldown = def.baseStockCooldown
            skill.stocks -= def.stockToConsume

            if(attack_state != noone)
            {
                attack_states[$ attack_state].onExit(attack_states[$ attack_state], self)
                attack_state = noone
            }

            attack_state = "primary"
            deadskill_state.onEnter(deadskill_state, self)
        }
    }}
}

_dbkey = ord(string(player_id + 1))

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
