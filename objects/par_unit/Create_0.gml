event_inherited()
stats = variable_clone(global.chardefs.base.stats)
level_stats = variable_clone(global.chardefs.base.level_stats)
skills = variable_clone(global.chardefs.base.skills)
attack_states = variable_clone(global.chardefs.base.attack_states)

t = 0
canRegen = 1
regen = canRegen
accel = 0
fric = 0
hp = 1
total_hp = hp
hp_change = "noone"
hp_change_delay = 0
crit_chance = 0
jumps = 1
fxtrail = 0
fxtrailtimer = 0
can_jump = 1
firedelay = 0
invincible = 0
ded = 0
attack_speed = 1
flash = 0
xp = 0
money = 0
mass = 10
_image_xscale = 1
max_shield = 0
shield = 0
drawhp = 0
__lastframe = image_index
__lastspr = sprite_index
oneshotprotection = 0
crit_modifier = 1
hitstun = 0
stun_immune = 0
_shield = shield
_shield_recharge = 0
_shield_recharge_handler = -1

fucked = 0
can_use_skills = 1
contributed = 0
target = noone

bonus_stocks = {
    primary: 0,
    secondary: 0,
    utility: 0,
    special: 0
}

in_combat = 0
combat_delay = t_inframes(5, TimeUnits.seconds)
combat_timer = 0
combat_state_changed = 0

invokeOnCombatEnter = function()
{
    in_combat = 1
    combat_state_changed = 1
    combat_timer = combat_delay
    onCombatEnter()
}

onCombatEnter = function() {}
onCombatExit = function() {}
onHurt = function(context) {}

onReceiveBuff = function(buff_id, context, duration, stacks)
{
    switch(buff_id)
    {
        case "fire":
        {
            if(buff_get_stacks(buff_id, id)) break;

            if(instance_exists(bigFlamo1)) bigFlamo1.stop()
            if(instance_exists(bigFlamo2)) bigFlamo2.stop()

            bigFlamo1 = instance_create_depth((bbox_left + bbox_right) / 2, (bbox_top + bbox_bottom) / 2, depth + 3, fx_particle_emitter, {
                owner: self,
                posGlobal: 1,
                interval: 1,
                max_particles: 40,
                spr: spr_fx_steam,
                img: 0,
                imgE: 0,
                color: #EDCA07,
                colorE: #38282E,
                life: 3.5/6,
                lifeR: 0.5/6,
                scale: 0.75,
                scaleR: 0.05,
                scaleE: 0.1,
                scaleER: 0.05,
                spd: 0.75,
                spdR: 0.25,
                spdE: 0.4,
                spdER: 0.05,
                grvY: -0.13,
                dir: 90,
                dirR: 5,
                xR: (bbox_right - bbox_left) / 2,
                yR: (bbox_bottom - bbox_top) / 2,
            })

            bigFlamo2 = instance_create_depth((bbox_left + bbox_right) / 2, bbox_top, depth + 4, fx_particle_emitter, {
                owner: self,
                posGlobal: 1,
                interval: 6,
                max_particles: 40,
                spr: spr_fx_steam,
                img: 0,
                imgE: 2,
                color: #3A1F27,
                colorE: #160A0D,
                alphaE: 0.1,
                life: 3.5/6,
                lifeR: 0.5/6,
                scale: 1,
                scaleR: 0.05,
                scaleE: 0.95,
                scaleER: 0.05,
                spd: 0.55,
                spdR: 0.05,
                spdE: 0.4,
                spdER: 0.05,
                grvY: -0.13,
                dir: 90,
                dirR: 5,
                xR: (bbox_right - bbox_left) / 2,
                yR: 8,
            })

            _audio_play_sound(sn_burning_start, 0, false, 2)

            break;
        }
    }
}

_onCombatExit = function()
{
    shield_regen = 1
    onCombatExit()
}

onFrameChange = function() {}

_apply_stats = function()
{
    hp_max = stats.hp_max * (1 + elite * 3)
    base_hp_max = hp_max
    total_hp_max = hp_max
    hp = hp_max
    total_hp = hp
    hp_change = hp
    regen_rate = stats.regen_rate
    curse = stats.curse
    damage = stats.damage
    base_damage = stats.damage
    spread = stats.spread
    firerate = stats.firerate
    bombrate = stats.bombrate
    spd = stats.spd
    jumpspd = stats.jumpspd
    ground_accel = stats.ground_accel
    ground_fric = stats.ground_fric
    air_accel = stats.air_accel
    air_fric = stats.air_fric
    jumps_max = stats.jumps_max
    jumps = jumps_max
    grv = stats.grv
    attack_speed = stats.attack_speed
    mass = ((bbox_bottom - bbox_top) + (bbox_right - bbox_left)) / 2
    max_shield = stats.shield * hp_max
    shield = max_shield

    bonus_stocks = {
        primary: 0,
        secondary: 0,
        utility: 0,
        special: 0
    }
}
_apply_stats()

_apply_level = function(_newlevel)
{
    var _oldhp_max = hp_max
    var _oldhp = hp
    base_hp_max = stats.hp_max + level_stats.hp_max * (_newlevel - 1)
    if(base_hp_max > _oldhp_max)
        hp = _oldhp / _oldhp_max * base_hp_max

    if(item_get_stacks("heal_on_level", self))
        heal_event(self, base_hp_max * 0.25 + 0.2 * (item_get_stacks("heal_on_level", self) - 1), HealColor.generic)

    hp = min(hp, base_hp_max)

    level = _newlevel
}

states = {
    normal: function() {}
}

attack_states = {}

state = states.normal
attack_state = noone
timer0 = 0

_setstate = function(_state, _resettimer = 0, _resetframe = 0)
{
    state = _state
    if(_resettimer)
        timer0 = 0
    if(_resetframe)
        image_index = 0
}

fire_angle = 0

items = []
if(team == Team.enemy)
{
    items = variable_clone(global.enemyItems)
}

buffs = []

skill_queue = []

INPUT =
{
    LEFT: 0,
    RIGHT: 0,
    UP: 0,
    DOWN: 0,
    JUMP: 0,
    FIRE: 0,
    PRIMARY: 0,
    SECONDARY: 0,
    UTILITY: 0,
    SPECIAL: 0
}

_processSkills = function()
{
    var names = ["primary", "secondary", "utility", "special"]
    for(var i = 0; i < array_length(names); i++)
    {
        var skill = skills[$ names[i]]
        var def = skill.def

        if(skill.cooldown > 0)
            skill.cooldown = approach(skill.cooldown, 0, global.dt / 60)
        else if(skill.stocks < def.baseMaxStocks + bonus_stocks[$ names[i]])
        {
            skill.cooldown = def.baseStockCooldown
            skill.stocks = min(skill.stocks + def.rechargeStock, def.baseMaxStocks + bonus_stocks[$ names[i]])
        }

        var inputPressed = INPUT[$ string_upper(names[i])]

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

    for(var i = 0; i < array_length(names); i++)
    {
        var skill = skills[$ names[i]]
        var def = skill.def

        var inputHeld = INPUT[$ string_upper(names[i])]
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
}

bigFlamo1 = noone
bigFlamo2 = noone
