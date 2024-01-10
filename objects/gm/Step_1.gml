global.dt = (delta_time / 1000000) * 60 * (global.timescale + 1 * keyboard_check(vk_rshift) * global.draw_debug)
global.sc = window_get_width() / SC_W

global.gameTimer += global.dt

if(keyboard_check_pressed(vk_enter))
{
    wavetimer = 0
}

if(!global.pause && global.runEnabled)
{
    global.t += global.dt

    if(wavetimer > 0)
        wavetimer = max(wavetimer - global.dt, 0)
    if(wave5delay > 0)
        wave5delay = max(wave5delay - global.dt, 0)

    if(wavetimer == 0)
    {
        wavetimer = -1
        if(!doNotIncreaseWave)
            global.wave++
        doNotIncreaseWave = 0

        var waveType = 0
        switch((global.wave - 1) % 5)
        {
            case 4:
            {
                waveType = 1
                break;
            }
            default:
            {
                waveType = 0
                break;
            }
        }
        mainDirector.waveType = waveType
        mainDirector.Enable()
    }

    if(wave5delay == 0 && wavetimer == -1)
    {
        wave5delay = -1
        mainDirector.Enable()
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

    if(mainDirector.enabled)
        mainDirector.Step()

    // if the director is totally pooped, proceed to next wave
    if((mainDirector.credits < 8 && mainDirector.generatorTickerSeconds >= mainDirector.wavePeriods[mainDirector.waveType]) && wavetimer == -1)
    {
        if(global.enemyCount == 0)
        {
            killzoneTimer = MINUTE / 2
            if(instance_exists(fx_death_fog))
                fx_death_fog.done = 1

            mainDirector.Disable()
            wavetimer = 600

            var pcount = array_length(global.players)
            for(var i = 0; i < pcount; i++)
            {
                instance_create_depth(obj_camera.tx + i * 24 - (pcount - 1) * 12, 96, depth, obj_item, {item_id: item_id_get_random(1, global.itemdata.item_tables.chest_small)})
            }
        }
        else
        {
            if(global.enemyCount == 1)
                with(par_unit)
                {
                    if(team == Team.enemy)
                        hp = -10000000
                }
            if(killzoneTimer > 0)
                killzoneTimer = approach(killzoneTimer, 0, global.dt)
            if(killzoneTimer == 0)
            {
                killzoneTimer = -1
                instance_create_depth(0, 0, 0, fx_death_fog)
            }
        }
    }
}

with(par_unit)
{
    if(object_get_parent(object_index) == obj_player)
    {
        if(xp > xpTarget)
        {
            xp = 0
            xpTarget *= 1.55
            _apply_level(level + 1)
        }
    }
    else
    {
        if(level < global.enemyLevel)
            _apply_level(global.enemyLevel)
    }

    for(var i = 0; i < array_length(items); i++)
    {
        getdef(items[i].item_id, deftype.item).step(id, items[i].stacks)
        items[i].triggered = 0
    }


    var curseFac = 1
    curse = stats.curse * curseFac


    var hpFac = 1

    hpFac += 0.25 * item_get_stacks("boost_health", self)

    hpFac *= 1 + elite * 3

    hp_max = (base_hp_max * hpFac) / curse


    var shieldFac = 0
    max_shield = hp_max * shieldFac


    total_hp_max = hp_max + max_shield
    total_hp = hp + shield


    var regenFac = 1 + level_stats.regen_rate * (level - 1)
    regen_rate = (stats.regen_rate * regenFac) / curse


    var spdInc = 1

    if(item_get_stacks("hyperthreader", self))
        spdInc += 0.5 + (item_get_stacks("hyperthreader", self) - 1) * 0.25


    var spdDec = 1


    var spdFac = spdInc/spdDec

    spd = stats.spd * spdFac

    var spdMul = max(spd / stats.spd, 1)
    ground_accel = stats.ground_accel * spdMul
    ground_fric = stats.ground_fric   * spdMul
    air_accel = stats.air_accel       * spdMul
    air_fric = stats.air_fric         * spdMul


    var jumpSpdFac = 1

    jumpSpdFac += item_get_stacks("hyperthreader", self) * 0.1

    jumpspd = stats.jumpspd * jumpSpdFac


    base_damage = (stats.damage + level_stats.damage * (level - 1))


    var dmgFac = 1

    dmgFac += 0.25 * item_get_stacks("boost_damage", self)

    dmgFac *= 1 + elite

    damage = base_damage * dmgFac


    var newCrit = 0

    newCrit += 0.1 * item_get_stacks("lucky_clover", self)

    crit_chance = clamp(newCrit, 0.01 * (object_get_parent(object_index) == obj_player), 1)


    var critModFac = 1

    crit_modifier = 1 * critModFac


    var spreadFac = 1

    spreadFac -= item_get_stacks("beeswax", self) * 0.1

    if(spreadFac < 0) spreadFac = 0
    spread = stats.spread * spreadFac


    var atkSpdFac = 1
    attack_speed = stats.attack_speed * atkSpdFac

    firerate = stats.firerate * attack_speed


    var bombrateFac = 1
    bombrate = stats.bombrate * bombrateFac
}

if(!global.pause)
{
    if(array_length(item_pickup_queue) > 0 && !instance_exists(fx_pickuptext))
    {
        var item = array_shift(item_pickup_queue)

        var _i = instance_create_depth(0, 0, 0, fx_pickuptext)
        _i.name = getdef(item.item_id, deftype.item).displayname
        _i.shortdesc = getdef(item.item_id, deftype.item).pickup
        _i.item_id = item.item_id
        _i.target = item.target
    }
}
