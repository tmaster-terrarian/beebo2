event_inherited()

particle.interval = 0

instance_create_depth(x, y, depth - 1, fx_particle_emitter, {
    spr: spr_8x8centered,
    life: 1.2,
    lifeR: 0.2,
    max_particles: 8,
    posGlobal: 1,
    interval: 0,
    emission: 8,
    scale: 0.75,
    scaleE: 0.125,
    scaleER: 0.125,
    dirR: 105,
    spd: 0.6,
    spdR: 0.1,
    spdE: -0.1,
    xR: 4 * _image_xscale - 2,
    yR: 4 * image_yscale - 2,
    color: c_red,
    alphaE: 0.5,
    alphaER: 0.25,
    grvY: -0.15,
})

screen_shake_set(3, 60)

audio_play_sound(sn_cube_death, 0, false, 3)

surface_free(surf)
