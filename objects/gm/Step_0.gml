if(keyboard_check_pressed(vk_f2))
{
    global.draw_debug = !global.draw_debug
    ini_open("save.ini")
    ini_write_real("debug", "draw_debug", global.draw_debug)
    ini_close()
}

//192 = `
if(keyboard_check_pressed(192))
{
    global.showDebugOverlay = !global.showDebugOverlay
    show_debug_log(global.showDebugOverlay)
}

if(keyboard_check(vk_rshift))
{
    global.timescale = 2
}
if(keyboard_check_released(vk_rshift))
{
    global.timescale = 1
}

var _fpsswitch = keyboard_check_pressed(ord("P")) - keyboard_check_pressed(ord("O"))

if(global.draw_debug)
{
    if(abs(_fpsswitch))
    {
        framerate_choice += _fpsswitch
        if(framerate_choice >= array_length(framerates))
            framerate_choice = 0
        if(framerate_choice < 0)
            framerate_choice = array_length(framerates) - 1
        game_set_speed(framerates[framerate_choice], gamespeed_fps)
    }
}

if(keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_start) || gamepad_button_check_pressed(1, gp_start))
{
    global.pause = !global.pause
    if(global.pause)
    {
        audio_play_sound(sn_pause, 10, 0, 1, 0, 1)
        audio_sound_pitch(current_bgm, 0)
        with(all)
        {
            __image_speed = image_speed
            image_speed = 0
            __speed = speed
            speed = 0
        }
        time_source_pause(time_source_game)
    }
    else
    {
        audio_play_sound(sn_pause, 10, 0, 1, 0, 2)
        audio_sound_pitch(current_bgm, 1)
        with(all)
        {
            image_speed = __image_speed
            speed = __speed
        }
        time_source_resume(time_source_game)
    }
}
