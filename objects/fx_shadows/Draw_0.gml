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

        for(var m = 0; m < array_length(meshes); m++)
        {
            var mesh = meshes[m]

            draw_primitive_begin(pr_trianglestrip)
            for(var i = 0; i < array_length(mesh.verts); i++)
            {
                var pX = mesh.verts[i].x
                var pY = mesh.verts[i].y

                var eX = pX + lengthdir_x(6 * SC_W/global.zoom, point_direction(plr.x, plr.y - 8, pX, pY)) + (choose(1, -1) * (random(1) + random(1))) * jitter
                var eY = pY + lengthdir_y(6 * SC_W/global.zoom, point_direction(plr.x, plr.y - 8, pX, pY)) + (choose(1, -1) * (random(1) + random(1))) * jitter

                draw_vertex_color(pX, pY, c_gray, 1)
                draw_vertex_color(eX, eY, c_gray, 1)
            }
            draw_primitive_end()
        }

        surface_reset_target()

        gpu_set_blendmode(bm_subtract)
        surface_set_target(surf2)
        draw_surface_ext(surf, 0, 0, 1, 1, 0, c_gray, 0.2)
        surface_reset_target()
        gpu_set_blendmode(bm_normal)
    }
}

// surface_set_target(surf2)
// gpu_set_blendmode(bm_max)
// for(var p = 0; p < array_length(global.players); p++)
// {
//     var plr = global.players[p]

//     if(instance_exists(plr) && plr.state != "ghost")
//     {
//         draw_circle_color(plr.x, plr.y, 3 * SC_W/global.zoom, c_black, c_dkgray, false)
//     }
// }
// gpu_set_blendmode(bm_normal)
// surface_reset_target()

gpu_set_blendmode_ext(bm_dest_color, bm_zero)
draw_surface_ext(surf2, 0, 0, 1, 1, 0, c_white, 1)
gpu_set_blendmode(bm_normal)

// gpu_set_blendmode_ext(bm_dest_color, bm_zero)
// for(var p = 0; p < array_length(global.players); p++)
// {
//     var plr = global.players[p]

//     if(instance_exists(plr) && plr.state != "ghost")
//     {
//         draw_circle_color(plr.x, plr.y, 2 * SC_W/global.zoom, c_white, c_ltgray, false)
//     }
// }
// gpu_set_blendmode(bm_normal)
