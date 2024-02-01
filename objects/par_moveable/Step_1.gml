on_ground = (place_meeting(x, y + 1, par_solid) && !instance_place(x, y + 1, par_solid).ghost && !instance_place(x, y + 1, par_solid).nocollide && (!place_meeting(x, y, par_jumpthru) || vsp > 0))
