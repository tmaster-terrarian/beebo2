// get camera position and size
cam_x = camera_get_view_x(cam)
cam_y = camera_get_view_y(cam)
wh = camera_get_view_width(cam) * 0.5
hh = camera_get_view_height(cam) * 0.5

// constrain to room edges
if(bounded && place_meeting(tx, ty, obj_trigger_camera_bounds))
{
    var t = instance_place(tx, ty, obj_trigger_camera_bounds)
    tx = clamp(tx, t.x + wh, (t.x + t.image_xscale) - wh)
    ty = clamp(ty, t.y + hh, (t.y + t.image_yscale) - hh - (t.image_yscale % 8))
}

// approach the targeted object
dx = (tx - x) / follow_rate * global.dt
dy = (ty - y) / follow_rate * global.dt
x += dx
y += dy

// snap to pixels and offset with camera shake
_x = round(x - wh + random_range(-shake, shake))
_y = round(y - hh + random_range(-shake, shake))
shake = max(0, shake - ((1 / shake_length) * shake_strength) * global.dt)

// apply position and zoom
camera_set_view_pos(cam, _x, _y)

var w = cam_w / global.zoom
var h = cam_h / global.zoom

// splitscreen
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
    case 3:
    {
        camera_set_view_size(cam, w, h)

        if(cam_id < 2)
            view_set_xport(cam_id, 0.5 * w * cam_id)
        else
        {
            view_set_xport(cam_id, 0.25 * w)
            view_set_yport(cam_id, 0.5 * h)
        }
        view_set_wport(cam_id, 0.5 * w)
        view_set_hport(cam_id, 0.5 * h)

        break;
    }
    case 4:
    {
        camera_set_view_size(cam, w, h)

        view_set_xport(cam_id, 0.5 * w * (cam_id % 2))
        view_set_yport(cam_id, 0.5 * h * floor(cam_id / 2))

        view_set_wport(cam_id, 0.5 * w)
        view_set_hport(cam_id, 0.5 * h)

        break;
    }
}
