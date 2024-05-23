if(!stopped) _t = t

if(!fixedStepExists(step)) instance_destroy()

if(abs(t - _t) >= ((life + lifeR) * 60))
{
    instance_destroy()
}
