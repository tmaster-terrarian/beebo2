if(facing != 0)
    image_xscale = sign(facing) * _image_xscale

event_inherited();

if(__lastspr == sprite_index && floor(__lastframe) != floor(image_index))
    onFrameChange()

combat_state_changed = 0

fxtrailtimer = approach(fxtrailtimer, 0, global.dt)
if(fxtrail && fxtrailtimer == 0)
{
    fxtrailtimer = 4

    create_fxtrail(id)
}

if(regen && hp > 0) heal_event(id, regen_rate/60 * global.dt, HealColor.regen)
if(hp > hp_max) hp = hp_max

if(hp > 0)
    regen = 1

if(_shield_recharge)
{
    // play shield recharge sound here
    if(shield < max_shield)
        shield = approach(shield, max_shield, (max_shield - _shield) / 120 * global.dt)
    else
    {
        _shield = max_shield
        _shield_recharge = 0
    }
}
