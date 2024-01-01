event_inherited();
stats = global.chardefs.benb.stats
level_stats = global.chardefs.benb.level_stats
_apply_stats()

skills = variable_clone(global.chardefs.benb.skills)
attack_states = variable_clone(global.chardefs.benb.attack_states)

_sp =
{
    m_default: mask_player,
    m_duck: mask_player_duck,
    m_ledgegrab: mask_player_ledgegrab,
    idle: spr_benb,
    idle_lookup: spr_benb_lookup,
    crawl: spr_benb_crawl,
    duck: spr_benb_duck,
    dead: spr_benb_dead,
    jump: spr_benb_jump,
    run: spr_benb_run,
    wallslide: spr_anime_wallslide,
    ledgegrab: spr_anime_ledgegrab,
    ledgeclimb: spr_anime_ledgeclimb,
    duckPunch: spr_benb_duckPunch,
    punch_1: spr_benb_punch_1,
    punch_2: spr_benb_punch_2
}
sprite_index = _sp.idle

state = "normal"

var c1 = make_color_rgb(255, 0, 77)
ponytail_colors = [c1,c1,c1,c1,c1,c1,c1,c1,c1]
ponytail_points_count = 7
ponytail_segment_len = []
ponytail_points = []
for(var a = 0; a < ponytail_points_count; a++)
{
    ponytail_points[a] = [0, 0]
    ponytail_segment_len[a] = 1
}

_dbkey = vk_lalt

punch = 1

_jumps = jumps

states.punch = function()
{ with(other) {
    skidding = 0
    image_speed = 0.3
    can_jump = 0
    can_attack = 0
    if (sprite_index == _sp.jump)
    {
        state = "normal"
        timer0 = 0
    }
    if (sprite_index == _sp.punch_1 || sprite_index == _sp.punch_2)
    {
        can_attack = 1
        can_jump = 1
        if (input.primary())
        {
            if (vsp < 0)
                vsp /= 2
        }
    }
    if on_ground
        hsp = approach(hsp, 0, fric)
    else
        vsp = approach(vsp, vsp_max, grv)
    timer0++
}}
