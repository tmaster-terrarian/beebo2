if(!instance_exists(obj_camera))
{
    instance_create_depth(0, 0, 0, obj_camera, {cam_id: 0, target: obj_player})

    // holy shit splitscreen
    // instance_create_depth(0, 0, 0, obj_camera, {cam_id: 1, target: obj_test})
    // instance_create_depth(0, 0, 0, obj_camera, {cam_id: 2, target: obj_circleplatform})
    // instance_create_depth(0, 0, 0, obj_camera, {cam_id: 3, target: obj_wall})
}
