event_inherited();
t += !global.pause // useful framerate-dependent timer

PAUSECHECK

flash = approach(flash, 0, global.dt)

if(regen)
    hp = approach(hp, hp_max, regen_rate/60 * global.dt)

if(combat_timer > 0)
    combat_timer = approach(combat_timer, 0, global.dt)
else if(combat_timer == 0)
{
    combat_timer = -1 // make sure this doesn't run infinitely untile combat timer is reset again
    in_combat = 0
    onCombatExit()
    combat_state_changed = 1
}
