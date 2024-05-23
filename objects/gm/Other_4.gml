global.zoom = 1
if(!instance_exists(obj_camera))
{
    // holy shit splitscreen
    if(global.usesplitscreen)
    {
        for(var i = 0; i < array_length(global.players); i++)
        {
            instance_create_depth(0, 0, 0, obj_camera, {cam_id: i, target: global.players[i]})
        }
    }
    else
        instance_create_depth(0, 0, 0, obj_camera, {cam_id: 0, target: obj_player})
}

if(room != startRoom)
struct_foreach(global.spriteCache as (name, value) {
    if(!array_contains(global.builtinSpriteList, name))
    {
        sprite_delete(value)
        struct_remove(global.spriteCache, name)
    }
})
else
{
    set_music(bgm_placeholder, 1, 0)
}
