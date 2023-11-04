event_inherited();
_target = noone
if(team == Team.enemy)
{
    items = global.enemyItems
}

target = get_nearest_notme(x, y, _target)
retargetTimer = 300
autoaggro = 1
aggrotimer = 0
agpos = {x:x, y:y, cy:y-8}
seethruwalls = 0
input_dir = 0

braindead = 0

INPUT =
{
    LEFT: 0,
    RIGHT: 0,
    UP: 0,
    DOWN: 0,
    JUMP: 0,
    FIRE: 0,
    PRIMARY: 0,
    SECONDARY: 0,
    UTILITY: 0,
    SPECIAL: 0
}

state = "normal"
