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
total_hp = hp
hp_change = noone
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

_onCombatExit = function()
{
    shield_regen = 1
    onCombatExit()
}

onFrameChange = function() {}

_apply_stats = function()
{
    hp_max = stats.hp_max
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
        heal_event(self, base_hp_max * 0.25 + 0.2 * (item_get_stacks("heal_on_level", self) - 1))

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
if(team == Team.enemy)
{
    items = variable_clone(global.enemyItems)
}

buffs = []

skill_queue = []
