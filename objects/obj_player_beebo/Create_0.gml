event_inherited();
stats = global.chardefs.beebo.stats
level_stats = global.chardefs.beebo.level_stats
_apply_stats()

skills = variable_clone(global.chardefs.beebo.skills)
attack_states = variable_clone(global.chardefs.beebo.attack_states)

_sp =
{
    m_default: mask_player,
    m_duck: mask_player_duck,
    m_ledgegrab: mask_player_ledgegrab,
    idle: spr_player,
    idle_lookup: spr_player_lookup,
    crawl: spr_player_crawl,
    duck: spr_player_duck,
    dead: spr_player_dead,
    jump: spr_player_jump,
    run: spr_player_run,
    wallslide: spr_player_wallslide,
    ledgegrab: spr_player_ledgegrab,
    ledgeclimb: spr_player_ledgeclimb
}
sprite_index = _sp.idle

state = "intro"

heat = 0
heat_max = stats.heat_max
heat_rate = stats.heat_rate
cool_rate = stats.cool_rate
cool_delay = 0

bomb = noone
