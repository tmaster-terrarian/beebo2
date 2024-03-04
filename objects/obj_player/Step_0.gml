__lastframe = floor(image_index)
__lastspr = sprite_index

if(sprite_index == _sp.idle || sprite_index == _sp.idle_lookup)
    image_index += 0.2 * global.dt

running = (sprite_index == _sp.run)

if(state != "ledgeclimb")
    ledgegrabTimer = approach(ledgegrabTimer, 0, global.dt)

input_dir = (input.right() - input.left()) * hascontrol

if(on_ground && state != "ledgegrab")
{
    platformtarget = instance_place((bbox_left + bbox_right)/2, bbox_bottom + 2, par_solid)
}
else if(_place_meeting(x + 2 * input_dir, y, par_solid) && (state == "normal" || state == "wallslide"))
{
    platformtarget = instance_place(x + 2 * input_dir, y, par_solid)
}
else if(jump_buffer < 10 && state != "ledgegrab")
{
    platformtarget = noone
}

if(place_meeting(x, y, par_solid) && !place_meeting(x, y - 1, par_jumpthru) && !ghost) y -= 1 * global.dt;

if(place_meeting(x, y, par_jumpthru))
{
    if(vsp <= 0)
    {
        vsp -= 0.2 * global.dt
        if(vsp > jumpspd/4)
            vsp = jumpspd/4
        y--
    }
}

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
    // if(abs(hsp) > spd * 1.3)
    //     fric *= 0.1
}

PAUSECHECK //prevent any further code from running if the game is paused (hopefully)

states[$ state]() //MAGIC

if (input.jump() && can_jump)
{
    if(on_ground) || ((jump_buffer && vsp > 0) || (jumps - 1 && state != "ledgegrab"))
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
        else if(!place_meeting(x, y - 2, par_solid))
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
        else
        {
            s = audio_play_sound(sn_jump, 0, false)
        }

        if(!on_ground)
        {
            if _place_meeting(x + spd, y, par_solid) && !place_meeting(x + spd, y, par_jumpthru) && can_walljump
            {
                state = "normal"
                hsp = -spd
                vsp = jumpspd
                facing = -1
                var w = instance_place(x + spd, y, par_solid)
                hsp += w.hsp / 2
                audio_stop_sound(s)
                audio_play_sound(sn_walljump, 0, false)
            }
            else if _place_meeting(x - spd, y, par_solid) && !place_meeting(x - spd, y, par_jumpthru) && can_walljump
            {
                state = "normal"
                hsp = spd
                vsp = jumpspd
                facing = 1
                var w = instance_place(x - spd, y, par_solid)
                hsp += w.hsp / 2
                audio_stop_sound(s)
                audio_play_sound(sn_walljump, 0, false)
            }
            else if(jump_buffer && vsp > 0)
            {
                jump_buffer = 0
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
                        vy = random_range(-0.2, 0)
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
                vsp -= 2.7 * !input.down()
            else // else displace the player first
            {
                if(state == "ledgegrab")
                    x -= 4 * facing
                y += 12
                vsp -= 2.7 * !input.down()
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
            vsp -= 2.7 * !input.down()
            sprite_index = _sp.jump
            image_index = 0
		    audio_play_sound(sn_walljump, 0, false)
        }
        state = "normal"
    }
    else if(can_walljump)
    {
        if _place_meeting(x + spd, y, par_solid) && !place_meeting(x + spd, y, par_jumpthru)
        {
            platformtarget = noone
            state = "normal"
            hsp = -spd
            vsp = jumpspd
            facing = -1
            var w = instance_place(x + spd, y, par_solid)
            hsp += w.hsp / 2
            audio_play_sound(sn_walljump, 0, false)
        }
        else if _place_meeting(x - spd, y, par_solid) && !place_meeting(x - spd, y, par_jumpthru)
        {
            platformtarget = noone
            state = "normal"
            hsp = spd
            vsp = jumpspd
            facing = 1
            var w = instance_place(x - spd, y, par_solid)
            hsp += w.hsp / 2
            audio_play_sound(sn_walljump, 0, false)
        }
    }
}

if(input.unjump() && vsp < 0)
{
    vsp /= 2
}

if(vsp > 4)
{
    squash = min(1.4, max(1, 1.01 * (vsp / 12)))
    stretch = max(0.65, min(1, 0.99 / (vsp / 12)))
}

if(skidding && on_ground)
{
    sprite_index = _sp.run
    image_index = 0

    with(instance_create_depth(x, bbox_bottom, (depth - 10), fx_dust))
    {
        sprite_index = spr_fx_dust2;
        image_index = irandom(1)
        vx = random_range(-0.1, 0.1);
        vy = random_range(-0.5, -0.1);
        vz = 0;
    }
}

// skill processing
var names = struct_get_names(skills)
for(var i = 0; i < array_length(names); i++)
{
    var skill = skills[$ names[i]]
    var def = skill.def

    if(skill.cooldown > 0)
        skill.cooldown = approach(skill.cooldown, 0, global.dt / 60)
    else if(skill.stocks < def.baseMaxStocks + bonus_stocks[$ names[i]])
    {
        skill.stocks = min(skill.stocks + def.rechargeStock, def.baseMaxStocks + bonus_stocks[$ names[i]])

        if(skill.stocks < def.baseMaxStocks + bonus_stocks[$ names[i]])
            skill.cooldown = def.baseStockCooldown
    }

    var inputPressed = input[$ names[i] + "Pressed"]()

    if(can_use_skills && inputPressed && (attack_state == names[i] && attack_states[$ attack_state].age >= (attack_states[$ attack_state].duration * def.spamCoeff)))
    {
        if(!def.beginCooldownOnEnd)
            skill.cooldown = def.baseStockCooldown
        skill.stocks -= def.stockToConsume

        if(attack_state != noone)
        {
            attack_states[$ attack_state].onExit(attack_states[$ attack_state], self)
            attack_state = noone
        }

        attack_state = names[i]
        attack_states[$ attack_state].onEnter(attack_states[$ attack_state], self)
    }
}

if(state == "ghost")
{
    var skill = deadskill
    var def = skill.def

    if(skill.cooldown > 0)
        skill.cooldown = approach(skill.cooldown, 0, global.dt / 60)
    else if(skill.stocks < def.baseMaxStocks)
    {
        skill.stocks = min(skill.stocks + def.rechargeStock, def.baseMaxStocks)

        if(skill.stocks < def.baseMaxStocks)
            skill.cooldown = def.baseStockCooldown
    }
}

for(var i = 0; i < array_length(names); i++)
{
    var skill = skills[$ names[i]]
    var def = skill.def

    var inputHeld = input[$ names[i]]()
    var preventSkillSelfInterrupt = attack_state != names[i]
    var higherPriority = (attack_state == noone || skills[$ attack_state].def.priority < skill.def.priority || skills[$ attack_state].def.priority < 0)
    var enoughStocksToFire = (skill.stocks >= def.requiredStock && skill.stocks - def.stockToConsume >= 0)

    if(can_use_skills && skill.cooldown <= 0 && inputHeld && preventSkillSelfInterrupt && higherPriority && enoughStocksToFire)
    {
        if(!def.beginCooldownOnEnd)
            skill.cooldown = def.baseStockCooldown
        skill.stocks -= def.stockToConsume

        if(attack_state != noone)
        {
            attack_states[$ attack_state].onExit(attack_states[$ attack_state], self)
            attack_state = noone
        }

        attack_state = names[i]
        attack_states[$ attack_state].onEnter(attack_states[$ attack_state], self)
    }
}

if(attack_state != noone)
{
    attack_states[$ attack_state].update(attack_states[$ attack_state], self)
}

x = round(x)
y = round(y)

squash = approach(squash, 1, 0.15 * global.dt)
stretch = approach(stretch, 1, 0.1 * global.dt)

if(place_meeting(x + input_dir, y, par_solid) && abs(input_dir) && sprite_index == _sp.run)
{
    sprite_index = _sp.idle
}

if(hp <= 0) && !ded
{
    ded = 1
    state = "dead"
    sprite_index = _sp.dead
    image_index = 0
    timer0 = 0

    rand = random(1) < 1/1000

    if(abs(hsp) < 2)
        hsp = 2 * sign(hsp)
    vsp = min(vsp, -1)

    regen = 0
}
