depth = 0

view_set_visible(cam_id, 1)
cam = view_camera[cam_id]
cam_x = 0
cam_y = 0
cam_w = SC_W
cam_h = SC_H
camera_set_view_size(cam, cam_w, cam_h)
wh = cam_w * 0.5
hh = cam_h * 0.5

follow = 1
tx = x
ty = y

follow_rate = 5

shake = 0
shake_length = 0
shake_strength = 1

bounded = 1
