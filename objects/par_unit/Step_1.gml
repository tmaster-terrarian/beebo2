event_inherited();
t += !global.pause

PAUSECHECK

if(flash > 0)
    flash = approach(flash, 0, global.dt)

hp = approach(hp, hp_max, regen_rate/60 * global.dt)
