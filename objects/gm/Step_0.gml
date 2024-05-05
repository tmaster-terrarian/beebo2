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
    // global.showDebugOverlay = !global.showDebugOverlay
    // show_log(global.showDebugOverlay)

    DamageEvent(new DamageEventContext(noone, global.players[0], 50, 1, 0, 0, 0).damageColor(DamageColor.playerhurt))
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

_money += (global.money - _money) * 0.2
if(abs(global.money - _money) < 0.01)
    _money = global.money

if(keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_start) || gamepad_button_check_pressed(1, gp_start))
{
    if(UILayer == 0)
        togglePause()
    else UILayer = 0
}

gifTicker++
if(keyboard_check_pressed(vk_f3))
{
	recording = !recording
	if(recording)
	{
		gifTicker = 0
		gifSaver.startRecording()
	}
	else
	{
		gifSaver.stopRecording()
	}
}

if(global.BGM_LOWPASS.cutoff < global.BGM_LOWPASS_CUTOFF_TARGET)
{
    global.BGM_BUS.effects[0].bypass = 0
    global.BGM_LOWPASS.cutoff = min(global.BGM_LOWPASS.cutoff * 1.15 * global.dt, global.BGM_LOWPASS_CUTOFF_TARGET)
}
else if(global.BGM_LOWPASS.cutoff > global.BGM_LOWPASS_CUTOFF_TARGET)
{
    global.BGM_BUS.effects[0].bypass = 0
    global.BGM_LOWPASS.cutoff = max(global.BGM_LOWPASS.cutoff / 1.15 * global.dt, global.BGM_LOWPASS_CUTOFF_TARGET)
}
if(global.BGM_LOWPASS.cutoff >= 20000)
{
    global.BGM_BUS.effects[0].bypass = 1
}

global.BGM_LOWPASS.cutoff = clamp(global.BGM_LOWPASS.cutoff, 400, 20000)

UILayers[UILayer].step()
