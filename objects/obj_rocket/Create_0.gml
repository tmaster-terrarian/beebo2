event_inherited();

team = Team.enemy
damage = 20
proc = 1

lifetime = 180

destroy_on_hit = 1

angle = 90 + irandom_range(-15, 15)
image_angle = 90
spd = 2.5
turnspd = 8
turnspdDecay = 0.15
target = noone

image_speed = 0.33

timer = 0

alarm[0] = 1

_oncollide_h = function()
{
    instance_destroy()
}
_oncollide_v = function()
{
    instance_destroy()
}
_squish = function()
{
    instance_destroy()
}

var snd = choose(sn_item_proc_missile_fire_01, sn_item_proc_missile_fire_02, sn_item_proc_missile_fire_03, sn_item_proc_missile_fire_04)
audio_play_sound(snd, 0, 0)
