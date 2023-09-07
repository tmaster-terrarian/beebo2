if(keyboard_check(_dbkey))
{
    hsp = 0
    vsp = 0
    x = round(mouse_x)
    y = round(mouse_y)
}

event_inherited();

if(regen) heal_event(id, regen_rate/60, healtype.regen)
if(hp > hp_max) hp = hp_max

//bound position to room
if(bbox_left < 0 || bbox_right > room_width)
{
    while(bbox_right > room_width)
        x--
    while(bbox_left < 0)
        x++

    if(!keyboard_check(_dbkey))
        _oncollide_h()
}
if(bbox_top < 0)
{
    while(bbox_top < 0)
        y++

    if(!keyboard_check(_dbkey))
        _oncollide_v()
}

if(position_meeting(bbox_left, bbox_bottom+1, par_solid) && position_meeting(bbox_right, bbox_bottom+1, par_solid))
{
    lastSafeX = x;
    lastSafeY = y;
}
