if(object_index == obj_player) return;

if(hp <= 0) && !ded
{
    ded = 1
    event_perform(ev_other, ev_user2)
}

if(y > room_height + 48)
    hp = 0

if(!on_ground)
    vsp = approach(vsp, 20, grv)
