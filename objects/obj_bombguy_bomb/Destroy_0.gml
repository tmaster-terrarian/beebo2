_size = 1
_dmg = damage
_fps = 0.25

if(bulleted)
{
    _size *= 1.3
    _fps = 0.167

    screen_shake_set(6, 60)
}
else
{
    screen_shake_set(4, 40)
}

_audio_play_sound(sn_bomb_explosion, 0, 0)
audio_stop_sound(throwsound)

with(instance_create_depth(x, y, depth - 1, obj_empty, {_size, _dmg, _fps, proc, parent, team, killtimer: 16 / _fps}))
{
    sprite_index = spr_fx_explosion
    image_index = other.bulleted
    image_speed = _fps
    image_xscale = _size
    image_yscale = _size

    with(par_unit)
    {
        if(place_meeting(x, y, other) && canHurt(self, other))
        {
            DamageEvent(new DamageEventContext(other.parent, id, other._dmg, other.proc, 1, 0))
        }
    }
}
