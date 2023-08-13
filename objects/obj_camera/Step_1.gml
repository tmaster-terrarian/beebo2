if(instance_exists(target) && follow)
{
    // target the CENTER of the object
    tx = target.bbox_left + target.bbox_right / 2
    ty = target.bbox_top + target.bbox_bottom / 2 + follow.vsp

    if(target.object_index == obj_player) && (!keyboard_check(vk_lcontrol))
    {
        ty += -4
    }
}
