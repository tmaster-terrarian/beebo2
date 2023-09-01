if(!global.usesplitscreen && follow)
{
    // target the AVERAGE of the target positions
    ts = [{x, y}, {x, y}]
    for(var i = 0; i < 2; i++)
    {
        var p = global.players[i]
        if(instance_exists(p))
        {
            ts[i].x = ((p.bbox_left + p.bbox_right) / 2)
            ts[i].y = clamp(((p.bbox_top + p.bbox_bottom) / 2) + p.vsp * global.dt - 4, hh, room_height - hh - 4) - ((p.lookup + global.players[-i + 1].lookup) / max(1, 2 * abs(sign(p.lookup)) * abs(sign(global.players[-i + 1].lookup)))) * 24
        }
    }
    tx = lerp(ts[0].x, ts[1].x, 0.5)
    ty = lerp(ts[0].y, ts[1].y, 0.5)
}
else if(instance_exists(target) && follow)
{
    // target the CENTER of the object
    tx = ((target.bbox_left + target.bbox_right) / 2)
    ty = ((target.bbox_top + target.bbox_bottom) / 2) + target.vsp * global.dt

    if(target.object_index == obj_player) && (!keyboard_check(target._dbkey))
    {
        tx += target.facing * 10
        ty = clamp(ty - 4, hh, room_height - hh - 4) - target.lookup * 24
    }
}
