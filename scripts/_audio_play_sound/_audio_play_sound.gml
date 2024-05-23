function _audio_play_sound(index, priority, loop, gain = 1, offset = 0, pitch = 1, listener_mask = 1)
{
    return audio_play_sound(index, priority, loop, gain, offset, pitch * global.timescale, listener_mask)
}
