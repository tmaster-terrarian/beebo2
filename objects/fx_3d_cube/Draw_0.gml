gpu_set_ztestenable(true)

var tex = sprite_get_texture(spr_tough_wall, 0)

var angle = get_timer() / 1000000 * 60

var a = matrix_get(matrix_world)
matrix_set(matrix_world, matrix_build(x, y, depth, -30, angle, 0, 16 * image_xscale, 16 * image_yscale, 16 * image_zscale))

shader_set(shd_palette_swap)
shader_set_uniform_f(u_width, 8 * 4)
shader_set_uniform_f(u_height, 8 * 4)

vertex_submit(v_buff, pr_trianglelist, tex)

shader_reset()

matrix_set(matrix_world, a)

gpu_set_ztestenable(false)
