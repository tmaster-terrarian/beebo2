//global variable definitions
// screen
global.screen_scale = 4
window_set_size(320 * global.screen_scale, 180 * global.screen_scale)

// time
global.t = 0
global.dt = 1
global.timescale = 1

// run
global.money = 0

//enums
enum team
{
    player,
    enemy,
    neutral
}
