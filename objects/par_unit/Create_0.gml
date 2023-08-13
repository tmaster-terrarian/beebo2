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
    grv : 0
}
level_stats =
{
    hp_max: 30,
    damage: 2.4
}

level = 1
t = 0
regen = 1
accel = 0
fric = 0
hp = 1
crit_chance = 0
jumps = 1
fxtrail = 0
can_jump = 0

_apply_stats = function()
{
    hp_max = stats.hp_max
    hp = hp_max
    regen_rate = stats.regen_rate
    curse = stats.curse
    damage = stats.damage
    base_damage = stats.damage
    spread = stats.spread
    firerate = stats.firerate
    spd = stats.spd
    jumpspd = stats.jumpspd
    ground_accel = stats.ground_accel
    ground_fric = stats.ground_fric
    air_accel = stats.air_accel
    air_fric = stats.air_fric
    jumps_max = stats.jumps_max
    jumps = jumps_max
    grv = stats.grv
}
_apply_stats()

_apply_level = function(_newlevel)
{
    hp_max = stats.hp_max + level_stats.hp_max * (_newlevel - 1)
    hp = min(hp + hp_max * 0.1, hp_max)

    base_damage = stats.damage + level_stats.damage * (_newlevel - 1)

    level = _newlevel
}

states =
{
    normal : function() {}
}

state = states.normal
timer0 = 0 // most powerful fucker ive ever seen

_setstate = function(_state, _resettimer = 0, _resetframe = 0)
{
    state = _state
    if(_resettimer)
        timer0 = 0
    if(_resetframe)
        image_index = 0
}
