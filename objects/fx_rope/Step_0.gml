integrate()

if(rope_points[rope_points_count - 1].anchored)
{
    rope_points[rope_points_count - 1].pos.x = x + x2
    rope_points[rope_points_count - 1].pos.y = y + y2
}

// var p = global.players[0]
// if(instance_exists(p))
// {
//     var pnt = rope_points[rope_points_count - 1]
//     var lx = lengthdir_x(segment_len * (rope_points_count + 1), point_direction(x, y, p.x, p.y)) + x
//     var ly = lengthdir_y(segment_len * (rope_points_count + 1), point_direction(x, y, p.x, p.y)) + y
//     var px = (p.bbox_left + p.bbox_right) / 2
//     var py = (p.bbox_top + p.bbox_bottom) / 2

//     if(point_distance(x, y, lx, ly) > point_distance(x, y, px, py))
//     {
//         pnt.pos.x = px
//         pnt.pos.y = py
//     }
//     else
//     {
//         pnt.pos.x = lx
//         pnt.pos.y = ly
//     }
// }

var dir = choose(-1, 1)
for(var r = 0; r < rope_points_count; r++)
{
    //var choice = irandom_range(0, rope_points_count - 1)
    var choice = r
    var pointA = rope_points[choice]

    if(choice == 0)
        dir = 1
    if(choice == rope_points_count - 1)
        dir = -1

    var pointB = rope_points[choice + dir]

    if(!pointB.anchored && !position_meeting(pointB.pos.x, pointB.pos.y, par_solid))
    {
        pointB.pos.y += grv * 2 * global.dt
    }

    solve(pointA, pointB)
}

calcVel()
