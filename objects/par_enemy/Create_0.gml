event_inherited();
_target = noone
if(team == Team.enemy)
{
    items = global.enemyItems
    _target = obj_player
}
else if(team == Team.player)
{
    _target = par_enemy
}
else if(team == Team.neutral)
{
    items = global.enemyItems
    _target = par_unit
}

target = get_nearest_notme(x, y, _target)
retargetTimer = 300
autoaggro = 1
aggrotimer = 0
agpos = {x:x, y:y, cy:y-8}
seethruwalls = 0

braindead = 0

INPUT =
{
    LEFT: 0,
    RIGHT: 0,
    UP: 0,
    DOWN: 0,
    JUMP: 0,
    FIRE: 0
}

state = "normal"
