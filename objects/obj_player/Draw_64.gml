if(global.draw_debug)
{
    _draw_rect(1, 1, 200, 62, c_black, 0.2)

    draw_set_font(fnt_console) draw_set_halign(fa_left) draw_set_valign(fa_top)
    draw_text(2, 2,  $"player 1 info")
    draw_text(2, 12, $"x: {x}") draw_text(72, 12, $"hsp: {hsp}") draw_text(142, 12, $"tx: {obj_camera.tx}")
    draw_text(2, 22, $"y: {y}") draw_text(72, 22, $"vsp: {vsp}") draw_text(142, 22, $"ty: {obj_camera.ty}")
    draw_text(2, 32, $"state: {state}")
    draw_text(2, 42, $"platformtarget: {platformtarget}")
    draw_text(2, 52, $"sprite: {sprite_get_name(sprite_index)}")

    if(instance_exists(platformtarget))
    {
        _draw_line(2 + 15*7, 46, platformtarget.x - obj_camera._x - 1, platformtarget.y - obj_camera._y - 1, 1, c_lime, 0.5)
    }
}
