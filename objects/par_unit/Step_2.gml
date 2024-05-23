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

if(canRegen && hp > 0) heal_event(id, regen_rate/60 * global.dt, HealColor.regen)
if(hp > hp_max) hp = hp_max

if(hp > 0)
{
    canRegen = 1
}

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

if(instance_exists(bigFlamo1))
{
    bigFlamo1.x = (bbox_left + bbox_right) / 2
    bigFlamo1.y = (bbox_top + bbox_bottom) / 2
    bigFlamo1.xR = (bbox_right - bbox_left) / 2
    bigFlamo1.yR = (bbox_bottom - bbox_top) / 2
}
if(instance_exists(bigFlamo2))
{
    bigFlamo2.x = (bbox_left + bbox_right) / 2
    bigFlamo2.y = bbox_top
    bigFlamo2.xR = (bbox_right - bbox_left) / 2
}

INPUT.PRIMARY = 0
INPUT.SECONDARY = 0
INPUT.UTILITY = 0
INPUT.SPECIAL = 0
