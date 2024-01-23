if(audio_group_is_loaded(audiogroup_music))
{
    audio_group_set_gain(audiogroup_music, global.bgm_volume, 0)
    room_goto(Room1)

    // set_music(bgm_test, 1, 1)
}
