function loadSettings()
{
    var json = {}

    var file = file_text_open_read("options.json")
	json = file_json_read(file)
	file_text_close(file)

    global.perPlayerInput = [{}, {}, {}, {}]

    global.optionsStruct = json

    var s = json.inputSettings

    // gamepad constants: n + 32769
    for(var i = 0; i < array_length(s); i++)
    {
        var obj = {}

        var names = variable_struct_get_names(s[i].buttons)
        var size = variable_struct_names_count(s[i].buttons)

        for (var j = 0; j < size; j++)
        {
            var name = names[j]
            var element = s[i].buttons[$ name]

            obj[$ name] = struct_clone(element)
            obj[$ name].playerIndex = s[i].gpIndex

            if(s[i].gpIndex < 0) // KBM
            {
                if(obj[$ name].mouse)
                {
                    with(obj[$ name])
                    {
                        check = function()
                        {
                            return (mouse_check_button(keyCode))
                        }
                        checkPressed = function()
                        {
                            return (mouse_check_button_pressed(keyCode))
                        }
                        checkReleased = function()
                        {
                            return (mouse_check_button_released(keyCode))
                        }
                    }
                }
                else
                {
                    with(obj[$ name])
                    {
                        check = function()
                        {
                            return (keyboard_check(keyCode))
                        }
                        checkPressed = function()
                        {
                            return (keyboard_check_pressed(keyCode))
                        }
                        checkReleased = function()
                        {
                            return (keyboard_check_released(keyCode))
                        }
                    }
                }
            }
            else // GP
            {
                with(obj[$ name])
                {
                    check = function()
                    {
                        return (gamepad_button_check(playerIndex, gp + 32769))
                    }
                    checkPressed = function()
                    {
                        return (gamepad_button_check_pressed(playerIndex, gp + 32769))
                    }
                    checkReleased = function()
                    {
                        return (gamepad_button_check_released(playerIndex, gp + 32769))
                    }
                }
            }
        }

        global.perPlayerInput[i].buttons = obj
        global.perPlayerInput[i].playerIndex = s[i].gpIndex
    }
}

function refreshInputSettings()
{
    var s = global.optionsStruct.inputSettings

    for(var i = 0; i < array_length(s); i++)
    {
        var obj = {}

        var names = variable_struct_get_names(s[i].buttons)
        var size = variable_struct_names_count(s[i].buttons)

        for (var j = 0; j < size; j++) {
            var name = names[j]
            var element = s[i].buttons[$ name]

            obj[$ name] = struct_clone(element)
            obj[$ name].playerIndex = s[i].gpIndex

            if(s[i].gpIndex < 0)
            { 
                if(obj[$ name].mouse)
                {
                    with(obj[$ name])
                    {
                        check = function()
                        {
                            return (mouse_check_button(keyCode))
                        }
                        checkPressed = function()
                        {
                            return (mouse_check_button_pressed(keyCode))
                        }
                        checkReleased = function()
                        {
                            return (mouse_check_button_released(keyCode))
                        }
                    }
                }
                else
                {
                    with(obj[$ name])
                    {
                        check = function()
                        {
                            return (keyboard_check(keyCode))
                        }
                        checkPressed = function()
                        {
                            return (keyboard_check_pressed(keyCode))
                        }
                        checkReleased = function()
                        {
                            return (keyboard_check_released(keyCode))
                        }
                    }
                }
            }
            else
            {
                with(obj[$ name])
                {
                    check = function()
                    {
                        return (gamepad_button_check(playerIndex, gp + 32769))
                    }
                    checkPressed = function()
                    {
                        return (gamepad_button_check_pressed(playerIndex, gp + 32769))
                    }
                    checkReleased = function()
                    {
                        return (gamepad_button_check_released(playerIndex, gp + 32769))
                    }
                }
            }
        }

        global.perPlayerInput[i].buttons = obj
        global.perPlayerInput[i].playerIndex = s[i].gpIndex
    }
}

function saveSettings()
{
    var file = file_text_open_write("options.json")
	file_text_write_string(file, json_stringify(global.optionsStruct, 1))
	file_text_close(file)
}
