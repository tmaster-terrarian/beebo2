event_inherited()

depth = -100

_image_xscale = 2 * image_xscale
image_zscale = _image_xscale
image_yscale = _image_xscale

vertex_format_begin()
vertex_format_add_position_3d()
vertex_format_add_normal()
vertex_format_add_color()
vertex_format_add_texcoord()
var format = vertex_format_end()

var v = [
    [-0.5, -0.5, -0.5 ],
    [-0.5,  0.5, -0.5 ],
    [ 0.5,  0.5, -0.5 ],
    [ 0.5, -0.5, -0.5 ],
    [-0.5, -0.5,  0.5 ],
    [-0.5,  0.5,  0.5 ],
    [ 0.5,  0.5,  0.5 ],
    [ 0.5, -0.5,  0.5 ]
]
var vt = [
    [ 0.25, 0    ],
    [ 0.50, 0    ],
    [ 0,    0.25 ],
    [ 0.25, 0.25 ],
    [ 0.50, 0.25 ],
    [ 0.75, 0.25 ],
    [ 0,    0.50 ],
    [ 0.25, 0.50 ],
    [ 0.50, 0.50 ],
    [ 0.75, 0.50 ],
    [ 0.25, 0.75 ],
    [ 0.50, 0.75 ],
    [ 0.25, 1.00 ],
    [ 0.50, 1.00 ]
]
var vn = [
    [ 1.0,  0.0,  0.0 ],
    [-1.0,  0.0,  0.0 ],
    [ 0.0,  1.0,  0.0 ],
    [ 0.0, -1.0,  0.0 ],
    [ 0.0,  0.0,  1.0 ],
    [ 0.0,  0.0, -1.0 ]
]
var f = [
    ["3/10/1", "7/6/1", "8/5/1"],
    ["3/10/1", "8/5/1", "4/9/1"],

    ["1/8/2", "5/4/2", "6/3/2"],
    ["1/8/2", "6/3/2", "2/7/2"],

    ["7/14/3", "3/12/3", "2/11/3"],
    ["7/14/3", "2/11/3", "6/13/3"],

    ["4/9/4", "8/5/4", "5/4/4"],
    ["4/9/4", "5/4/4", "1/8/4"],

    ["8/5/5", "7/2/5", "6/1/5"],
    ["8/5/5", "6/1/5", "5/4/5"],

    ["3/12/6", "4/9/6", "1/8/6"],
    ["3/12/6", "1/8/6", "2/11/6"]
]

v_buff = vertex_create_buffer()
vertex_begin(v_buff, format)

for(var i = 0; i < array_length(f); i++)
{
    for(var j = 0; j < array_length(f[i]); j++)
    {
        var s = string_split(f[i][j], "/")

        var _v  = real(s[0]) - 1
        var _vt = real(s[1]) - 1
        var _vn = real(s[2]) - 1

        vertex_position_3d(v_buff, v[_v][0], v[_v][1], v[_v][2])
        vertex_normal(v_buff, vn[_vn][0], vn[_vn][1], vn[_vn][2])
        vertex_color(v_buff, image_blend, image_alpha)
        vertex_texcoord(v_buff, vt[_vt][0], vt[_vt][1])
    }
}

vertex_end(v_buff)
vertex_freeze(v_buff)

u_width = shader_get_uniform(shd_palette_swap, "width")
u_height = shader_get_uniform(shd_palette_swap, "height")

particle = instance_create_depth(x, y, depth + 2, fx_particle_emitter, {
    owner: self,
    spr: spr_8x8centered,
    posGlobal: 1,
    life: 0.75,
    max_particles: 15,
    interval: 4,
    scale: 0.75,
    scaleE: 0.25,
    scaleER: 0.125,
    dirR: 45,
    spd: 0.5,
    spdR: 0.1,
    spdE: 0,
    xR: 4 * image_xscale - 2,
    yR: 4 * image_yscale - 2,
    color: c_red,
    colorER: 30,
    alphaE: 0.5,
    alphaER: 0.25,
    grvY: 0.1,
})

onHurt = function(context)
{
    var s = choose(sn_cube_hit1, sn_cube_hit2, sn_cube_hit3)
    _audio_play_sound(s, 0, false, 3)
}

surf = -1

state = "normal"

states = {
    normal: function() {with(other) {
        if(instance_exists(target))
        {
            hsp = approach(hsp, lengthdir_x(spd, point_direction(x, y, target.x, (target.bbox_top + target.bbox_bottom) / 2)), air_accel)
            vsp = approach(vsp, lengthdir_y(spd, point_direction(x, y, target.x, (target.bbox_top + target.bbox_bottom) / 2)), air_accel)
        }

        if(!instance_exists(target) || sqrt(sqr(hsp) + sqr(vsp)) > spd)
        {
            hsp = approach(hsp, 0, air_fric)
            vsp = approach(vsp, 0, air_fric)
        }
    }}
}
