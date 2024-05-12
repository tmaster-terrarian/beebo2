event_inherited();
var ind = string_replace(object_get_name(object_index), "obj_", "")

if(struct_exists(global.chardefs, ind))
{
    stats = global.chardefs[$ ind].stats
    level_stats = global.chardefs[$ ind].level_stats
    _apply_stats()

    skills = variable_clone(global.chardefs[$ ind].skills)
    attack_states = variable_clone(global.chardefs[$ ind].attack_states)
}
else Log("Main/WARN", $"Instance {real(id)} of {object_get_name(object_index)} does not have a matching CharacterDef")

_target = noone

depth = 60

target = get_nearest_notme(x, y, _target)
retargetTimer = 300
autoaggro = 1
aggrotimer = 0
agpos = {x, y, cy:y-8}
seethruwalls = 0
input_dir = 0

braindead = 0

state = "normal"

_squish = function()
{
    DamageEvent(new DamageEventContext(noone, self, 999999/2, 0, false, 1, false))
}
