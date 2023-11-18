event_inherited();
stats = variable_clone(global.chardefs.beebo.stats)
level_stats = variable_clone(global.chardefs.beebo.level_stats)
_apply_stats()

skills = variable_clone(global.chardefs.beebo.skills)
attack_states = variable_clone(global.chardefs.beebo.attack_states)

// debug_log("Main", json_stringify(instance_get_struct(self), 1))
