event_inherited();
stats = global.chardefs.rival.stats
level_stats = global.chardefs.rival.level_stats
_apply_stats()

skills = variable_clone(global.chardefs.rival.skills)
attack_states = variable_clone(global.chardefs.rival.attack_states)

_sp =
{
    m_default: mask_player,
    m_duck: mask_player_duck,
    m_ledgegrab: mask_player_ledgegrab,
    idle: spr_anime,
    idle_lookup: spr_anime_lookup,
    crawl: spr_anime_crawl,
    duck: spr_anime_duck,
    dead: spr_anime_dead,
    jump: spr_anime_jump,
    run: spr_anime_run_sword,
    wallslide: spr_anime_wallslide,
    ledgegrab: spr_anime_ledgegrab,
    ledgeclimb: spr_anime_ledgeclimb,
    ghost: spr_anime_ghost
}
sprite_index = _sp.idle

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

draw_sword = 0
sword_angle = 0
_sword_angle = 0
sword_angle_locked = 0
sword_nohand = 0
sword_xscale = -1
sword_yscale = 1
swordpos = {x: 0, y: -8}

swfxtrail = 0
swfxtrailtimer = 0

combo = 1
