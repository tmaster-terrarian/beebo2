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
