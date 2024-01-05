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
global.runEnabled = 1

wavetimer = 600
killzoneTimer = MINUTE

doNotIncreaseWave = 0

mainDirector = new Director(0, 0.1, 0.75, new range(3, 4), new range(0.5, 0.5), 10)

wave5delay = 0

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

// pause surface
pauseSurface = -1

// drawing
item_pickup_queue = []
_money = global.money

time_source_start(global.fixedStepTimeSource)

addFixedStep(function() {
    with(par_unit)
    {
        for(var i = 0; i < array_length(buffs); i++)
        {
            getdef(buffs[i].buff_id, deftype.buff).step(buffs[i])
            getdef(buffs[i].buff_id, deftype.buff).timer_step(buffs[i])
        }
    }
}, self)

#region UI INIT

UILayer = 0
UILayers = []

pauseUI = new UI()

var button1 = new UIButtonSimple(SC_W/2 - 26, SC_H/2 - 32, 51, 11)
button1.on_confirm = function()
{
    gm.togglePause()
}
button1.label = string_loc("ui.pause.resume")

var button2 = new UIButtonSimple(SC_W/2 - 26, SC_H/2 - 20, 51, 11)
button2.on_confirm = function()
{
    with(gm)
    {
        UILayers[UILayer].enabled = 0
        UILayers[UILayer].visible = 0
        UILayer = 1
        UILayers[UILayer].enabled = 1
        UILayers[UILayer].visible = 1
    }
}
button2.label = string_loc("ui.pause.options")

var button3 = new UIButtonSimple(SC_W/2 - 26, SC_H/2 - 8, 51, 11)
button3.label = string_loc("ui.pause.quit_title")

var button4 = new UIButtonSimple(SC_W/2 - 26, SC_H/2 + 4, 51, 11)
button4.on_confirm = function()
{
    // save your shit
    game_end()
}
button4.label = string_loc("ui.pause.quit_game")

pauseUI.elements[0] = button1
pauseUI.elements[1] = button2
pauseUI.elements[2] = button3
pauseUI.elements[3] = button4
UILayers[0] = pauseUI

// options ui

optionsUI = new UI()
optionsUI.enabled = 0
optionsUI.visible = 0
optionsUI.tabs = []
with(optionsUI)
{
    self.switchTab = function(index)
    {
        for(var i = 0; i < array_length(self.tabs); i++)
        {
            self.tabs[i].enabled = 0
            self.tabs[i].visible = 0
        }
        self.tabs[index].enabled = 1
        self.tabs[index].visible = 1

        self.elements[0] = self.tabs[index]
    }
    self.draw = function()
	{
		if(!self.visible)
			return

		for(var i = 0; i < array_length(self.elements); i++)
		{
			var e = self.elements[i]
			e.draw()
		}

		for(var i = 0; i < array_length(self.tabs); i++)
		{
			var e = self.tabs[i]
			e.draw()
		}
	}
}

// contents

    var button0 = new UICategoryButton(SC_W/2 - 111, SC_H/2 - 54, 47, 7)
    button0.exclusive = 1
    button0.exclusionMask = 0b0101
    button0.label = string_loc("ui.options.category.gameplay")
    button0.on_confirm = function()
    {
        with(gm)
        {
            UILayers[1].switchTab(0)
        }
    }
    button0.pressed = 1

    var button1 = new UICategoryButton(SC_W/2 - 111, SC_H/2 - 43, 47, 7)
    button1.exclusive = 1
    button1.exclusionMask = 0b0101
    button1.label = string_loc("ui.options.category.input")
    button1.on_confirm = function()
    {
        with(gm)
        {
            UILayers[1].switchTab(1)
        }
    }

    var button2 = new UICategoryButton(SC_W/2 - 111, SC_H/2 - 32, 47, 7)
    button2.exclusive = 1
    button2.exclusionMask = 0b0101
    button2.label = string_loc("ui.options.category.video")
    button2.on_confirm = function()
    {
        with(gm)
        {
            UILayers[1].switchTab(2)
        }
    }

    var button3 = new UICategoryButton(SC_W/2 - 111, SC_H/2 - 21, 47, 7)
    button3.exclusive = 1
    button3.exclusionMask = 0b0101
    button3.label = string_loc("ui.options.category.audio")
    button3.on_confirm = function()
    {
        with(gm)
        {
            UILayers[1].switchTab(3)
        }
    }

    optionsUI.elements[1] = button0
    optionsUI.elements[2] = button1
    optionsUI.elements[3] = button2
    optionsUI.elements[4] = button3

    var section0 = new UI()
    section0.enabled = 1
    section0.visible = 1
    // contents

        var label0 = new UIText(SC_W/2 - 40, SC_H/2 - 51, 128, c_ltgray)
        label0.label = "hi"

        section0.elements[0] = label0

    //

    var section1 = new UI()
    section1.enabled = 0
    section1.visible = 0
    // contents

        var label0 = new UIText(SC_W/2 - 40, SC_H/2 - 51, 128, c_ltgray)
        label0.label = "hello"

        section1.elements[0] = label0

    //

    var section2 = new UI()
    section2.enabled = 0
    section2.visible = 0
    // contents

        var label0 = new UIText(SC_W/2 - 40, SC_H/2 - 51, 128, c_ltgray)
        label0.label = "where am i"

        section2.elements[0] = label0

    //

    var section3 = new UI()
    section3.enabled = 0
    section3.visible = 0
    // contents

        var label0 = new UIText(SC_W/2 - 40, SC_H/2 - 51, 128, c_ltgray)
        label0.label = "oh"

        section3.elements[0] = label0

    //

    optionsUI.tabs[0] = section0
    optionsUI.tabs[1] = section1
    optionsUI.tabs[2] = section2
    optionsUI.tabs[3] = section3

    optionsUI.switchTab(0)
//

UILayers[1] = optionsUI

#endregion
