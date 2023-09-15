_size = 0.75
_dmg = damage
_fps = 0.5

screen_shake_set(2, 20)

audio_play_sound(sn_bomb_explosion, 0, 0)

with(instance_create_depth(x, y, depth - 1, obj_empty, {_size, _dmg, _fps, proc, parent, _team, team, killtimer: 16 / _fps}))
{
    sprite_index = spr_fx_explosion
    image_index = other.bulleted
    image_speed = _fps
    image_xscale = _size
    image_yscale = _size

    with(par_unit)
    {
        if(place_meeting(x, y, other) && team != other.team)
        {
            damage_event(other.parent, id, proctype.onhit, other._dmg, other.proc, other._team == other.team)
        }
    }
}
