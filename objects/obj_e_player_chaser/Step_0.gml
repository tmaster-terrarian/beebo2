grv = 0
event_inherited()

target = global.players[0]
if(instance_exists(target) && _image_xscale == -1000)
    _image_xscale = target.facing
