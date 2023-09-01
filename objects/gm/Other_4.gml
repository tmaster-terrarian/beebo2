if(!instance_exists(obj_camera))
{
    instance_create_depth(0, 0, 0, obj_camera, {cam_id: 0, target: obj_player})

    // holy shit splitscreen
    if(global.usesplitscreen)
        instance_create_depth(0, 0, 0, obj_camera, {cam_id: 1, target: obj_player_rival})
}
