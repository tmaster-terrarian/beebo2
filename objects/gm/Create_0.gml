framerates = [60, 30, 15]
framerate_choice = 0

global.zoom = 1

current_bgm = noone
bgm_fading = 0

bgm_clear = function()
{
    audio_stop_sound(current_bgm)
}

bgm_set = function(index, loop = 1, gain = 1, offset = 0, pitch = 1)
{
    audio_stop_sound(current_bgm)
    current_bgm = audio_play_sound(index, 20, loop, gain, offset, pitch)
}

bgm_fade = function(index, fadetime, loop = 1, gain = 1, offset = 0, pitch = 1)
{
    audio_sound_gain(current_bgm, 0, fadetime * 1000)

    current_bgm = audio_play_sound(index, 20, loop, 0, offset, pitch)
    audio_sound_gain(current_bgm, gain, fadetime * 1000)
}

wave_creation = 0
wave_active = 0

rundata = new _rundata()
rundata.wave = 1
