event_inherited()
base_stats =
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

xp_max = 50
xp = 0

can_walljump = 1
duck = 0
hascontrol = 1

_sp =
{
    mask_default: mask_player,
    mask_duck: mask_player_duck,
    idle: spr_player,
    idle_lookup: spr_player_lookup
}

states =
{
    braindead : function()
    {
        fxtrail = 0
        can_jump = 0
        can_walljump = 0
        hsp = 0
        vsp = 0
    },
    normal : function()
    {
        can_walljump = 1
        if (duck > 1)
            mask_index = _sp.mask_duck
        else
            mask_index = _sp.mask_default
        
    }
}
state = states.normal
