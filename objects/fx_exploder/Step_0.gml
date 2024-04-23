event_inherited();


_interval = approach(_interval, interval, global.dt)

if(_interval == interval)
{
    _interval = 0

    screen_shake_set(4, interval)

    if(snd_index)
        audio_play_sound(snd_index, 0, 0)
    with(instance_create_depth(random_range(bbox_left, bbox_right), random_range(bbox_top, bbox_bottom) + 4, depth, obj_empty, {killtimer: 16 / 0.5}))
    {
        sprite_index = spr_fx_explosion
        image_speed = 0.5
    }
}
