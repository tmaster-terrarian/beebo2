var verts = [{x: 0, y: 120}, {x: 48, y: 120}, {x: 48, y: 32}, {x: 272, y: 32}, {x: 272, y: 120}, {x: 320, y: 120}]

if(!surface_exists(surf))
{
    if(surf == -1)
    {
        // event for when surface is first created
    }

    surf = surface_create(room_width, room_height)
}
if(!surface_exists(surf2))
{
    if(surf2 == -1)
    {
        // event for when surface2 is first created
    }

    surf2 = surface_create(room_width, room_height)
}
surface_set_target(surf2)
draw_clear_alpha(c_white, 1)
surface_reset_target()

for(var p = 0; p < array_length(global.players); p++)
{
    var plr = global.players[p]

    if(instance_exists(plr) && plr.state != "ghost")
    {
        surface_set_target(surf)
        draw_clear_alpha(c_black, 1)

        draw_primitive_begin(pr_trianglestrip)
        for(var i = 0; i < array_length(verts); i++)
        {
            var pX = verts[i].x
            var pY = verts[i].y

            var eX = pX + lengthdir_x(6 * SC_W/global.zoom, point_direction(plr.x, plr.y - 8, pX, pY))
            var eY = pY + lengthdir_y(6 * SC_W/global.zoom, point_direction(plr.x, plr.y - 8, pX, pY))

            draw_vertex_color(pX, pY, c_white, 1)
            draw_vertex_color(eX, eY, c_white, 1)
        }
        draw_primitive_end()

        surface_reset_target()
    }

    surface_set_target(surf2)
    gpu_set_blendmode_ext(bm_dest_color, bm_zero)
    draw_surface_ext(surf, 0, 0, 1, 1, 0, c_white, 1)
    gpu_set_blendmode(bm_normal)
    surface_reset_target()
}

gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_color)
draw_surface_ext(surf2, 0, 0, 1, 1, 0, c_white, 0.3)
gpu_set_blendmode(bm_normal)
