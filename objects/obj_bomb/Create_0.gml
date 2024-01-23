event_inherited();
destroy_on_hit = 1

grv = 0.1

image_speed = 0.15

bulleted = 0
bulleted_delay = 6

bounces = 0
bounces_max = 1

throwsound = audio_play_sound(sn_throw_bomb, 0, 0, 1, 0, damage_boosted ? clamp(1 - (damage_boosted/(max_dmg_boost - 20)), 0.5, 1) : 1)

_oncollide_h = function()
{
    if(bounces < bounces_max)
    {
        bounces++
        hsp = -hsp * 0.9

        audio_play_sound(sn_walljump, 0, 0)
    }
    else
        instance_destroy()
}
_oncollide_v = function()
{
    if(bounces < bounces_max)
    {
        bounces++
        vsp = -vsp * 0.8
        hsp *= 0.9

        audio_play_sound(sn_walljump, 0, 0)
    }
    else
        instance_destroy()
}

_squish = function()
{
    instance_destroy()
}
