function gamepad_button_check_any(gp = 0)
{
    for(var i = 0; i < 16; i++)
    {
        if(gamepad_button_check(gp, i + 32769) || gamepad_axis_value(gp, gp_axislh) != 0 || gamepad_axis_value(gp, gp_axislv) != 0 || gamepad_axis_value(gp, gp_axisrh) != 0 || gamepad_axis_value(gp, gp_axisrv) != 0)
        {
            return 1
        }
    }
    return 0
}
function gamepad_button_check_any_pressed(gp = 0)
{
    for(var i = 0; i < 16; i++)
    {
        if(gamepad_button_check_pressed(gp, i + 32769) || gamepad_axis_value(gp, gp_axislh) != 0 || gamepad_axis_value(gp, gp_axislv) != 0 || gamepad_axis_value(gp, gp_axisrh) != 0 || gamepad_axis_value(gp, gp_axisrv) != 0)
        {
            return 1
        }
    }
    return 0
}
function gamepad_button_check_any_released(gp = 0)
{
    for(var i = 0; i < 16; i++)
    {
        if(gamepad_button_check_released(gp, i + 32769) || gamepad_axis_value(gp, gp_axislh) != 0 || gamepad_axis_value(gp, gp_axislv) != 0 || gamepad_axis_value(gp, gp_axisrh) != 0 || gamepad_axis_value(gp, gp_axisrv) != 0)
        {
            return 1
        }
    }
    return 0
}

function gamepad_button(gp)
{
    for(var i = 0; i < 16; i++)
    {
        if(gamepad_button_check(gp, i + 32769))
        {
            return i
        }
    }
    return 0
}
