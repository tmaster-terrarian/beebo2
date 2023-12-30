event_inherited();
stats = global.chardefs.beebo.stats
level_stats = global.chardefs.beebo.level_stats
_apply_stats()

skills = variable_clone(global.chardefs.beebo.skills)
attack_states = variable_clone(global.chardefs.beebo.attack_states)

heat = 0
heat_max = stats.heat_max
heat_rate = stats.heat_rate
cool_rate = stats.cool_rate
cool_delay = 0
