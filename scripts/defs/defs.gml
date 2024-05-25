function initSkills()
{
    var deadPrimarySkill = new Skill("dead.primary", function(def) {
        def.baseMaxStocks = 1
        def.baseStockCooldown = 1
        def.beginCooldownOnEnd = 0
        def.fullRestockOnAssign = 1
        def.isCombatSkill = 1
        def.mustKeyPress = 0
        def.rechargeStock = 1
        def.requiredStock = 1
        def.stockToConsume = 1
        def.slot = "primary"
        def.priority = 0
        def.buffer = 0
    })

    var deadPrimarySkillState = new State(function(def) {
        def.baseDuration = 20/60
        def.onEnter = function(ins, obj) {

            ins.duration = ins.baseDuration / obj.attack_speed

            with(obj)
            {
                screen_shake_set(1, 5)

                var v = spread
                var _obj = instance_create_depth(x + lengthdir_x(14, fire_angle), y + lengthdir_y(14, fire_angle) - 8, depth - 3, obj_bullet)

                with (_obj)
                {
                    parent = other
                    team = other.team
                    _audio_play_sound(sn_player_shoot, 1, false);

                    _speed = 12;
                    direction = other.fire_angle;
                    image_angle = direction;

                    damage = other.damage * 0.5
                    proc = 0.8
                }
                with(instance_create_depth(x + lengthdir_x(4, fire_angle), y + lengthdir_y(4, fire_angle), depth - 5, fx_casing))
                {
                    image_yscale = other.facing
                    angle = other.fire_angle
                    dir = other.facing
                    hsp = -other.facing * random_range(1, 1.5)
                    vsp = -1 + random_range(-0.2, 0.1)
                }
            }
        }
        def.onExit = function(ins, obj) {
            ins.age = 0
            obj.attack_state = noone
        }
    }, deadPrimarySkill)
    deadPrimarySkill.activationState = deadPrimarySkillState

    #region BEEBER
    var beeboPrimarySkill = new Skill("beebo.rapidfire", function(def) {
        def.baseMaxStocks = 1
        def.baseStockCooldown = 0
        def.beginCooldownOnEnd = 0
        def.fullRestockOnAssign = 1
        def.isCombatSkill = 1
        def.mustKeyPress = 0
        def.rechargeStock = 1
        def.requiredStock = 0
        def.stockToConsume = 0
        def.slot = "primary"
        def.priority = 0
        def.buffer = 0
    })

    var beeboSecondarySkill = new Skill("beebo.bomb_throw", function(def) {
        def.baseMaxStocks = 1
        def.baseStockCooldown = 2
        def.beginCooldownOnEnd = 0
        def.fullRestockOnAssign = 1
        def.isCombatSkill = 1
        def.mustKeyPress = 0
        def.rechargeStock = 1
        def.requiredStock = 1
        def.stockToConsume = 1
        def.slot = "secondary"
        def.priority = 1
        def.buffer = 1
    })

    var beeboUtilitySkill = new Skill("beebo.quick_evade", function(def) {
        def.baseMaxStocks = 1
        def.baseStockCooldown = 5
        def.beginCooldownOnEnd = 0
        def.fullRestockOnAssign = 1
        def.isCombatSkill = 0
        def.mustKeyPress = 0
        def.rechargeStock = 1
        def.requiredStock = 1
        def.stockToConsume = 1
        def.slot = "utility"
        def.priority = 2
        def.buffer = 0
    })

    var beeboSpecialSkill = new Skill("beebo.hotswap", function(def) {
        def.baseMaxStocks = 1
        def.baseStockCooldown = 6
        def.beginCooldownOnEnd = 0
        def.fullRestockOnAssign = 1
        def.isCombatSkill = 1
        def.mustKeyPress = 0
        def.rechargeStock = 1
        def.requiredStock = 1
        def.stockToConsume = 1
        def.slot = "special"
        def.priority = 1
        def.buffer = 1
    })

    var beeboPrimarySkillState = new State(function(def) {
        def.baseDuration = 6/60
        def.onEnter = function(ins, obj) {
            ins.duration = ins.baseDuration / obj.attack_speed

            with(obj)
            {
                screen_shake_set(1, 5)
                recoil = 2

                fire = 1

                var v = spread
                var _obj = instance_create_depth(x + lengthdir_x(14, fire_angle) + gun_pos.x * sign(facing), y + lengthdir_y(14, fire_angle) + gun_pos.y - 1, depth - 3, obj_bullet)

                with (_obj)
                {
                    parent = other
                    team = other.team
                    _audio_play_sound(sn_player_shoot, 1, false);

                    _speed = 12;
                    direction = other.fire_angle + random_range(-v, v);
                    image_angle = direction;

                    damage = other.damage * 0.5
                    proc = 0.8
                }
                with(instance_create_depth(x + lengthdir_x(4, fire_angle) + gun_pos.x * sign(facing), y + lengthdir_y(4, fire_angle) - 1 + gun_pos.y, depth - 5, fx_casing))
                {
                    image_yscale = other.facing
                    angle = other.fire_angle
                    dir = other.facing
                    hsp = -other.facing * random_range(1, 1.5)
                    vsp = -1 + random_range(-0.2, 0.1)
                }

                heat = approach(heat, heat_max, heat_rate * global.dt)
                var n = irandom_range(0, (heat_max/ceil(heat))/round(global.dt))
                if(n == 0)
                {
                    var dist = random_range(0.1, 1) * 12
                    with(instance_create_depth(x + lengthdir_x(dist, fire_angle) + gun_pos.x * sign(facing), y - 2 + lengthdir_y(dist, fire_angle) + gun_pos.y, depth - 1, fx_dust))
                    {
                        vy = random_range(-1.5, -1) + other.vsp
                        vx += other.hsp
                    }
                }
                cool_delay = ins.duration + 30
            }
        }
        def.update = function(ins, obj) {
            ins.age = approach(ins.age, ins.duration, global.dt / 60)
            if(ins.age >= ins.duration)
            {
                with(ins) onExit(self, obj)
                return;
            }
        }
        def.onExit = function(ins, obj) {
            ins.age = 0
            obj.attack_state = noone
            with(obj)
            {
                gun_spr = spr_player_gun_reload
                gun_spr_ind = 0
            }
        }
    }, beeboPrimarySkill)
    beeboPrimarySkill.activationState = beeboPrimarySkillState

    var beeboSecondarySkillState = new State(function(def) {
        def.baseDuration = 0.33
        def.onEnter = function(ins, obj) {
            ins.duration = ins.baseDuration / obj.attack_speed

            with(obj)
            {
                screen_shake_set(2, 10)
                recoil = 6

                fire = 1

                bomb = instance_create_depth(x + lengthdir_x(12, fire_angle) + gun_pos.x * sign(facing), y + lengthdir_y(12, fire_angle) + gun_pos.y - 1, depth - 2, obj_bomb, {max_dmg_boost: heat_max, damage_boosted : ((heat > 20) ? heat : 0)})

                with(bomb)
                {
                    parent = other
                    team = other.team
                    _audio_play_sound(sn_throw, 0, 0, 1, 0, 1)

                    hsp = lengthdir_x(2, other.fire_angle) + (other.hsp * 0.5)
                    vsp = lengthdir_y(2, other.fire_angle) + (other.vsp * 0.25) - 1

                    damage = other.damage * (2 + 3 * (other.heat/other.heat_max))

                    // bulleted_delay = 20

                    bulleted_delay = 0
                }
                if(heat > 1)
                repeat(6)
                {
                    var dist = random_range(0.1, 1) * 12
                    with(instance_create_depth(x + lengthdir_x(dist, fire_angle) + gun_pos.x * sign(facing), y - 2 + lengthdir_y(dist, fire_angle) + gun_pos.y, depth - 1, fx_dust))
                    {
                        vy = random_range(-1.5, -1) + other.vsp
                        vx += other.hsp
                        vx *= 1.5
                        fric *= 0.2
                    }
                    _audio_play_sound(sn_steam, 0, false, heat/heat_max)
                }
                heat = 0
            }
        }
    }, beeboSecondarySkill)
    beeboSecondarySkill.activationState = beeboSecondarySkillState

    var beeboUtilitySkillState = new State(function(def) {
        def.baseDuration = 5/60

        def.onEnter = function(ins, obj) {
            ins.duration = ins.baseDuration

            with(obj)
            {
                hsp = (1.5 + (spd * 2) + (((spd / stats.spd) * 1) * on_ground) + (((spd / stats.spd - 2) * 0.1) * !on_ground)) * sign(facing)
                vsp = -1 * !on_ground

                sprite_index = spr_player_dash
                mask_index = mask_player
                image_index = 0

                timer0 = 0

                repeat(8)
                {
                    with(instance_create_depth(x + random_range(-1, 4) * sign(facing), y - random(10), depth - 2, fx_dust))
                    {
                        vx = random_range(-3, -1) * sign(other.facing)
                        vy = random_range(-0.5, 0.5)
                    }
                }

                __utilityHit = []

                if(!variable_struct_exists(states, "SKILL_quick_evade"))
                {
                    states.SKILL_quick_evade = function() {with(other) {
                        can_jump = 1
                        can_walljump = 0
                        ghost = 0
                        duck = 0
                        fxtrail = 1
                        hsp = approach(hsp, (spd + 1.5) * sign(facing), 0.25 * spd/stats.spd * global.dt)
                        if(!on_ground)
                            vsp = approach(vsp, 20, grv/2 * global.dt)

                        if(on_ground && fxtrailtimer <= 1)
                        {
                            with(instance_create_depth(x + random_range(-1, 4) * sign(facing), y, depth - 2, fx_dust))
                            {
                                vx = random_range(-3, -1) * sign(other.facing)
                                vy = random_range(-1.5, 0)
                            }
                        }

                        var e = instance_place(x, y, par_unit)
                        if(e && canHurt(self, e) && !array_contains(__utilityHit, e))
                        {
                            array_push(__utilityHit, e)
                            DamageEvent(new DamageEventContext(id, e, base_damage * 0.5, 1, 1, 0))
                        }

                        if(abs(hsp) <= spd + 1.5)
                        {
                            state = "normal"
                            __utilityHit = []
                            fxtrail = 0
                        }
                    }}
                }
                state = "SKILL_quick_evade"
            }
        }
        self.update = function(ins, obj) {
            ins.age = approach(ins.age, ins.duration, global.dt / 60)
            if(ins.age >= ins.duration || obj.state != "SKILL_quick_evade")
            {
                obj.__utilityHit = []
                with(ins) onExit(self, obj)
                return;
            }
        }
        self.onExit = function(ins, obj) {
            ins.age = 0
            obj.attack_state = noone
        }
    }, beeboUtilitySkill)
    beeboUtilitySkill.activationState = beeboUtilitySkillState

    var beeboSpecialSkillState = new State(function(def) {
        def.baseDuration = 45/60

        def.onEnter = function(ins, obj) {
            ins.duration = ins.baseDuration / obj.attack_speed

            with(obj)
            {
                sprite_index = spr_player
                mask_index = mask_player
                image_index = 0

                timer0 = 0

                __specialHit = []

                recoil = 4

                if(!variable_struct_exists(states, "SKILL_hotswap"))
                {
                    states.SKILL_hotswap = function() {with(other) {

                        hsp = clamp(hsp, -spd, spd) * 0.25
                        if(!on_ground)
                            vsp = clamp(vsp, -1.5, 1)

                        can_jump = 0
                        can_walljump = 0
                        ghost = 0
                        duck = 0
                        fxtrail = 0

                        gun_angle = 180 * (facing < 0)

                        instance_create_depth(x + 12 * other.facing, y - 12, depth - 1, fx_anim, {sprite_index: spr_fx_hotswap, animspeed: 0.4, image_xscale})

                        _audio_play_sound(sn_shotgun_blast, 1, 0)

                        with(par_unit)
                        {
                            if(collision_circle(other.x + 12 * other.facing, other.y - 12, 30, id, 0, 0) && canHurt(other, self) && !array_contains(other.__specialHit, self))
                            {
                                array_push(other.__specialHit, self)
                                DamageEvent(new DamageEventContext(other, self, other.damage * 4, 1))
                            }
                        }

                        var e = instance_place(x, y, par_unit)
                        if(e && canHurt(self, e) && !array_contains(__specialHit, e))
                        {
                            array_push(__specialHit, e)
                            DamageEvent(new DamageEventContext(id, e, base_damage * 0.5, 1, 1, 0))
                        }

                        state = "normal" // for now i keep this
                    }}
                }
                state = "SKILL_hotswap"
            }
        }
        self.update = function(ins, obj) {
            ins.age = approach(ins.age, ins.duration, global.dt / 60)
            if(ins.age >= ins.duration || obj.state != "SKILL_hotswap")
            {
                obj.__specialHit = []
                with(ins) onExit(self, obj)
                return;
            }
        }
    }, beeboSpecialSkill)
    beeboSpecialSkill.activationState = beeboSpecialSkillState
    #endregion

    #region RIVAL
    var rivalPrimarySkill = new Skill("rival.blade", function(def) {
        def.baseMaxStocks = 1
        def.baseStockCooldown = 0
        def.beginCooldownOnEnd = 0
        def.fullRestockOnAssign = 1
        def.isCombatSkill = 1
        def.mustKeyPress = 0
        def.rechargeStock = 1
        def.requiredStock = 0
        def.stockToConsume = 0
        def.slot = "primary"
        def.priority = 0
        def.buffer = 0
    })

    rivalPrimarySkill.activationState = new State(function(def) {
        def.baseDuration = 22/60
        def.onEnter = function(ins, obj) {
            ins.duration = ins.baseDuration / obj.attack_speed

            with(obj)
            {
                timer0 = 0
                swfxtrail = 1
                sword_angle_locked = 1
                sprite_index = duck ? spr_anime_swing_duck : spr_anime_swing1
                can_jump = 0
                can_walljump = 0
                vsp = min(abs(vsp), 0.75) * sign(vsp)
                sword_xscale = -sign(facing)
                _sword_angle = duck ? 20 * facing : 100 * facing
                if(combo && !duck)
                {
                    combo = 0
                    image_index = 4
                }
                else
                    combo = 1
                if(!variable_struct_exists(states, "SKILL_blade"))
                {
                    states.SKILL_blade = function() { with(other) {
                        if(timer0 < 16)
                        {
                            if(duck)
                            {
                                image_index += 0.25 * global.dt * attack_speed

                                if(timer0 < 4)
                                {
                                    sword_angle = 170 * facing
                                    swordpos.x = 1
                                    swordpos.y = -3
                                    timer0 = approach(timer0, 4, global.dt * attack_speed)
                                }
                                else if(timer0 < 8)
                                {
                                    if(timer0 == 4)
                                    {
                                        _sword_angle = sword_angle
                                        _audio_play_sound(sn_rivalSwing, 1, 0, 1, 0, random_range(1.1, 1.2))
                                    }
                                    sword_angle = 180 * facing
                                    sword_xscale = approach(sword_xscale, -1.5 * facing, 0.05 * global.dt)
                                    swordpos.x = 2
                                    swordpos.y = -3
                                    timer0 = approach(timer0, 8, global.dt * attack_speed)
                                }
                                else if(timer0 < 12)
                                {
                                    if(timer0 == 8)
                                    {
                                        _sword_angle = sword_angle

                                        with(instance_create_depth(x, y - 10, depth, obj_empty, {sprite_index: spr_1pixel, image_xscale: 30 * facing, image_yscale: 10, parent: id, damage, team}))
                                        {
                                            with(par_unit)
                                            {
                                                if(place_meeting(x, y, other) && canHurt(self, other))
                                                {
                                                    DamageEvent(new DamageEventContext(other.parent, id, other.damage, 1, 1, -1, 1))
                                                }
                                            }
                                            instance_destroy()
                                        }
                                    }
                                    sword_angle = 190 * facing
                                    sword_xscale = approach(sword_xscale, -2 * facing, 0.2 * global.dt)
                                    swordpos.x = 3
                                    swordpos.y = -3
                                    vsp = approach(vsp, 0, fric * global.dt)
                                    timer0 = approach(timer0, 12, global.dt * attack_speed)
                                }
                                else
                                {
                                    if(timer0 == 12)
                                        _sword_angle = sword_angle
                                    sword_angle = 200 * facing
                                    sword_xscale = approach(sword_xscale, -1.5 * facing, 0.05 * global.dt)
                                    swordpos.x = 2
                                    swordpos.y = -3
                                    vsp = approach(vsp, 0, fric)
                                    timer0 = approach(timer0, 16, global.dt * attack_speed)
                                }
                            }
                            else if(!combo)
                            {
                                image_index -= 0.25 * global.dt * attack_speed

                                if(timer0 < 4)
                                {
                                    sword_angle = 320 * facing
                                    sword_xscale = -0.9 * facing
                                    swordpos.x = -4
                                    swordpos.y = -14
                                    timer0 = approach(timer0, 4, global.dt * attack_speed)
                                }
                                else if(timer0 < 8)
                                {
                                    if(timer0 == 4)
                                    {
                                        _audio_play_sound(sn_rivalSwing, 1, 0, 1, 0, random_range(1.1, 1.2))
                                    }
                                    sword_angle = 220 * facing
                                    sword_xscale = -1.25 * facing
                                    swordpos.x = 5 - (timer0 - 8) * 2
                                    swordpos.y = -14
                                    timer0 = approach(timer0, 8, global.dt * attack_speed)
                                }
                                else if(timer0 < 12)
                                {
                                    if(timer0 == 8)
                                    {
                                        _sword_angle = sword_angle

                                        with(instance_create_depth(x, y - 14, depth, obj_empty, {sprite_index: spr_1pixel, image_xscale: 24 * facing, image_yscale: 14, parent: id, damage, team}))
                                        {
                                            with(par_unit)
                                            {
                                                if(place_meeting(x, y, other) && canHurt(self, other))
                                                {
                                                    DamageEvent(new DamageEventContext(other.parent, id, other.damage, 1, 1, -1, 1))
                                                }
                                            }
                                            instance_destroy()
                                        }
                                    }
                                    sword_angle = 180 * facing
                                    sword_xscale = -1.25 * facing
                                    swordpos.x = -3 + (timer0 - 4)
                                    swordpos.y = -6
                                    vsp = approach(vsp, 0, fric * global.dt)
                                    timer0 = approach(timer0, 12, global.dt * attack_speed)
                                }
                                else
                                {
                                    if(timer0 == 12)
                                        _sword_angle = sword_angle - 45 * facing
                                    sword_angle = 20 * facing
                                    sword_xscale = -1.25 * facing
                                    swordpos.x = -5
                                    swordpos.y = -9
                                    vsp = approach(vsp, 0, fric * global.dt)
                                    timer0 = approach(timer0, 16, global.dt * attack_speed)
                                }
                            }
                            else
                            {
                                sword_yscale = -1
                                image_index += 0.25 * global.dt * attack_speed

                                if(timer0 < 4)
                                {
                                    sword_angle = 100 * facing
                                    sword_xscale = -0.9 * facing
                                    swordpos.x = -5
                                    swordpos.y = -9
                                    timer0 = approach(timer0, 4, global.dt * attack_speed)
                                }
                                else if(timer0 < 8)
                                {
                                    if(timer0 == 4)
                                    {
                                        _audio_play_sound(sn_rivalSwing, 1, 0, 1, 0, random_range(1.1, 1.2))
                                    }
                                    sword_angle = 120 * facing
                                    sword_xscale = -1.25 * facing
                                    swordpos.x = -3 + (timer0 - 4)
                                    swordpos.y = -6
                                    timer0 = approach(timer0, 8, global.dt * attack_speed)
                                }
                                else if(timer0 < 12)
                                {
                                    if(timer0 == 8)
                                    {
                                        _sword_angle = sword_angle

                                        with(instance_create_depth(x, y - 14, depth, obj_empty, {sprite_index: spr_1pixel, image_xscale: 24 * facing, image_yscale: 14, parent: id, damage, team}))
                                        {
                                            with(par_unit)
                                            {
                                                if(place_meeting(x, y, other) && canHurt(self, other))
                                                {
                                                    DamageEvent(new DamageEventContext(other.parent, id, other.damage, 1, 1, -1, 1))
                                                }
                                            }
                                            instance_destroy()
                                        }
                                    }
                                    sword_angle = 190 * facing
                                    sword_xscale = -1.75 * facing
                                    swordpos.x = 5 - (timer0 - 8) * 2
                                    swordpos.y = -14
                                    vsp = approach(vsp, 0, fric * global.dt)
                                    timer0 = approach(timer0, 12, global.dt * attack_speed)
                                }
                                else
                                {
                                    sword_angle = 320 * facing
                                    sword_xscale = -1.25 * facing
                                    swordpos.x = -4
                                    swordpos.y = -14
                                    vsp = approach(vsp, 0, fric * global.dt)
                                    timer0 = approach(timer0, 16, global.dt * attack_speed)
                                }
                            }
                        }
                        else
                        {
                            sprite_index = _sp.jump
                            image_index = 0
                            timer0 = 0
                            state = "normal"
                            swfxtrail = 0
                        }
                    }}
                }
                state = "SKILL_blade"
            }
        }
        self.update = function(ins, obj) {
            ins.age = approach(ins.age, ins.duration, global.dt / 60)
            if(ins.age >= ins.duration || obj.state != "SKILL_blade")
            {
                with(ins) onExit(self, obj)
                return;
            }
        }
        self.onExit = function(ins, obj) {
            ins.age = 0
            obj.attack_state = noone
            obj.state = "normal"
        }
    }, rivalPrimarySkill)
    #endregion

    #region BENBOMEME
    var benbPrimarySkill = new Skill("benb.punch", function(def) {
        def.baseMaxStocks = 1
        def.baseStockCooldown = 0
        def.beginCooldownOnEnd = 0
        def.fullRestockOnAssign = 1
        def.isCombatSkill = 1
        def.mustKeyPress = 0
        def.rechargeStock = 1
        def.requiredStock = 0
        def.stockToConsume = 0
        def.slot = "primary"
        def.priority = -1
        def.buffer = 0
        def.spamCoeff = 0.4
    })

    var benbSecondarySkill = new Skill("benb.dkick", function(def) {
        def.baseMaxStocks = 1
        def.baseStockCooldown = 3.5
        def.beginCooldownOnEnd = 0
        def.fullRestockOnAssign = 1
        def.isCombatSkill = 1
        def.mustKeyPress = 0
        def.rechargeStock = 1
        def.requiredStock = 1
        def.stockToConsume = 1
        def.slot = "secondary"
        def.priority = 1
        def.buffer = 1
    })

    var benbPrimarySkillState = new State(function(def) {
        def.baseDuration = 15/60
        def.onEnter = function(ins, obj) {
            ins.duration = ins.baseDuration / obj.attack_speed

            with(obj)
            {
                screen_shake_set(1, 4)

                var f = instance_nearest(x, y, obj_playerfist)
                if(f)
                {
                    if(f.parent == id)
                        instance_destroy(f)
                }

                facing = sign(facing)
                state = "punch"
                image_speed = 0.4
                image_index = 0
                var canTurn = 0
                var no = 1
                if (duck == 0)
                {
                    if (sprite_index != _sp.punch_1)
                    {
                        sprite_index = _sp.punch_1
                    }
                    else
                    {
                        sprite_index = _sp.punch_2
                    }
                }
                else
                {
                    sprite_index = _sp.duckPunch
                }
                with (instance_create_depth(x, y, depth + 2, obj_playerfist))
                {
                    parent = other
                    team = other.team
                    knockdown = -1
                    knockback = 1

                    facing = other.facing

                    damage = other.damage
                }
                image_index = 0
                if (sprite_index == _sp.punch_1 || sprite_index == _sp.punch_2)
                {
                    canTurn = 1
                }
                if canTurn
                {
                    if (abs(hsp) < 1)
                    {
                        if input_dir == 1
                        {
                            facing = 1
                            if on_ground
                                hsp = approach(hsp, facing * 1, 1)
                        }
                        if input_dir == -1
                        {
                            facing = -1
                            if on_ground
                                hsp = approach(hsp, facing * 1, 1)
                        }
                    }
                }
            }
        }
    }, benbPrimarySkill)
    benbPrimarySkill.activationState = benbPrimarySkillState

    var benbSecondarySkillState = new State(function(def) {
        def.baseDuration = 5/60

        def.onEnter = function(ins, obj) {
            ins.duration = ins.baseDuration

            with(obj)
            {
                hsp = (spd * facing * 2.5)
                vsp = spd * 2.5
                duck = 0

                sprite_index = spr_benb_dkick
                mask_index = mask_player_duck
                image_index = 1

                __fakepunch = instance_create_depth(x, y, depth + 2, obj_empty, {sprite_index: spr_playerfist, image_speed: 1, image_index: 2})

                timer0 = 0

                __alreadyHit = []

                state = "SKILL_dkick"
                if(!variable_struct_exists(states, "SKILL_dkick"))
                {
                    states.SKILL_dkick = function() {with(other) {
                        can_jump = 0
                        can_walljump = 0
                        can_attack = 0
                        ghost = 0
                        duck = 0
                        fxtrail = 1

                        image_index = max(1, image_index + 0.5)

                        var e = instance_place(x, y, par_unit)
                        if(e && canHurt(self, e) && e.id != id)
                        {
                            if(!array_contains(__alreadyHit, e))
                            {
                                array_push(__alreadyHit, e)
                                e.__invuln = 19
                                DamageEvent(new DamageEventContext(id, e, damage, 1, 1, 0))
                            }
                            else
                            {
                                e.__invuln = approach(e.__invuln, 0, global.dt)
                                if(e.__invuln == 0)
                                {
                                    array_delete(__alreadyHit, array_find_index_by_value(e), 1)
                                }
                            }
                        }

                        if(instance_exists(__fakepunch))
                        {
                            __fakepunch.x = x + hsp
                            __fakepunch.y = y + vsp + 4
                            if(__fakepunch.image_index > 6)
                            {
                                __fakepunch.image_index = 2
                            }
                        }

                        if(on_ground)
                        {
                            instance_destroy(__fakepunch)
                            state = "SKILL_dkick_recover"
                            timer0 = 0
                            __alreadyHit = []
                            fxtrail = 0
                            image_index = 0
                            _audio_play_sound(sn_groundhit, 1, 0, 1.5)
                            screen_shake_set(3, 40)

                            var obj = instance_create_depth(x, y - 4, depth, obj_empty, {damage: base_damage * 2, parent: id, proc: 1, team})
                            with(obj)
                            {
                                sprite_index = spr_8x8
                                visible = 0
                                image_xscale = 5
                                image_yscale = 2

                                crit = 0

                                with(par_unit)
                                {
                                    if(on_ground && canHurt(self, other) && other.parent != id && place_meeting(x, y, other))
                                    {
                                        DamageEvent(new DamageEventContext(other.parent, self, other.damage, 1, other.crit, 0))
                                        vsp -= 8/max(24, mass) + max(0, 16/clamp(instance_distance(other), 6.4, 32) - 0.5)
                                    }
                                }
                            }
                            instance_destroy(obj)
                        }
                    }}
                }
                if(!variable_struct_exists(states, "SKILL_dkick_recover"))
                {
                    states.SKILL_dkick_recover = function() {with(other) {
                        can_jump = 0
                        can_walljump = 0
                        can_attack = 0
                        ghost = 0
                        duck = 0
                        hsp = approach(hsp, 0, ground_fric * global.dt)
                        vsp = 0

                        if(timer0 == 0)
                        {
                            landTimer = 20 / attack_speed

                            repeat(6)
                            {
                                with(instance_create_depth(x + random_range(-3, 4) * sign(facing), y, depth - 2, fx_dust))
                                {
                                    vx = random_range(-1, 1.5) * sign(other.facing)
                                    vy = random_range(-0.5, 0)
                                }
                            }
                        }
                        else
                        {
                            image_index = 1
                        }
                        timer0 += global.dt

                        if(timer0 >= 10 / attack_speed)
                        {
                            state = "normal"
                            timer0 = 0

                            hsp = 0
                            can_jump = 1
                            can_walljump = 1
                            can_attack = 1

                            sprite_index = _sp.duck
                            duck = 1
                            image_index = 1
                        }
                    }}
                }
            }
        }
        self.update = function(ins, obj) {
            ins.age = approach(ins.age, ins.duration, global.dt / 60)
            if(obj.state != "SKILL_dkick" && obj.state != "SKILL_dkick_recover")
            {
                with(ins) onExit(self, obj)
                return;
            }
        }
        self.onExit = function(ins, obj) {
            ins.age = 0
            obj.attack_state = noone
        }
    }, benbSecondarySkill)
    benbSecondarySkill.activationState = benbSecondarySkillState
    #endregion

    #region fx_3d_cube
    var fx_3d_cubePrimarySkill = new Skill("fx_3d_cube.primary", function(def) {
        def.baseMaxStocks = 3
        def.baseStockCooldown = 3
        def.beginCooldownOnEnd = 1
        def.fullRestockOnAssign = 1
        def.isCombatSkill = 1
        def.mustKeyPress = 0
        def.rechargeStock = 3
        def.requiredStock = 1
        def.stockToConsume = 1
        def.slot = "primary"
        def.priority = 0
        def.buffer = 0
    })

    var fx_3d_cubePrimarySkillState = new State(function(def) {
        def.baseDuration = 20/60
        def.onEnter = function(ins, obj) {
            ins.duration = ins.baseDuration / obj.attack_speed

            with(obj)
            {
                screen_shake_set(1, 5)

                var f = function() {
                    var _obj = instance_create_depth(x, y, depth - 3, obj_rocket)

                    with (_obj)
                    {
                        parent = other
                        team = other.team

                        damage = other.damage
                        proc = 1
                    }
                }

                f()

                setTimeout(f, 0.25)
                setTimeout(f, 0.5)
            }
        }
    }, fx_3d_cubePrimarySkill)
    fx_3d_cubePrimarySkill.activationState = fx_3d_cubePrimarySkillState
    #endregion

    Log("Startup/INFO", "Initialized character skills and skill states")
}

function initChars()
{
    global.chardefs = {
        base: new CharacterDef("base")
    }

    global.chardefs.dead = new CharacterDef("dead", function(def) {
        def.skills.primary = new SkillInstance(global.skilldefs[$ "dead.primary"])
        def.attack_states.primary = variable_clone(def.skills.primary.def.activationState)
    })

    global.chardefs.beebo = new CharacterDef("beebo", function(def) {
        def.stats = {
            hp_max: 100,
            regen_rate: 1,
            curse: 1,
            spd: 2,
            jumpspd: -3.7,
            firerate: 5,
            bombrate: 80,
            spread: 4,
            damage: 12,
            ground_accel: 0.12,
            ground_fric: 0.08,
            air_accel: 0.07,
            air_fric: 0.02,
            jumps_max: 1,
            grv: 0.2,
            attack_speed: 1,
            shield: 0,
            heat_max: 100,
            heat_rate: 1,
            cool_rate: 1
        }
        def.level_stats = {
            hp_max: 30,
            damage: 2.4,
            regen_rate: 0.2
        }

        def.skills = {
            primary:   new SkillInstance(global.skilldefs[$ "beebo.rapidfire"]),
            secondary: new SkillInstance(global.skilldefs[$ "beebo.bomb_throw"]),
            utility:   new SkillInstance(global.skilldefs[$ "beebo.quick_evade"]),
            special:   new SkillInstance(global.skilldefs[$ "beebo.hotswap"])
        }

        def.attack_states = {
            primary:   variable_clone(def.skills.primary.def.activationState),
            secondary: variable_clone(def.skills.secondary.def.activationState),
            utility:   variable_clone(def.skills.utility.def.activationState),
            special:   variable_clone(def.skills.special.def.activationState)
        }
    })

    global.chardefs.rival = new CharacterDef("rival", function(def) {
        def.stats = {
            hp_max: 100,
            regen_rate: 1,
            curse: 1,
            spd: 2,
            jumpspd: -3.7,
            firerate: 5,
            bombrate: 80,
            spread: 4,
            damage: 22,
            ground_accel: 0.12,
            ground_fric: 0.08,
            air_accel: 0.07,
            air_fric: 0.02,
            jumps_max: 1,
            grv: 0.2,
            attack_speed: 1,
            shield: 0,
        }
        def.level_stats = {
            hp_max: 30,
            damage: 2.4,
            regen_rate: 0.2
        }

        def.skills = {
            primary:   new SkillInstance(global.skilldefs[$ "rival.blade"]),
            secondary: new SkillInstance(global.skilldefs[$ "base"]),
            utility:   new SkillInstance(global.skilldefs[$ "base"]),
            special:   new SkillInstance(global.skilldefs[$ "base"])
        }

        def.attack_states = {
            primary:   variable_clone(def.skills.primary.def.activationState),
            secondary: variable_clone(def.skills.secondary.def.activationState),
            utility:   variable_clone(def.skills.utility.def.activationState),
            special:   variable_clone(def.skills.special.def.activationState)
        }
    })

    global.chardefs.benb = new CharacterDef("benb", function(def) {
        def.stats = {
            hp_max: 100,
            regen_rate: 1,
            curse: 1,
            spd: 2,
            jumpspd: -3.7,
            firerate: 5,
            bombrate: 80,
            spread: 4,
            damage: 15,
            ground_accel: 0.15,
            ground_fric: 0.12,
            air_accel: 0.07,
            air_fric: 0.02,
            jumps_max: 2,
            grv: 0.2,
            attack_speed: 1,
            shield: 0,
        }
        def.level_stats = {
            hp_max: 30,
            damage: 2.4,
            regen_rate: 0.2
        }

        def.skills = {
            primary:   new SkillInstance(global.skilldefs[$ "benb.punch"]),
		    secondary: new SkillInstance(global.skilldefs[$ "benb.dkick"]),
		    utility:   new SkillInstance(global.skilldefs[$ "base"]),
		    special:   new SkillInstance(global.skilldefs[$ "base"])
        }

        def.attack_states = {
            primary:   variable_clone(def.skills.primary.def.activationState),
            secondary: variable_clone(def.skills.secondary.def.activationState),
            utility:   variable_clone(def.skills.utility.def.activationState),
            special:   variable_clone(def.skills.special.def.activationState)
        }
    })

    global.chardefs.e_wall = new CharacterDef("e_wall", function(def) {
        def.stats = {
            hp_max: 200,
            regen_rate: 0,
            curse: 1,
            spd: 1,
            jumpspd: -1,
            firerate: 5,
            bombrate: 0,
            spread: 4,
            damage: 1,
            ground_accel: 0.12,
            ground_fric: 0.08,
            air_accel: 0.07,
            air_fric: 0.02,
            jumps_max: 1,
            grv: 0.2,
            attack_speed: 1,
            shield: 0,
        }
        def.level_stats = {
            hp_max: 20,
            damage: 0,
            regen_rate: 0
        }
    })

    global.chardefs.e_bombguy = new CharacterDef("e_bombguy", function(def) {
        def.stats = {
            hp_max : 480,
            regen_rate : 0,
            curse : 1,
            spd : 0.75,
            jumpspd : -1,
            firerate : 80,
            bombrate : 1,
            spread : 2,
            damage : 24,
            ground_accel : 0.12,
            ground_fric : 0.08,
            air_accel : 0.07,
            air_fric : 0.02,
            jumps_max : 1,
            grv : 0.2,
            attack_speed : 1,
            shield: 0,
        }
        def.level_stats = {
            hp_max: 144,
            damage: 2.4,
            regen_rate: 0
        }
    })

    global.chardefs.e_strikes_back = new CharacterDef("e_strikes_back", function(def) {
        def.stats = {
            hp_max : 80,
            regen_rate : 0,
            curse : 1,
            spd : 1,
            jumpspd : -1,
            firerate : 80,
            bombrate : 1,
            spread : 2,
            damage : 12,
            ground_accel : 0.12,
            ground_fric : 0.08,
            air_accel : 0.07,
            air_fric : 0.02,
            jumps_max : 1,
            grv : 0.2,
            attack_speed : 1,
            shield: 0,
        }
        def.level_stats = {
            hp_max: 24,
            damage: 2.4,
            regen_rate: 0
        }
    })

    global.chardefs.e_strikes_backer = new CharacterDef("e_strikes_backer", function(def) {
        def.stats = {
            hp_max : 2100,
            regen_rate : 0,
            curse : 1,
            spd : 1,
            jumpspd : -1,
            firerate : 80,
            bombrate : 1,
            spread : 2,
            damage : 25,
            ground_accel : 0.12,
            ground_fric : 0.08,
            air_accel : 0.07,
            air_fric : 0.02,
            jumps_max : 1,
            grv : 0.2,
            attack_speed : 1,
            shield: 0,
        }
        def.level_stats = {
            hp_max: 630,
            damage: 5,
            regen_rate: 0
        }
    })

    global.chardefs.e_player_chaser = new CharacterDef("e_player_chaser", function(def) {
        def.stats = {
            hp_max: 100,
            regen_rate: 1,
            curse: 1,
            spd: 2,
            jumpspd: -3.7,
            firerate: 5,
            bombrate: 80,
            spread: 4,
            damage: 12,
            ground_accel: 0.12,
            ground_fric: 0.08,
            air_accel: 0.07,
            air_fric: 0.02,
            jumps_max: 1,
            grv: 0.2,
            attack_speed: 1,
            shield: 0
        }
        def.level_stats = {
            hp_max: 30,
            damage: 2.4,
            regen_rate: 0.2
        }
    })

    global.chardefs.fx_3d_cube = new CharacterDef("fx_3d_cube", function(def) {
        def.stats = {
            hp_max: 140,
            regen_rate: 0,
            curse: 1,
            spd: 0.5,
            jumpspd: -3.7,
            firerate: 5,
            bombrate: 80,
            spread: 4,
            damage: 12,
            ground_accel: 0.12,
            ground_fric: 0.08,
            air_accel: 0.07,
            air_fric: 0.02,
            jumps_max: 1,
            grv: 0,
            attack_speed: 1,
            shield: 0
        }
        def.level_stats = {
            hp_max: 30,
            damage: 2.4,
            regen_rate: 0
        }

        def.skills.primary = new SkillInstance(global.skilldefs[$ "fx_3d_cube.primary"])
        def.attack_states.primary = variable_clone(def.skills.primary.def.activationState)
    })

    global.chardefs.e_dummy = new CharacterDef("e_dummy", function(def) {
        def.stats = {
            hp_max: 100,
            regen_rate: 0,
            curse: 1,
            spd: 1,
            jumpspd: -1,
            firerate: 5,
            bombrate: 0,
            spread: 4,
            damage: 1,
            ground_accel: 0.12,
            ground_fric: 0.08,
            air_accel: 0.07,
            air_fric: 0.02,
            jumps_max: 1,
            grv: 0.2,
            attack_speed: 1,
            shield: 0,
        }
        def.level_stats = {
            hp_max: 20,
            damage: 0,
            regen_rate: 0
        }
    })

    Log("Startup/INFO", "Initialized character definitions")
}
