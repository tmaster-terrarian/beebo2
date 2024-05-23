t = 0
_t = 0
particles = []

sprite_index = spr

hasOwner = owner != noone

createParticle = function ()
{
    var p = {}
    p.dir = dir + random_range(-dirR, dirR)
    p.spd = spd + random_range(-spdR, spdR)
    p.x = x * posGlobal + random_range(-xR, xR)
    p.y = y * posGlobal + random_range(-yR, yR)
    p.img = img + random_range(-imgR, imgR)
    p.scale = scale + random_range(-scaleR, scaleR)
    p.angle = angle + random_range(-angleR, angleR)
    p.color = merge_color(color, colorE, random_range(-colorR, colorR))
    p.alpha = clamp(alpha + random_range(-alphaR, alphaR), 0, 1)
    p.life = 0

    p.dirS = p.dir
    p.spdS = p.spd
    p.imgS = p.img
    p.scaleS = p.scale
    p.angleS = p.angle
    p.colorS = p.color
    p.alphaS = p.alpha

    p.spdE = spdE + random_range(-spdER, spdER)
    p.imgE = imgE + random_range(-imgER, imgER)
    p.scaleE = scaleE + random_range(-scaleER, scaleER)
    p.angleE = angleE + random_range(-angleER, angleER)
    p.colorE = merge_color(colorE, color, random_range(-colorER, colorER))
    p.alphaE = clamp(alphaE + random_range(-alphaER, alphaER), 0, 1)
    p.lifeM = life + random_range(-lifeR, lifeR)

    p.grvX = grvX
    p.grvY = grvY
    p.spdX = 0
    p.spdY = 0

    return p
}

lerpAngle = function(a, b, t)
{
    return (a + angle_difference(b, a) * t)
}

stopped = false

stop = function()
{
    stopped = true
    interval = 0
}

step = addFixedStep(function() {
    for(var i = 0; i < array_length(particles); i++)
    {
        if(i >= array_length(particles))
            break
        var p = particles[i]
        p.life += 1/60
        if(p.life >= p.lifeM)
        {
            array_delete(particles, i, 1)
            i--
            continue
        }
        var _px = p.x
        var _py = p.y

        p.spd = lerp(p.spdS, p.spdE, p.life / p.lifeM)
        p.spdX = approach(p.spdX, p.grvX, max(0.03, abs(p.grvX/10)))
        p.spdY = approach(p.spdY, p.grvY, max(0.03, abs(p.grvY/10)))
        p.x += lengthdir_x(p.spd, p.dir) + p.spdX
        p.y += lengthdir_y(p.spd, p.dir) + p.spdY
        p.img = lerp(p.imgS, p.imgE, p.life / p.lifeM)
        p.scale = lerp(p.scaleS, p.scaleE, p.life / p.lifeM)
        if(dynamicRot)
            p.angle = point_direction(_px, _py, p.x, p.y)
        else
            p.angle = angleRotate(p.angle, p.angleE, angle_difference(p.angleE, p.angleS) / (p.lifeM * 60))
        p.alpha = lerp(p.alphaS, p.alphaE, p.life / p.lifeM)
        p.color = (merge_color(p.colorS, p.colorE, p.life / p.lifeM))
    }
    if(interval >= 1 && t % max(1, interval + irandom_range(-intervalR, intervalR)) == 0)
    {
        repeat(emission + irandom_range(-emissionR, emissionR))
        {
            if(array_length(particles) < max_particles)
            {
                array_push(particles, createParticle())
            }
        }
    }
    if(interval <= 0)
    {
        if(t == 0)
        {
            repeat(emission + irandom_range(-emissionR, emissionR))
            {
                if(array_length(particles) < max_particles)
                {
                    array_push(particles, createParticle())
                }
            }
        }
        if(array_length(particles) == 0)
            stop()
    }

    t++
})
