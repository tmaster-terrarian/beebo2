if(draw_hud)
{
    var _fps = scribble($"[fa_left][fa_bottom][fnt_itemdesc][c_white]{fps}FPS")

    _draw_rect(1, SC_H - 8, _fps.get_width(), SC_H - 2, c_black, 0.5)

    _fps.draw(2, SC_H - 1)
}

if(global.draw_debug)
{
    _draw_rect(1, 1, 200, 42, c_black, 0.25)

    draw_set_font(fnt_console) draw_set_halign(fa_left) draw_set_valign(fa_top)
    draw_text(2, 2, $"x: {x}")  draw_text(72, 2, $"hsp: {hsp}")
    draw_text(2, 12, $"y: {y}") draw_text(72, 12, $"vsp: {vsp}")
    draw_text(2, 22, $"state: {state}")
    draw_text(2, 32, $"platformtarget: {platformtarget}")

    if(instance_exists(platformtarget))
    {
        _draw_line(2 + 15*7, 36, platformtarget.x - obj_camera._x - 1, platformtarget.y - obj_camera._y - 1, 1, c_lime, 0.5)
    }
}
