#macro PROGRAM_DIR string_replace_all(program_directory, "\\", "/")

function initializeMods()
{
    lua_reset()

    global.modsList = global.optionsStruct.enabledMods
    array_insert(global.modsList, 0, "base")

    global.loadedMods = []

    global.modLibraryStruct = {
        registerItemDef: function(id, struct = {})
        {
            global.itemdefs[$ id] = itemdef(id, struct)
            global.itemdefs_by_rarity[global.itemdefs[$ id].rarity][$ id] = global.itemdefs[$ id]
        },
        registerBuffDef: function(id, struct)
        {
            global.buffdefs[$ id] = buffdef(id, struct)
        },

        createDamageEventContext: function(attacker, target, damage, proc, use_attacker_items = 1, force_crit = -1, isReduceable = 1)
        {
            return new DamageEventContext(attacker, target, damage, proc, use_attacker_items, force_crit, isReduceable)
        },

        events: {
            doDamageEvent: function(ctx)
            {
                damage_event(ctx)
            }
        },

        unit: {
            inflictBuff: function(buff_id, context, duration = -1, stacks = 1)
            {
                return buff_instance_create(buff_id, context, duration, stacks)
            },
            inflictBuffNoContext: function(buff_id, target, duration = -1, stacks = 1)
            {
                return buff_instance_create_headless(buff_id, target, duration, stacks)
            }
        },

        instance: {
            get: function(ins, prop)
            {
                with(ins) return variable_instance_get(id, prop);
                if(!instance_exists(ins))
                {
                    lua_show_error("Couldn't find instance " + string(q));
                }
                return undefined;
            },
            set: function(ins, prop, val)
            {
                with(ins) variable_instance_set(id, prop, val);
                if(!instance_exists(ins))
                {
                    lua_show_error("Couldn't find instance " + string(q));
                }
            },
            destroy: function(ins)
            {
                instance_destroy(ins)
            }
        },

        enums: {
            Team: {
                player: 0,
                enemy: 1,
                neutral: 2
            },
            ItemRarity: {
                none: 0,
                common: 1,
                rare: 2,
                legendary: 3,
                special: 4
            },
            DamageColor: {
                generic: 0,
                crit: 1,
                heal: 2,
                revive: 3,
                playerhurt: 4,
                bleed: 5,
                immune: 6
            }
        },

        logInfo: function(text)
        {
            Log("Main/INFO", string(text))
        }
    }

    Log("Modloader/INFO", "Found mod: 'base' (internal)")
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

            Log("Modloader/INFO", "Found mod: '" + global.loadedMods[i].displayName + "' (" + PROGRAM_DIR + "mods/" + global.modsList[i] + ")")

            var state = lua_state_create()
            global.loadedMods[i].data = {}
            global.loadedMods[i].data.luaState = state

            if(directory_exists("mods/" + global.modsList[i] + "/data"))
            {
                if(file_exists("mods/" + global.modsList[i] + "/data/lang.json"))
                {
                    var json = {}
                    var file = file_text_open_read("mods/" + global.modsList[i] + "/data/lang.json")
                    json = file_json_read(file)
                    file_text_close(file)

                    struct_assign(global.lang, json)
                }
            }
        }
        catch(err) {
            Log("Modloader/WARN", "Failed to load mod '" + global.modsList[i] + "'!\nCaused by: " + ThrowError(err, false))
        }
    }

    locale.reload()

    Log("Modloader/INFO", "Initializing mods")
    for(var i = 0; i < array_length(global.loadedMods); i++)
    {
        var state = global.loadedMods[i].data.luaState
        var path = "mods/" + global.modsList[i] + "/"

        var lib = struct_clone(global.modLibraryStruct)
        lua_global_set(state, "lib", lib)
        global.loadedMods[i].data.libCopy = lib

        lua_add_code(state, @"__idfields = __idfields or { };
        debug.setmetatable(0, {
            __index = function(self, name)
                if (__idfields[name]) then
                    return _G[name];
                else
                    return lib.instance.get(self, name);
                end
            end,
            __newindex = lib.instance.set,
        })

        ref = {
            __r2i = { },
            __i2r = { },
            __next = 0
        }
        function ref.toid(fn)
            local id = ref.__r2i[fn]
            if (id == nil) then
                id = ref.__next
                ref.__next = id + 1
                ref.__r2i[fn] = id
                ref.__i2r[id] = fn
            end
            return id
        end
        function ref.fromid(id)
            return ref.__i2r[id]
        end
        function ref.free(fn)
            local id
            if (type(fn) == 'number') then
                id = fn
                fn = ref.__i2r[id]
            else
                id = ref.__r2i[fn]
            end
            ref.__r2i[fn] = nil
            ref.__i2r[id] = nil
        end")

        lua_add_file(state, (i == 0) ? "data/init.lua" : (path + "init.lua"))

        Log("Modloader/INFO", global.loadedMods[i].displayName + " finished initializing")
    }
}
