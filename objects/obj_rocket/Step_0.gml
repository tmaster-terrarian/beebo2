PAUSECHECK

if(timer < 60 * 0.2)
{
    spd = approach(spd, 2, 1/(60 * 0.2) * global.dt)
}
else
{
    spd = approach(spd, 20, 0.1 * global.dt)
    turnspd = approach(turnspd, 1, 0.15 * global.dt)

    if(instance_exists(target))
    {
        angle = angleRotate(angle, point_direction(x, y, target.x, ((target.bbox_top + target.bbox_bottom) / 2)), turnspd * global.dt);
    }
    else
    {
        angle = angleRotate(angle, angle + 20, turnspd * global.dt);
    }
}

hsp = lengthdir_x(spd, angle)
vsp = lengthdir_y(spd, angle)

image_angle = round(angle / 8) * 8

timer += global.dt

if(timer % (8 / spd + 4) <= 1)
{
    instance_create_depth(x + lengthdir_x(-4, image_angle), y + lengthdir_y(-4, image_angle), depth + 2, fx_particle_emitter, {
        spr: spr_fx_steam,
        posGlobal: 1,
        dynamicRot: 0,
        max_particles: 30,
        life: 1,
        lifeR: 0.25,
        interval: -1,
        dir: image_angle + 180,
        dirR: 15,
        spd: 0.6,
        spdR: 0.2,
        spdE: 0,
        spdER: 0,
        xR: 1,
        yR: 1,
        imgE: 3,
        angle: 0,
        angleR: 0,
        angleE: 0,
        angleER: 0,
        colorE: $FF999999,
        alpha: 1,
        alphaE: 1,
        grvX: 0,
        grvY: 0.2
    })
}
