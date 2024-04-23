event_inherited();

if(!in_combat)
    retargetTimer = approach(retargetTimer, 0, global.dt)

if autoaggro && !braindead
{
    if(!instance_exists(target))
        target = team_nearest(x, y, (team == Team.enemy) ? Team.player : ((team == Team.player) ? Team.enemy : choose(Team.player, Team.enemy)))
    if(retargetTimer == 0)
    {
        retargetTimer = irandom_range(200, 600)
        target = team_nearest(x, y, (team == Team.enemy) ? Team.player : ((team == Team.player) ? Team.enemy : choose(Team.player, Team.enemy)))
    }

    if(instance_exists(target))
    {
        if(collision_line(x, (bbox_bottom + bbox_top)/2, target.x, (target.bbox_bottom + target.bbox_top)/2, par_solid, 0, 1) && !seethruwalls)
        {
            if(aggrotimer < 180 && !in_combat)
                aggrotimer += global.dt
            if(aggrotimer >= 180)
            {
                agpos.x = x
                agpos.y = y
                agpos.cy = (bbox_bottom + bbox_top)/2
                target = noone
            }
        }
        else
        {
            aggrotimer = 0
            agpos.x = target.x
            agpos.y = target.y
            agpos.cy = (target.bbox_bottom + target.bbox_top)/2
        }
    }
}
