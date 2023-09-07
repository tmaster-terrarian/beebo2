global.dt = (delta_time / 1000000) * 60 * global.timescale * !global.pause
global.sc = window_get_width() / SC_W

global.t += global.dt * !global.pause

with(par_unit)
{
    var hpFac = 1
    hp_max = (stats.hp_max + level_stats.hp_max * (level - 1)) * hpFac

    var regenFac = 1 + 0.2 * (level - 1)
    regen_rate = stats.regen_rate * regenFac

    var spdFac = 1
    spd = stats.spd * spdFac
    ground_accel = stats.ground_accel * (spd / stats.spd)
    ground_fric = stats.ground_fric * (spd / stats.spd)
    air_accel = stats.air_accel * (spd / stats.spd)
    air_fric = stats.air_fric * (spd / stats.spd)

    base_damage = (stats.damage + level_stats.damage * (level - 1))

    var dmgFac = 1
    damage = base_damage * dmgFac

    var newCrit = 0
    crit_chance = clamp(newCrit, 0, 1)
    if(crit_chance == 0) crit_chance += 0.01

    var spreadFac = 1
    if(spreadFac < 0) spreadFac = 0

    spread = stats.spread * spreadFac

    var firerateFac = 1
    firerate = stats.firerate * firerateFac
    if(gun_upgrade != "")
    {
        firerate = getdef(gun_upgrade, 2).firerate * firerateFac
    }

    var bombrateFac = 1
    bombrate = stats.bombrate * bombrateFac
    if(gun_upgrade != "")
    {
        bombrate = getdef(gun_upgrade, 2).bombrate * bombrateFac
    }
}

if(gamepad_button_check_any_pressed())
{
    global.controller = true
}
if(keyboard_check_pressed(vk_anykey) || mouse_check_button_pressed(mb_any))
{
    global.controller = false
}
