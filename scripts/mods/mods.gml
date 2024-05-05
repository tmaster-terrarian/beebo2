#macro PROGRAM_DIR string_replace_all(program_directory, "\\", "/")

function initializeMods()
{
    global.modsList = variable_clone(global.optionsStruct.enabledMods)
    array_insert(global.modsList, 0, "base")

    global.loadedMods = []

    Log("Modloader/INFO", "Found mod: 'base' (builtin)")
    var modFile = file_text_open_read("data/mod.json")
    array_push(global.loadedMods, file_json_read(modFile))
    file_text_close(modFile)
    global.loadedMods[0].data = {}
    global.loadedMods[0].data.luaState = lua_state_create()

    for(var i = 1; i < array_length(global.modsList); i++) // load mods and apply their localization data
    {
        try {
            var modFile = file_text_open_read("mods/" + global.modsList[i] + "/mod.json")
            var _mod = file_json_read(modFile)
            array_push(global.loadedMods, _mod)
            file_text_close(modFile)

            Log("Modloader/INFO", "Found mod: '" + _mod.displayName + "' (" + PROGRAM_DIR + "mods/" + _mod.id + ")")

            var state = new LuaState()
            state.addCodeFromFile = function(dir)
            {
                var f = file_text_open_read(string(dir))
                if(!f)
                {
                    Log("Apollo/ERROR", $"failed to read file from path '{string(dir)}'")
                    return;
                }
                var _code = file_text_read_whole(f)
                file_text_close(f)
                return lua_add_code(__ptr__, _code)
            }

            _mod.data = {}
            _mod.data.luaState = state

            if(directory_exists("mods/" + _mod.id + "/data"))
            {
                if(file_exists("mods/" + _mod.id + "/data/lang.json"))
                {
                    var json = {}
                    var file = file_text_open_read("mods/" + _mod.id + "/data/lang.json")
                    json = file_json_read(file)
                    file_text_close(file)

                    struct_assign(global.lang, json)
                }
            }
        }
        catch(err) {
            Log("Modloader/WARN", "Failed to load mod '" + global.modsList[i] + "'!")
            ThrowError(err, true, true)
        }
    }

    Locale.reload()

    Log("Modloader/INFO", "Initializing loaded mods..")
    for(var i = 0; i < array_length(global.loadedMods); i++)
    {
        var _mod = global.loadedMods[i]
        var state = _mod.data.luaState

        var path = "mods/" + _mod.id + "/"

        var lib = new modLibrary(state)
        lib.modId = _mod.id
        _mod.data.libCopy = lib

        lualib_addModLibrary(state, lib)

        state.addCodeFromFile(i == 0 ? "data/init.lua" : path + "init.lua")

        Log("Modloader/INFO", "initialized " + _mod.id + " with state " + string(state))
    }
}

function modLibrary(state) constructor
{
    self._state = state
    self.modId = ""

    self.registerItemDef = function(id, struct = {})
    {
        global.itemdefs[$ id] = itemdef(id, struct)
        global.itemdefs_by_rarity[global.itemdefs[$ id].rarity][$ id] = global.itemdefs[$ id]
        return global.itemdefs[$ id]
    }
    self.registerBuffDef = function(id, struct)
    {
        global.buffdefs[$ id] = buffdef(id, struct)
        return global.buffdefs[$ id]
    }

    self.createDamageEventContext = function(attacker, target, damage, proc, use_attacker_items = 1, force_crit = -1, isReduceable = 1)
    {
        return new DamageEventContext(attacker, target, damage, proc, use_attacker_items, force_crit, isReduceable)
    }

    self.gmlMethod = function(luaFunctionName)
    {
        return lualib_f_gmlMethod(luaFunctionName, self._state)
    }

    self.events = {
        doDamageEvent: function(ctx)
        {
            ctx.attacker = lualib_fixInstanceId(ctx.attacker)
            ctx.target = lualib_fixInstanceId(ctx.target)
            DamageEvent(ctx)
        }
    }

    self.unit = {
        inflictBuff: function(buff_id, context, duration = -1, stacks = 1)
        {
            context.attacker = lualib_fixInstanceId(context.attacker)
            context.target = lualib_fixInstanceId(context.target)
            return buff_instance_create(buff_id, context, duration, stacks)
        },
        inflictBuffNoContext: function(buff_id, target, duration = -1, stacks = 1)
        {
            return buff_instance_create_headless(buff_id, lualib_fixInstanceId(target), duration, stacks)
        }
    }

    self.instance = {
        // obsoleted with Apollo v3 (probably)
        // get: function(ins, prop)
        // {
        //     var ref = lualib_fixInstanceId(ins)
        //     if(!instance_exists(ref))
        //     {
        //         lua_show_error("Couldn't find instance " + string(ins));
        //     }
        //     else return variable_instance_get(ref, string(prop));
        //
        //     return undefined;
        // },
        // set: function(ins, prop, val)
        // {
        //     var ref = lualib_fixInstanceId(ins)
        //     if(!instance_exists(ref))
        //     {
        //         lua_show_error("Couldn't find instance " + string(ins));
        //     }
        //     else variable_instance_set(ref, string(prop), val);
        // },
        destroy: function(ins)
        {
            instance_destroy(lualib_fixInstanceId(ins))
        }
    }

    self.enums = {
        Team: {
            player: Team.player,
            enemy: Team.enemy,
            neutral: Team.neutral
        },
        ItemRarity: {
            none: ItemRarity.none,
            common: ItemRarity.common,
            rare: ItemRarity.rare,
            legendary: ItemRarity.legendary,
            special: ItemRarity.special
        },
        DamageColor: {
            generic: DamageColor.generic,
            crit: DamageColor.crit,
            heal: DamageColor.heal,
            revive: DamageColor.revive,
            playerhurt: DamageColor.playerhurt,
            bleed: DamageColor.bleed,
            immune: DamageColor.immune
        },
        HealColor: {
            generic: HealColor.generic,
            regen: HealColor.regen,
            hidden: HealColor.hidden
        }
    }

    self.log = function(text)
    {
        Log(self.modId + "/INFO", string(text))
    }

    self.rng = {
        Random: function(x)
        {
            return random(x)
        },

        RandomRange: function(_min, _max)
        {
            return random_range(_min, _max)
        },

        RandomInt: function(x)
        {
            return irandom(x)
        },

        RandomRangeInt: function(_min, _max)
        {
            return irandom_range(_min, _max)
        },

        Roll: function(val)
        {
            if(val == 0 || val == 1) return bool(val)
            return bool(random(1) <= val)
        }
    }
}
