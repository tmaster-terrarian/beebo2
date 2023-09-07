PAUSECHECK

// get camera position and size
cam_x = camera_get_view_x(cam)
cam_y = camera_get_view_y(cam)
wh = camera_get_view_width(cam) * 0.5
hh = camera_get_view_height(cam) * 0.5

// approach the targeted object
x += (tx - x) / follow_rate * global.dt
y += (ty - y) / follow_rate * global.dt

// constrain to room edges
if(bounded)
{
    x = clamp(x, wh, room_width - wh)
    y = clamp(y, hh, room_height - hh - 4)
}

// snap to pixels and offset with camera shake
_x = round(x - wh + random_range(-shake, shake))
_y = round(y - hh + random_range(-shake, shake))
shake = max(0, shake - ((1 / shake_length) * shake_strength) * global.dt)

// apply position and zoom
camera_set_view_pos(cam, _x, _y)

var w = cam_w / global.zoom
var h = cam_h / global.zoom

// splitscreen
if(global.usesplitscreen)
switch(instance_number(obj_camera))
{
    case 1:
    {
        camera_set_view_size(cam, w, h)

        break;
    }
    case 2:
    {
        camera_set_view_size(cam, w * 0.5, h)

        view_set_xport(cam_id, 0.5 * w * cam_id)
        view_set_wport(cam_id, 0.5 * w)

        break;
    }
}
