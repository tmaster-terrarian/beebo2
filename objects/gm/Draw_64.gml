if(global.pause)
{
    _draw_rect(0, 0, SC_W, SC_H, c_black, 0.5)

    var txt = scribble("[fa_middle][fa_center][fnt_basic][c_white]PAUSED")
    txt.flash(c_black, 1).draw(SC_W * 0.5, SC_H * 0.25 + 1)
    txt.flash(c_black, 0).draw(SC_W * 0.5, SC_H * 0.25)
}

var _fps = scribble($"[fa_left][fa_bottom][fnt_itemdesc][c_white]{fps}FPS")

_draw_rect(1, SC_H - 8, _fps.get_width(), SC_H - 2, c_black, 0.5)
_fps.draw(2, SC_H - 1)

var _timer = scribble($"[fa_left][fa_bottom][fnt_itemdesc][c_white]TIMER: {timer_to_timestamp((global.t / 60) * 1000000)}")

_draw_rect(31, SC_H - 8, _timer.get_width(), SC_H - 2, c_black, 0.5)
_timer.draw(32, SC_H - 1)
