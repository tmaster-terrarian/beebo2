function initializeMods()
{
    lua_reset()

    global.modsList = global.optionsStruct.enabledMods
    array_insert(global.modsList, 0, "base")

    global.loadedMods = []

    global.modLibraryStruct = {
        registerItemDef: function(id, struct)
        {
            global.itemdefs[$ id] = itemdef(id, struct)
        }
    }

    Log("Modloader/INFO", "Found mod: base")
    var modFile = file_text_open_read("data/mod.json")
    array_push(global.loadedMods, file_json_read(modFile))
    file_text_close(modFile)
    global.loadedMods[0].data = {}
    global.loadedMods[0].data.luaState = lua_state_create()

    for(var i = 1; i < array_length(global.modsList); i++) // load mods and apply their localization data
    {
        try {
            var modFile = file_text_open_read("mods/" + global.modsList[i] + "/mod.json")
            array_push(global.loadedMods, file_json_read(modFile))
            file_text_close(modFile)

            Log("Modloader/INFO", "Found mod: '" + global.loadedMods[i].displayName + "' (" + program_directory + "mods/" + global.modsList[i] + ")")

            var state = lua_state_create()
            global.loadedMods[i].data = {}
            global.loadedMods[i].data.luaState = state
        }
        catch(err) {
            Log("Modloader/WARN", "Failed to load mod '" + global.modsList[i] + "' due to an error!\nCaused by: " + ThrowError(err, false))
        }
    }

    Log("Modloader/INFO", "Initializing found mods...")
    for(var i = 0; i < array_length(global.loadedMods); i++)
    {
        var state = global.loadedMods[i].data.luaState

        lua_global_set(state, "lib", global.modLibraryStruct)

        lua_add_file(state, (i == 0) ? "data/init.lua" : ("mods/" + global.modsList[i] + "/init.lua"))

        var itemdefs = lua_call(state, "defineItems")

        if(is_array(itemdefs))
        for(var j = 0; j < array_length(itemdefs); j++)
        {
            global.itemdefs[$ itemdefs[j].name] = itemdef(itemdefs[j].name, itemdefs[j])
        }
    }
}
