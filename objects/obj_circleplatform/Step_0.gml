hsp = (round(xstart + cos((2/w_freq) * pi * (t / 60)) * w_amp) - x)
vsp = (round(ystart + sin((2/w_freq) * pi * (t / 60)) * w_amp) - y)

t += (delta_time / 1000000) * 60 * global.timescale * !global.pause
