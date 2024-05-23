_size = 0.75
_fps = 0.33

_audio_play_sound(sn_bomb_explosion, 0, 0)

screen_shake_set(3, 30)

with(instance_create_depth(x, y, depth - 1, obj_empty, {_size, _fps, killtimer: 16 / _fps}))
{
    sprite_index = spr_fx_explosion
    image_speed = _fps
    image_xscale = _size
    image_yscale = _size
}
