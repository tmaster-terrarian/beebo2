hsp = (round(xstart + sin((2/w_freq) * pi * (t / 60)) * w_amp) - x) * !_vertical
vsp = (round(ystart + sin((2/w_freq) * pi * (t / 60)) * w_amp) - y) * _vertical

t += (delta_time / 1000000) * 60
