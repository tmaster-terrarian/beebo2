// get camera position and size
cam_x = camera_get_view_x(cam)
cam_y = camera_get_view_y(cam)
w_half = camera_get_view_width(cam) * 0.5 * (1 / zoom)
h_half = camera_get_view_height(cam) * 0.5 * (1 / zoom)

// approach the targeted object
x += (tx - x) / follow_rate * global.dt
y += (ty - y) / follow_rate * global.dt

// constrain to room edges
if(bounded)
{
    x = clamp(x, w_half, room_width - w_half)
    y = clamp(y, h_half, room_height - h_half - 4)
}

// snap to pixels
_x = round(x - w_half)
_y = round(y - h_half)

// offset with camera shake
x += irandom_range(-round(shake), round(shake))
y += irandom_range(-round(shake), round(shake))
shake = approach(shake, 0, shake_decay * 1/shake_time * global.dt)

// apply position and zoom
camera_set_view_pos(cam, _x, _y)
camera_set_view_size(cam, cam_w / zoom, cam_h / zoom)
