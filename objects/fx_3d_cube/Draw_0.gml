var _a = image_alpha
image_alpha = 0
event_inherited()
image_alpha = _a

gpu_set_ztestenable(true)

var tex = sprite_get_texture(spr_tough_wall3d, 0)

var angle = ((get_timer() / 1000000 * 60) * (1 + (1-hp/hp_max) * 1.2) + 2 * flash) + (5 * cos(0.125 * (get_timer() / 1000000 * pi)) + 5)

if(!surface_exists(surf))
{
    surf = surface_create(room_width, room_height)
}

var a = matrix_get(matrix_world)

surface_set_target(surf)
draw_clear_alpha(c_black, 0)

if(flash > 0)
    shader_set(sh_flash)
else
{
    shader_set(shd_palette_swap)
    shader_set_uniform_f(u_width, sprite_get_width(spr_tough_wall3d))
    shader_set_uniform_f(u_height, sprite_get_height(spr_tough_wall3d))
}

matrix_set(matrix_world, matrix_build(
    x + random_range(-flash, flash), // pos
    y + random_range(-flash, flash),
    depth,
    -30 + angle/2, // angle
    angle,
    -90 + angle/4,
    6 * _image_xscale, // scale
    6 * image_yscale,
    6 * image_zscale
))

vertex_submit(v_buff, pr_trianglelist, tex)

matrix_set(matrix_world, a)

shader_reset()

surface_reset_target()

// var outlineColor = #093666

// shader_set(sh_flash)
// draw_surface_ext(surf, -1, 0, 1, 1, 0, outlineColor, 1)
// draw_surface_ext(surf, 1, 0, 1, 1, 0, outlineColor, 1)
// draw_surface_ext(surf, 0, -1, 1, 1, 0, outlineColor, 1)
// draw_surface_ext(surf, 0, 1, 1, 1, 0, outlineColor, 1)
// shader_reset()

draw_surface_ext(surf, 0, 0, 1, 1, 0, image_blend, 1)

gpu_set_ztestenable(false)
