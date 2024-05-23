if(keyboard_check(_dbkey))
{
    hsp = 0
    vsp = 0
    x = round(mouse_x)
    y = round(mouse_y)
}

event_inherited();

if(oneshotprotection > 0)
{
    oneshotprotection = approach(oneshotprotection, 0, global.dt)
}

var cam = view_camera[0]
if(global.usesplitscreen)
    cam = view_camera[player_id]

var cam_x = camera_get_view_x(cam)
var cam_y = camera_get_view_y(cam)
var cam_w = camera_get_view_width(cam)
var cam_h = camera_get_view_height(cam)

//bound position to room
if(bbox_left < 0 || bbox_right > room_width)
{
    if(bbox_left < 0)
        x = x - bbox_left
    if(bbox_right > room_width)
        x = room_width + x - bbox_right

    if(!keyboard_check(_dbkey))
        _oncollide_h()
    hsp = 0

    if(running)
    {
        image_index = 0
    }
}
if(bbox_top < 0)
{
    y += 0 - bbox_top

    if(!keyboard_check(_dbkey))
        _oncollide_v()
    vsp = 0
}

//bound position to screen
// if((bbox_left < cam_x || bbox_right > cam_x + cam_w) && state != "dead")
// {
//     if(bbox_left < cam_x)
//         x = cam_x + x - bbox_left
//     if(bbox_right > cam_x + cam_w)
//         x = cam_x + cam_w + x - bbox_right

//     if(!keyboard_check(_dbkey) && state != "ghost")
//         _oncollide_h()
//     hsp = 0

//     if(running)
//     {
//         image_index = 0
//     }
// }
// if(bbox_top < cam_y && state != "dead")
// {
//     y = cam_y + y - bbox_top

//     if(!keyboard_check(_dbkey) && state != "ghost")
//         _oncollide_v()
//     vsp = 0
// }
// if(bbox_bottom > cam_y + cam_h && state == "ghost")
// {
//     y = cam_y + cam_h + y - bbox_bottom

//     vsp = 0
// }

if(position_meeting(bbox_left, bbox_bottom + 1, par_solid) && position_meeting(bbox_right, bbox_bottom + 1, par_solid))
{
    lastSafeX = x;
    lastSafeY = y;
}
