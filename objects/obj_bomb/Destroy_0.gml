_size = 1
_dmg = damage
_fps = 0.3

if(bulleted)
{
    _size *= 1.3
    _fps = 0.2

    screen_shake_set(6, 60)
}
else
{
    screen_shake_set(4, 40)
}

audio_play_sound(sn_bomb_explosion, 0, 0)
audio_stop_sound(throwsound)

with(instance_create_depth(x, y, depth - 1, obj_empty, {_size, _dmg, _fps, proc, parent, team, killtimer: image_number / _fps}))
{
    sprite_index = spr_fx_explosion
    image_index = other.bulleted
    image_speed = _fps
    image_xscale = _size
    image_yscale = _size

    crit = other.bulleted

    with(par_unit)
    {
        if(place_meeting(x, y, other) && canHurt(self, other))
        {
            DamageEvent(new DamageEventContext(other.parent, id, other._dmg * (1 + other.crit * 0.5), other.proc, 1, 1))
        }
        if(place_meeting(x, y, other) && other.parent.id == id && other.crit)
        {
            var dist = point_distance(other.x, other.y + 2, x, (bbox_bottom + bbox_top)/2)
            var dir = point_direction(other.x, other.y + 2, x, (bbox_bottom + bbox_top)/2)
            hsp += lengthdir_x(80/max(16, dist), dir)
            vsp += lengthdir_y(80/max(16, dist), dir)
        }
    }
}

with(fx_particle_emitter)
{
    for(var i = 0; i < array_length(particles); i++)
    {
        var p = particles[i]
        var dist = point_distance(other.x, other.y - 2, p.x + x * !posGlobal, p.y + y * !posGlobal)
        var dir = point_direction(other.x, other.y - 2, p.x + x * !posGlobal, p.y + y * !posGlobal)
        if(dist <= 48)
            p.spdX += lengthdir_x((32 + 16 * other.bulleted)/max(16 + 4 * other.bulleted, dist), dir)
        if(dist <= 64)
            p.spdY += lengthdir_y((48 + 16 * other.bulleted)/max(16 + 4 * other.bulleted, dist), dir)
    }
}

with(fx_rope)
{
    for(var i = 1; i < rope_points_count - 1; i++)
    {
        var p = rope_points[i]
        var dist = point_distance(other.x, other.y, p.pos.x, p.pos.y)
        var dir = point_direction(other.x, other.y, p.pos.x, p.pos.y)
        if(dist <= 64)
        {
            p.pos.x += lengthdir_x((48 + 16 * other.bulleted)/max(16 + 4 * other.bulleted, dist), dir) * 12
            p.pos.y += lengthdir_y((48 + 16 * other.bulleted)/max(16 + 4 * other.bulleted, dist), dir) * 12
        }
        else if(dist <= 48)
        {
            p.pos.x += lengthdir_x((32 + 16 * other.bulleted)/max(16 + 4 * other.bulleted, dist), dir) * 12
            p.pos.y += lengthdir_y((32 + 16 * other.bulleted)/max(16 + 4 * other.bulleted, dist), dir) * 12
        }
    }
}
