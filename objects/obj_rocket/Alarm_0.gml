target = team_nearest(x, y, (team == Team.enemy) ? Team.player : ((team == Team.player) ? Team.enemy : choose(Team.player, Team.enemy)))

if(instance_exists(target))
with(instance_create_depth(target.x, target.y, target.depth - 5, fx_target_reticle))
{
    parent = other
    target = other.target
}
