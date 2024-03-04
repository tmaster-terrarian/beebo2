hsp = 0
grv = 0.2

vector = function(x, y)
{
    return {x, y}
}

point = function(pos, anchored = false)
{
    return {
        pos,
        oldPos: pos,
        vel: vector(0, 0),
        anchored
    }
}

integrate = function()
{
    for(var i = 0; i < rope_points_count; i++)
    {
        var s = rope_points[i]

        if(!s.anchored)
        {
            s.pos.x += s.vel.x + hsp
            s.pos.y += s.vel.y
        }
    }
}

solve = function(_a, _b)
{
    var a = _a.pos
    var b = _b.pos
    var dist = point_distance(a.x, a.y, b.x, b.y)

    if(dist != 0)
    {
        var ratio = (segment_len / dist - 1.0)
        var correction = vector(ratio * (b.x - a.x), ratio * (b.y - a.y))

        if(!_a.anchored && !_b.anchored)
        {
            a.x -= 0.5 * correction.x
            a.y -= 0.5 * correction.y
            b.x += 0.5 * correction.x
            b.y += 0.5 * correction.y
        }
        else if(!_b.anchored)
        {
            b.x += 0.8 * correction.x
            b.y += 0.8 * correction.y
        }
    }
}

calcVel = function()
{
    for(var i = 0; i < rope_points_count; i++)
    {
        var s = rope_points[i]

        if(!s.anchored && point_distance(s.pos.x, s.pos.y, s.oldPos.x, s.oldPos.y) > 2)
        {
            s.vel.x = (s.pos.x - s.oldPos.x) * min(4, rope_points_count/(segment_len * 2))
            s.vel.y = (s.pos.y - s.oldPos.y) * min(4, rope_points_count/(segment_len * 2))
        }
        else
        {
            s.vel.x = 0
            s.vel.y = 0
        }

        var w = instance_position(s.pos.x, s.pos.y, par_solid)
        if(w && w != anchor_object)
        {
            var d1 = point_distance(s.pos.x, s.pos.y, s.pos.x, w.bbox_top)
            var d2 = point_distance(s.pos.x, s.pos.y, s.pos.x, w.bbox_bottom)
            var d3 = point_distance(s.pos.x, s.pos.y, w.bbox_left, s.pos.y)
            var d4 = point_distance(s.pos.x, s.pos.y, w.bbox_right, s.pos.y)
            var d = min(d1, d2, d3, d4)

            switch(d)
            {
                case d1:
                {
                    s.pos.y = w.bbox_top
                    break;
                }
                case d2:
                {
                    s.pos.y = w.bbox_bottom
                    break;
                }
                case d3:
                {
                    s.pos.x = w.bbox_left
                    break;
                }
                case d4:
                {
                    s.pos.x = w.bbox_right
                    break;
                }
            }
        }

        s.oldPos.x = s.pos.x
        s.oldPos.y = s.pos.y
    }
}

var c1 = $8caba4
var c2 = $616b6a
rope_colors = [c1,c2]
rope_points = []
for(var a = 0; a < rope_points_count; a++)
{
    rope_points[a] = point(vector(round(lerp(x, x + x2, a/rope_points_count)), round(lerp(y, y + y2, a/rope_points_count))), false)
}
rope_points[0].anchored = true
// rope_points[rope_points_count - 1].anchored = true
