if(instance_exists(target) && follow)
{
    // target the CENTER of the object
    tx = ((target.bbox_left + target.bbox_right) / 2)
    ty = ((target.bbox_top + target.bbox_bottom) / 2) + target.vsp * global.dt

    if(target.object_index == obj_player) && (!keyboard_check(vk_lcontrol))
    {
        tx += target.facing * 10
        ty = clamp(ty - 4, hh, room_height - hh - 4) - target.lookup * 24
    }
}
