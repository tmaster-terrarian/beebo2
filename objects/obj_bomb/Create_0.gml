event_inherited();
destroy_on_hit = 1
max_instances = 1

grv = 0.1

image_speed = 0.15

bulleted = 0

bounces = 0
bounces_max = 1

throwsound = audio_play_sound(sn_throw_bomb, 0, 0)

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
