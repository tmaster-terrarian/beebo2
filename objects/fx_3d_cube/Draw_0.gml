var _a = image_alpha
image_alpha = 0
event_inherited()
image_alpha = _a

gpu_set_ztestenable(true)

var tex = sprite_get_texture(spr_tough_wall3d, 0)

var angle = (get_timer() / 1000000 * 60) * (1 + (1-hp/hp_max) * 1.2)

// var surf = surface_create(room_width, room_height)
// surface_set_target(surf)

if(flash > 0)
    shader_set(sh_flash)
else
{
    shader_set(shd_palette_swap)
    shader_set_uniform_f(u_width, sprite_get_width(spr_tough_wall3d))
    shader_set_uniform_f(u_height, sprite_get_height(spr_tough_wall3d))
}

var a = matrix_get(matrix_world)
matrix_set(matrix_world, matrix_build(x + 4 * image_xscale + random_range(-flash, flash), y + 4 * image_yscale + random_range(-flash, flash), depth, -30 + angle/2, angle, -90 + angle/4, 6 * _image_xscale, 6 * image_yscale, 6 * image_zscale))
vertex_submit(v_buff, pr_trianglelist, tex)
matrix_set(matrix_world, a)

shader_reset()

// surface_reset_target()

// shader_set(sh_flash)
// draw_surface_ext(surf, -1, 0, 1, 1, 0, c_black, 1)
// draw_surface_ext(surf, 1, 0, 1, 1, 0, c_black, 1)
// draw_surface_ext(surf, 0, -1, 1, 1, 0, c_black, 1)
// draw_surface_ext(surf, 0, 1, 1, 1, 0, c_black, 1)
// shader_reset()

// draw_surface_ext(surf, 0, 0, 1, 1, 0, c_white, 1)

// surface_free(surf)

gpu_set_ztestenable(false)
