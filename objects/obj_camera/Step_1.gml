// good ole platformer days
if(!global.usesplitscreen && follow && array_length(global.players) > 1)
{
    // target the AVERAGE of the target positions
    ts = []

    tx = 0
    ty = 0

    var lookup = 0
    for(var l = 0; l < array_length(global.players); l++)
    {
        array_push(ts, {x: 0, y: 0})
        var p = global.players[l]
        if(instance_exists(p))
        {
            lookup += p.lookup
        }
    }
    lookup /= array_length(global.players)
    if(lookup > 0)
        lookup = 1
    else if(lookup <= -0.25)
        lookup = -0.5
    else
        lookup = 0

    for(var i = 0; i < array_length(global.players); i++)
    {
        var p = global.players[i]
        if(instance_exists(p))
        {
            ts[i].x = ((p.bbox_left + p.bbox_right) / 2) + (p.hsp * global.dt)
            ts[i].y = clamp(((p.bbox_top + p.bbox_bottom) / 2) + p.vsp * global.dt - 16 + (max(2, p.vsp) - 2) * global.dt * 8, hh, room_height - hh - 4) - lookup * (24 / global.zoom) // oldie: ((p.lookup + global.players[-i + 1].lookup) / max(1, 2 * abs(sign(p.lookup)) * abs(sign(global.players[-i + 1].lookup))))
        }
        tx += ts[i].x
        ty += ts[i].y
    }
    tx /= array_length(global.players)
    ty /= array_length(global.players)
}
else if(instance_exists(target) && follow)
{
    // target the CENTER of the object
    tx = ((target.bbox_left + target.bbox_right) / 2) + (target.hsp * global.dt)
    ty = ((target.bbox_top + target.bbox_bottom) / 2) + (target.vsp * global.dt)

    if(object_get_parent(target.object_index) == obj_player) && (!keyboard_check(target._dbkey))
    {
        if(target.object_index == obj_player_beebo)
        {
            tx += lengthdir_x(16 / global.zoom, target.fire_angle)
        }
        else
            tx += target.facing * 16 / global.zoom
        ty = clamp(ty - 4, hh, room_height - hh - 4) - target.lookup * 24 / global.zoom
    }
}

// if(instance_exists(target) && follow)
// {
//     // target the screen the object is in
//     var w = SC_H * 4/3
//     var off = (SC_W - w)/2
//     tx = max(floor((target.x - off) / w) * w + w/2 + off, w/2 + off)
//     ty = max(floor(target.y / SC_H) * SC_H + SC_H/2, SC_H/2)
// }
