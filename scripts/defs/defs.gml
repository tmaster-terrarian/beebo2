function initSkills()
{
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
        def.baseDuration = 5/60
        def.onEnter = function(ins, obj) {
            ins.duration = ins.baseDuration / obj.attack_speed

            with(obj)
            {
                screen_shake_set(1, 5)
                recoil = 3

                var v = spread
                var _obj = instance_create_depth(x + lengthdir_x(14, fire_angle) + gun_pos.x * sign(facing), y + lengthdir_y(14, fire_angle) + gun_pos.y - 1, depth - 3, obj_bullet)

                with (_obj)
                {
                    parent = other
                    team = other.team
                    audio_play_sound(sn_player_shoot, 1, false);

                    _speed = 12;
                    direction = other.fire_angle + random_range(-v, v);
                    image_angle = direction;

                    damage = other.damage
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

                var _obj = instance_create_depth(x + lengthdir_x(12, fire_angle) + gun_pos.x * sign(facing), y + lengthdir_y(12, fire_angle) + gun_pos.y - 1, depth - 2, obj_bomb, {damage_boosted : ((heat > 20) ? heat : 0)})

                with(_obj)
                {
                    parent = other
                    team = other.team
                    audio_play_sound(sn_throw, 0, 0, 1, 0, 1)

                    hsp = lengthdir_x(2, other.fire_angle) + (other.hsp * 0.5)
                    vsp = lengthdir_y(2, other.fire_angle) + (other.vsp * 0.25) - 1

                    damage = other.damage * (2 + 3 * (other.heat/other.heat_max))

                    bulleted_delay = 20
                }
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
                    audio_play_sound(sn_steam, 0, false, heat/heat_max)
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
                        if(e && e.team != team && !array_contains(__utilityHit, e))
                        {
                            array_push(__utilityHit, e)
                            damage_event(new DamageEventContext(id, e, proctype.onhit, base_damage * 0.5, 1, 1, 0))
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
    #endregion

    #region RIVAL
    
    #endregion

    LogInfo("Startup", "Initialized character skills and skill states")
}

function initChars()
{
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
            heat_max: 100,
            heat_rate: 1,
            cool_rate: 1
        }
        def.level_stats = {
            hp_max: 30,
            damage: 2.4
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
            damage: 12,
            ground_accel: 0.12,
            ground_fric: 0.08,
            air_accel: 0.07,
            air_fric: 0.02,
            jumps_max: 1,
            grv: 0.2,
            attack_speed: 1
        }
        def.level_stats = {
            hp_max: 30,
            damage: 2.4
        }
    })

    LogInfo("Startup", "Initialized character definitions")
}

