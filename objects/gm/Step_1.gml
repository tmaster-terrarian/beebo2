global.dt = (delta_time / 1000000) * 60 * global.timescale
global.sc = window_get_width() / SC_W

if(keyboard_check_pressed(vk_enter))
{
    wavetimer = 0
}

if(!global.pause)
{
    global.t += global.dt

    if(wavetimer > 0)
        wavetimer = max(wavetimer - global.dt, 0)

    if(wavetimer == 0)
    {
        wavetimer = -1
        global.wave++

        var waveType = 0
        var shopWave = 0
        switch((global.wave - 1) % 5)
        {
            case 3:
            {
                waveType = 0
                shopWave = 1
                break;
            }
            case 4:
            {
                waveType = 1
                shopWave = 0
                break;
            }
            default:
            {
                waveType = 0
                shopWave = 0
                break;
            }
        }
        if(!shopWave)
        {
            mainDirector.waveType = waveType
            mainDirector.Enable()
        }
        else
        {
            mainDirector.Disable()
            wavetimer = 900
        }
    }

    var waveFac = 1.5 * global.wave
    var diffFac = 0.0506 * global.difficultySetting
    global.difficultyCoeff = (1 + diffFac * waveFac) * power(1.02, global.wave) // ror2 is so cool man

    global.enemyLevel = min(1 + round((global.difficultyCoeff - 1)/0.33), 9999)

    global.enemyCount = 0
    with(par_unit)
    {
        if(team == Team.enemy)
        {
            global.enemyCount++
        }
    }

    mainDirector.Step()

    // if the director is totally pooped and we are not on a shop wave, proceed to next wave
    if((mainDirector.credits < 10 && mainDirector.generatorTickerSeconds >= mainDirector.wavePeriods[mainDirector.waveType]) && wavetimer == -1 && global.wave % 5 != 3)
    {
        if(global.enemyCount == 0)
        {
            killzoneTimer = MINUTE
            // destroy fog of death

            mainDirector.Disable()
            wavetimer = 600
        }
        else
        {
            if(killzoneTimer > 0)
                killzoneTimer = approach(killzoneTimer, 0, global.dt)
            if(killzoneTimer == 0)
            {
                killzoneTimer = -1
                // create fog of death here
            }
        }
    }
}

with(par_unit)
{
    if(team == Team.enemy)
    {
        level = global.enemyLevel
    }

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
