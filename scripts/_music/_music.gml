function set_music(ind, loop = 1, crossfade = 0)
{
    global.__oldBGM = global.BGM
    if(global.__oldBGM != -1)
	    audio_sound_gain(global.__oldBGM, 0, crossfade * 1000)

    global.BGM = audio_play_sound_on(global.BGM_EMITTER, ind, 10, loop, 0)
	audio_sound_gain(global.BGM, 1, crossfade * 1000)

    setTimeout(function() {if(global.__oldBGM != -1) audio_stop_sound(global.__oldBGM); global.__olfBGM = -1}, crossfade + 1/60)
}

function stop_music(fade = 0)
{
	audio_sound_gain(global.BGM, 0, fade * 1000)

    setTimeout(function() {audio_stop_sound(global.BGM); global.BGM = -1}, fade + 1/60)
}
