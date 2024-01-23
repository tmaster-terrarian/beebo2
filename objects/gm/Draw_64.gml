if(global.pause)
{
    _draw_rect(-1, -1, SC_W + 1, SC_H + 1, c_black, 0.5)

    var txt = scribble("[fa_middle][fa_center][fnt_basic][c_white]-[[ PAUSED ]-")

    if(UILayer != 1)
    {
        txt.flash(c_black, 1).draw(SC_W * 0.5, SC_H * 0.25 + 1)
        txt.flash(c_black, 0).draw(SC_W * 0.5, SC_H * 0.25)
    }

    UILayers[UILayer].visible = 1
    UILayers[UILayer].enabled = 1
}
else
{
    UILayers[UILayer].visible = 0
    UILayers[UILayer].enabled = 0

    _draw_rect(-1, -1, SC_W + 1, SC_H + 1, global.sctint, global.sctint_alpha)

    var _fps = scribble($"[fa_left][fa_bottom][fnt_itemdesc][c_white]{fps}FPS")

    _draw_rect(1, SC_H - 8, _fps.get_width(), SC_H - 2, c_black, 0.5)
    _fps.draw(2, SC_H - 1)

    var time = timer_to_timestamp((global.t / 60) * 1000000)
    var _timer = scribble($"[fa_left][fa_bottom][fnt_itemdesc][c_white]TIMER: {time} WAVE: {global.wave}")
    _draw_rect(23, SC_H - 8, _timer.get_width() + 22, SC_H - 2, c_black, 0.5)
    _timer.draw(24, SC_H - 1)

    var _debugtext = scribble($"[fa_left][fa_top][fnt_itemdesc][c_white]CREDITS: {mainDirector.credits}\nLASTCARD: {(mainDirector.lastSpawnCard == noone) ? "noone" : mainDirector.lastSpawnCard.index}\nLASTSPAWNSUCCESS: {mainDirector.lastSpawnSucceeded}\nENABLED: {mainDirector.enabled}").wrap(320)
    // _draw_rect(1, 1, _debugtext.get_width(), _debugtext.get_height() - 1, c_black, 0.5)
    // _debugtext.draw(2, 1)

    var _MONEY = scribble($"[fa_left][fa_top][spr_hudnumbers][c_yellow]$[/c]:{floor(_money)}")
    // _draw_rect(1, 1, _MONEY.get_width(), _MONEY.get_height(), c_black, 0.5)
    // _MONEY.draw(1, 1)

    if(mainDirector.waveType == 1 && global.enemyCount > 0)
    {
        global.combinedBossHealth = 0
        with(par_unit)
        {
            if(boss)
            {
                global.combinedBossHealth += total_hp
                if(!contributed)
                    global.combinedBossMaxHealth += total_hp_max
                contributed = 1
            }
        }

        draw_sprite_ext(spr_enemyhpbar, 0, 4, 4, SC_W - 8, 2, 0, c_white, 1)

        draw_sprite_ext(spr_enemyhpbar, 3, 4, 4, global.combinedBossHealth/global.combinedBossMaxHealth * (SC_W - 8), 2, 0, c_white, 1)
    }
    else
    {
        global.combinedBossHealth = 0
        global.combinedBossMaxHealth = 0
    }

    // var _stockcounter = scribble($"[fa_left][fa_bottom][fnt_itemdesc][c_white]{ceil(global.players[0].skills.primary.stocks)} {ceil(global.players[0].skills.secondary.stocks)} {ceil(global.players[0].skills.utility.stocks)} {ceil(global.players[0].skills.special.stocks)}")

    // _draw_rect(_timer.get_width() + 25, SC_H - 16, _timer.get_width() + _stockcounter.get_width() + 24, SC_H - 10, c_black, 0.5)

    // var p = ceil(global.players[0].skills.primary.cooldown)
    // var s = ceil(global.players[0].skills.secondary.cooldown)
    // var u = ceil(global.players[0].skills.utility.cooldown)
    // var r = ceil(global.players[0].skills.special.cooldown)
    // var _cldncounter = scribble($"[fa_left][fa_bottom][fnt_itemdesc][c_white]{p ? p : "_"} {s ? s : "_"} {u ? u : "_"} {r ? r : "_"} state:{global.players[0].attack_state}")

    // _draw_rect(_timer.get_width() + 25, SC_H - 8, _timer.get_width() + _cldncounter.get_width() + 24, SC_H - 2, c_black, 0.5)

    // draw_set_font(fnt_itemdesc) draw_set_halign(fa_left) draw_set_valign(fa_bottom)
    // var names = struct_get_names(global.players[0].skills)
    // for(var i = 0; i < array_length(names); i++)
    // {
    //     var skill = global.players[0].skills[$ names[i]]
    //     var def = skill.def
    //     var xx = _timer.get_width() + 23 + i * 7

    //     if(skill.cooldown > 0)
    //     {
    //         var mult = round(6 * skill.cooldown / def.baseStockCooldown)

    //         draw_text(xx + 3, SC_H - 1, ceil(skill.cooldown))
    //         _draw_line(xx + 1, SC_H - 8.5 + mult, xx + 6, SC_H - 8.5 + mult, 1, c_white, 0.5)
    //     }
    //     if(def.baseMaxStocks + global.players[0].bonus_stocks[$ names[i]] > 1)
    //         draw_text(xx + 3, SC_H - 8, ceil(skill.stocks))
    // }
}

UILayers[UILayer].draw()

// scribble($"[fa_left][fa_top][fnt_itemdesc][c_white]{keyboard_key}").draw(1, 1)
// scribble($"[fa_left][fa_top][fnt_itemdesc][c_white]{mouse_button}").draw(1, 10)
// scribble($"[fa_left][fa_top][fnt_itemdesc][c_white]{gamepad_button(0)}").draw(1, 19)
