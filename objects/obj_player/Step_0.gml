event_inherited()

running = (sprite_index == spr_player_run) || (sprite_index == spr_player_run_rev)

if(place_meeting(x, y, obj_wall)) y--;

var input_dir = 0
input_dir = sign
(
    gamepad_axis_value(0, gp_axislh)
    + (gamepad_button_check(0, gp_padr) - gamepad_button_check(0, gp_padl))
    + (keyboard_check(ord("D")) - keyboard_check(ord("A")))
) * hascontrol

if(!on_ground)
    duck = 0
if(duck)
{
    spd *= 0.5
    if(abs(hsp) > spd)
        hsp = approach(hsp, spd * input_dir, 0.25)
}

if(on_ground)
{
    accel = ground_accel;
    fric = ground_fric;
}
else
{
    accel = air_accel;
    fric = air_fric;
    if(abs(hsp) > spd * 1.3)
        fric *= 0.1
}

state()
