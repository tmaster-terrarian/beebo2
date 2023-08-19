if(keyboard_check_pressed(vk_f2))
{
    global.draw_debug = !global.draw_debug
    ini_open("save.ini")
    ini_write_real("debug", "draw_debug", global.draw_debug)
    ini_close()
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

switch(game_get_speed(gamespeed_fps))
{
    case 60: case 30: case 15:
    {
        global.fx_bias = 0
        break;
    }
    case 144:
    {
        global.fx_bias = 0.41
        break;
    }
}
