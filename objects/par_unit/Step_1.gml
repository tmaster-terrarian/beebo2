event_inherited();

t += 1 // useful framerate-dependent timer

__lastframe = floor(image_index)
__lastspr = sprite_index

flash = approach(flash, 0, global.dt)

if(hp_change == "noone")
    hp_change = total_hp

if(hp_change_delay > 0)
    hp_change_delay = approach(hp_change_delay, 0, global.dt)
else
{
    hp_change += (total_hp - hp_change) * 0.5 * global.dt
    if(abs(total_hp - hp_change) < 0.01)
        hp_change = total_hp
}

hp_change = clamp(hp_change, 0, total_hp_max)

if(combat_timer > 0)
    combat_timer = approach(combat_timer, 0, global.dt)
else if(combat_timer == 0)
{
    combat_timer = -1 // make sure this doesn't run infinitely untile combat timer is reset again
    in_combat = 0
    onCombatExit()
    combat_state_changed = 1
}
