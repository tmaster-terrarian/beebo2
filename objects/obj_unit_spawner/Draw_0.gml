if(!surface_exists(surface)) surface = surface_create(64, 64)

surface_set_target(surface)
draw_clear_alpha(c_black, 0)

draw_sprite_ext(sprite_index, image_index, 32, 32 + yOffset, image_xscale, image_yscale, image_angle, image_blend, image_alpha)

gpu_set_blendmode_ext(bm_dest_color, bm_zero)
_draw_rect(16, 32 - 15 * ((delay - spawntimer) / delay), 48, 32, c_red, 1, false)
gpu_set_blendmode(bm_normal)

surface_reset_target()

draw_surface(surface, x - 32, y - 32)
