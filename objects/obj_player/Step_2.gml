event_inherited();

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
