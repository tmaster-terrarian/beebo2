event_inherited();

if(jumps == 1 && _jumps > jumps)
{
    hsp += spd * 0.6 * input_dir
    vsp += (-jumpspd * 0.25) * abs(input_dir)
}

if(instance_exists(__fakepunch) && state != "SKILL_dkick")
    instance_destroy(__fakepunch)
