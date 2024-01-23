__lastframe = floor(image_index)
__lastspr = sprite_index

event_inherited();

if(!string_starts_with(state, "SKILL"))
{
    if(facing != 0)
        sword_xscale = -sign(facing)
    sword_yscale = 1
    ponytail_visible = 1
    sword_angle_locked = 0
    draw_sword = 1
    sword_nohand = 0
    swordpos.x = 2; swordpos.y = -6
}

if(!string_starts_with(state, "SKILL"))
if(sprite_index == _sp.idle || sprite_index == _sp.idle_lookup)
{
    ponytail_visible = 0
    draw_sword = 1
    sword_angle_locked = 0
    sword_nohand = 0
    switch(floor(image_index)) {
        case 0: { swordpos.x = 3; swordpos.y = -5 } break;
        case 1: { swordpos.x = 3; swordpos.y = -5 } break;
        case 2: { swordpos.x = 3; swordpos.y = -5 } break;
        case 3: { swordpos.x = 3; swordpos.y = -6 } break;
        case 4: { swordpos.x = 3; swordpos.y = -6 } break;
        case 5: { swordpos.x = 3; swordpos.y = -6 } break;
    }
}
else if(running && sprite_index != _sp.crawl)
{
    ponytail_visible = 1
    sword_angle_locked = 0
    draw_sword = 1
    sword_nohand = 0
    sword_angle = (round(floor(image_index) / 2) % 2) * -4
    switch(floor(image_index)) {
        case 0: { swordpos.x = 2; swordpos.y = -4 } break;
        case 1: { swordpos.x = 2; swordpos.y = -4 } break;
        case 2: { swordpos.x = 4; swordpos.y = -6 } break;
        case 3: { swordpos.x = 2; swordpos.y = -5 } break;
        case 4: { swordpos.x = 2; swordpos.y = -4 } break;
        case 5: { swordpos.x = 1; swordpos.y = -4 } break;
        case 6: { swordpos.x = 0; swordpos.y = -4 } break;
        case 7: { swordpos.x = 2; swordpos.y = -4 } break;
    }
}
else if(sprite_index == _sp.jump)
{
    ponytail_visible = 1
    draw_sword = 1
    sword_angle_locked = 1
    sword_nohand = 0
    switch(floor(image_index)) {
        case 0: { swordpos.x = 0; swordpos.y = -5; sword_angle = 45 * facing } break;
        case 1: { swordpos.x = 3; swordpos.y = -7; sword_angle = 45 * facing } break;
        case 2: { swordpos.x = 1; swordpos.y = -7; sword_angle = 30 * facing } break;
        case 3: { swordpos.x = 1; swordpos.y = -7; sword_angle = 30 * facing } break;
        case 4: { swordpos.x = 3; swordpos.y = -8; sword_angle = -10 * facing } break;
        case 5: { swordpos.x = 5; swordpos.y = -9; sword_angle = -15 * facing } break;
    }
}
else if(sprite_index == _sp.crawl)
{
    ponytail_visible = 0
    sword_angle_locked = 1
    draw_sword = 1
    sword_nohand = 1
    swordpos.x = 4; swordpos.y = -4 - (floor(image_index) == 0 || floor(image_index) == 1) - (floor(image_index) == 4 || floor(image_index) == 5) - (floor(image_index) == 6 || floor(image_index) == 7) * 2
    sword_angle = 10 * facing
}
else if(duck)
{
    ponytail_visible = 0
    sword_angle_locked = 1
    draw_sword = 1
    sword_nohand = 1
    swordpos.x = 5; swordpos.y = -6 + duck
    sword_angle = 5 * facing
}
else if(state == "wallslide")
{
    sword_yscale = -1
    ponytail_visible = 0
    sword_angle_locked = 1
    draw_sword = 1
    sword_nohand = 1
    swordpos.x = -1; swordpos.y = -6
    sword_angle = -100 * facing
}
else if(state == "ledgegrab")
{
    ponytail_visible = 0
    sword_angle_locked = 0
    draw_sword = 1
    sword_nohand = 1
    swordpos.x = -4; swordpos.y = 4
}
else if(state == "ledgeclimb")
{
    ponytail_visible = 0
    sword_angle_locked = 1
    draw_sword = 0
    sword_nohand = 1
}

if(!sword_angle_locked && !string_starts_with(state, "SKILL"))
{
    var floorx = -8 * facing
    var floory = 3
    for(var i = 0; i < 20; i++)
    {
        var d = point_direction(0, 0, floorx, floory) + 2 * facing
        if(!position_meeting(x + swordpos.x * facing + lengthdir_x(8, d), y + lengthdir_y(8, d), par_solid))
        {
            floorx = lengthdir_x(8, d)
            floory = lengthdir_y(8, d)
        }
    }
    sword_angle = cycle(point_direction(0, 0, floorx, floory) + 180 * (facing == 1), -180, 180) - 7 * input_dir

    if(abs(hsp) > 1)
    {
        var canPlaceSpark = 0
        if(position_meeting(x + swordpos.x * facing + lengthdir_x(-12 * facing, sword_angle), y + lengthdir_y(12, d), par_solid))
        {
            for(var i = 0; i < 10; i++)
            {
                if position_meeting(x + swordpos.x * facing + lengthdir_x(-12 * facing, sword_angle), y + lengthdir_y(12, d) - i, par_solid)
                    continue
                else
                {
                    canPlaceSpark = (__lastspr == sprite_index && floor(__lastframe) != floor(image_index)) * (i + 1)
                    break
                }
            }
        }
        if(canPlaceSpark)
        {
            with(instance_create_depth(x + swordpos.x * facing + lengthdir_x(-12 * facing, sword_angle) + irandom_range(-3, 1) * facing, y + lengthdir_y(12, d) - canPlaceSpark, depth - 2, fx_spark))
            {
                hsp = random_range(-3, -1) * other.facing
                vsp = random_range(-2.5, -0.5)
            }
        }
    }
}

var dx = lengthdir_x(1, sword_angle)
var dy = lengthdir_y(1, sword_angle)
var dirx = lengthdir_x(1, _sword_angle)
var diry = lengthdir_y(1, _sword_angle)

dirx += (dx - dirx) * 0.45 * global.dt
diry += (dy - diry) * 0.45 * global.dt

_sword_angle = point_direction(0, 0, dirx, diry)

// _sword_angle += cycle(sword_angle - _sword_angle, -180, 180) * 0.25

// very helpful for later ithink
// var len = sqrt(dx * dx + dy * dy)
// dx /= (len) ? len : 1.0
// dy /= (len) ? len : 1.0

swfxtrailtimer = approach(swfxtrailtimer, 0, global.dt)
if(swfxtrail && swfxtrailtimer == 0)
{
    swfxtrailtimer = 4

    var sx = swordpos.x * facing * stretch
    var sy = swordpos.y * squash

    var ax = lengthdir_x(point_distance(0, 0, sx, sy), point_direction(0, 0, sx, sy) + image_angle)
    var ay = lengthdir_y(point_distance(0, 0, sx, sy), point_direction(0, 0, sx, sy) + image_angle)

    create_fxtrail_ext(spr_anime_sword, 1, x + ax, y + ay, sword_xscale, squash, _sword_angle + image_angle, c_white, 1)
}
