if(keyboard_check(_dbkey))
{
    hsp = 0
    vsp = 0
    x = round(mouse_x)
    y = round(mouse_y)
}

event_inherited();

if(regen && hp > 0) heal_event(id, regen_rate/60 * global.dt, healtype.regen)
if(hp > hp_max) hp = hp_max

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
if(bbox_left < max(0, cam_x) || bbox_right > min(cam_x + cam_w, room_width))
{
    while(bbox_left < max(0, cam_x))
        x++
    while(bbox_right > min(room_width, cam_x + cam_w))
        x--

    if(!keyboard_check(_dbkey))
        _oncollide_h()
    hsp = 0

    if(running)
    {
        image_index = 0
    }
}
if(bbox_top < max(0, cam_y))
{
    while(bbox_top < max(0, cam_y))
        y++

    if(!keyboard_check(_dbkey))
        _oncollide_v()
    vsp = 0
}

if(position_meeting(bbox_left, bbox_bottom + 1, par_solid) && position_meeting(bbox_right, bbox_bottom + 1, par_solid))
{
    lastSafeX = x;
    lastSafeY = y;
}
