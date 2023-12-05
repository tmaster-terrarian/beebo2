framerates = [60, 30, 15]
framerate_choice = 0

global.zoom = 1
global.gameTimer = 0

global.sctint = c_white
global.sctint_alpha = 0

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

global.wave = 0
global.runEnabled = 0

wavetimer = 600
killzoneTimer = MINUTE

mainDirector = new Director(0, 0.1, 0.75, new range(3, 4), new range(0.24, 0.5), 10)

global.lastsecond = current_second

global.showDebugOverlay = 0

togglePause = function()
{
    global.pause = !global.pause
    if(global.pause)
    {
        audio_play_sound(sn_pause, 10, 0, 1, 0, 1)
        audio_sound_pitch(current_bgm, 0)
        time_source_pause(time_source_game)

        UILayer = 0
    }
    else
    {
        audio_play_sound(sn_pause, 10, 0, 1, 0, 2)
        audio_sound_pitch(current_bgm, 1)
        time_source_resume(time_source_game)

        instance_activate_all();
        surface_free(pauseSurface);
        pauseSurface = -1;

        UILayer = 0
    }
}

#region UI INIT

UILayer = 0
UILayers = []

pauseUI = new UI()

var button1 = new UIButton2(SC_W/2 - 26, SC_H/2 - 32, 51, 11)
button1.on_confirm = function()
{
    gm.togglePause()
}
button1.label = string_loc("ui.pause.resume")

var button2 = new UIButton2(SC_W/2 - 26, SC_H/2 - 20, 51, 11)
button2.on_confirm = function()
{
    with(gm)
    {
        UILayers[UILayer].enabled = 0
        UILayers[UILayer].draw = 0
        UILayer = 1
        UILayers[1].enabled = 1
        UILayers[1].draw = 1
    }
}
button2.label = string_loc("ui.pause.options")

var button3 = new UIButton2(SC_W/2 - 26, SC_H/2 - 8, 51, 11)
button3.label = string_loc("ui.pause.quit_title")

var button4 = new UIButton2(SC_W/2 - 26, SC_H/2 + 4, 51, 11)
button4.label = string_loc("ui.pause.quit_game")

pauseUI.elements[0] = button1
pauseUI.elements[1] = button2
pauseUI.elements[2] = button3
pauseUI.elements[3] = button4
UILayers[0] = pauseUI

optionsUI = new UI()
optionsUI.enabled = 0
optionsUI.draw = 0

var button5 = new UIButton2(SC_W/2 - 24, SC_H/2 - 32, 47, 11)
button5.on_confirm = function()
{
    with(gm)
    {
        UILayers[UILayer].enabled = 0
        UILayers[UILayer].draw = 0
        UILayer = 0
        UILayers[0].enabled = 1
        UILayers[0].draw = 1
    }
}
button5.label = string_loc("ui.options.back")

var button6 = new UIButton2(SC_W/2 - 24, SC_H/2 - 20, 47, 11)
button6.label = string_loc("ui.options.a")

var button7 = new UIButton2(SC_W/2 - 24, SC_H/2 - 8, 47, 11)
button7.label = string_loc("ui.options.b")

optionsUI.elements[0] = button5
optionsUI.elements[1] = button6
optionsUI.elements[2] = button7
UILayers[1] = optionsUI

#endregion

// pause surface
pauseSurface = -1
