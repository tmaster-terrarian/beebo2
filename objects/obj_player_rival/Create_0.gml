event_inherited();
stats = variable_clone(global.chardefs.rival.stats)
level_stats = variable_clone(global.chardefs.rival.level_stats)
_apply_stats()

skills = variable_clone(global.chardefs.rival.skills)
attack_states = variable_clone(global.chardefs.rival.attack_states)

_sp =
{
    m_default: mask_player,
    m_duck: mask_player_duck,
    m_ledgegrab: mask_player_ledgegrab,
    idle: spr_anime,
    idle_lookup: spr_player_lookup,
    crawl: spr_anime_crawl,
    duck: spr_anime_duck,
    dead: spr_anime_dead,
    jump: spr_anime_jump,
    run: spr_anime_run,
    wallslide: spr_anime_wallslide,
    ledgegrab: spr_anime_ledgegrab,
    ledgeclimb: spr_anime_ledgeclimb
}
sprite_index = _sp.idle

player_id = 1

_dbkey = vk_lalt

global.players[1] = object_index

state = "normal"

var c1 = make_color_rgb(37, 89, 137)
var c2 = make_color_rgb(32, 64, 105)
var c3 = make_color_rgb(64, 119, 163)
hair1_colors = [c1,c1,c2,c2,c1,c1,c1,c3,c2]
hair1_points_count = 9
hair1_segment_len = []
hair1_points = []
for(var a = 0; a < hair1_points_count; a++)
{
    hair1_points[a] = [0, 0]
    hair1_segment_len[a] = 1
}

hair2_colors = [c1,c1,c2,c2,c1,c1,c1,c3,c2]
hair2_points_count = 9
hair2_segment_len = []
hair2_points = []
for(var a = 0; a < hair2_points_count; a++)
{
    hair2_points[a] = [0, 0]
    hair2_segment_len[a] = 1
}
