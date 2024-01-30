fhsp = 0
grv = 0.2

var c1 = make_color_rgb(52, 28, 39)
var c2 = make_color_rgb(96, 44, 44)
rope_colors = [c1,c2,c2]
rope_points = []
for(var a = 0; a < rope_points_count; a++)
{
    rope_points[a] = [lerp(x, x + x2, a/rope_points_count), lerp(y, y + y2, a/rope_points_count)]
}
