if(facing != 0)
    image_xscale = sign(facing)

event_inherited();

combat_state_changed = 0

fxtrailtimer = approach(fxtrailtimer, 0, global.dt)
if(fxtrail && fxtrailtimer == 0)
{
    fxtrailtimer = 4

    create_fxtrail(id)
}
