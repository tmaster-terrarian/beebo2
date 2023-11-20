event_inherited()
stats = variable_clone(global.chardefs.base.stats)
level_stats = variable_clone(global.chardefs.base.level_stats)
skills = variable_clone(global.chardefs.base.skills)
attack_states = variable_clone(global.chardefs.base.attack_states)

t = 0
regen = 1
accel = 0
fric = 0
hp = 1
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

_apply_stats = function()
{
    hp_max = stats.hp_max
    base_hp_max = hp_max
    hp = hp_max
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

    if(item_get_stacks(self, "heal_on_level"))
        heal_event(self, base_hp_max * 0.1 * item_get_stacks(self, "heal_on_level"))

    hp = min(hp, base_hp_max)

    level = _newlevel
}

states = {
    normal: function() {}
}

attack_states = {}

state = states.normal
attack_state = noone
timer0 = 0 // most powerful fucker ive ever seen

_setstate = function(_state, _resettimer = 0, _resetframe = 0)
{
    state = _state
    if(_resettimer)
        timer0 = 0
    if(_resetframe)
        image_index = 0
}

fire_angle = 0
gun_pos = {x:0,y:0}

items = []
buffs = []

skill_queue = []
