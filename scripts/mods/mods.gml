#macro PROGRAM_DIR string_replace_all(program_directory, "\\", "/")

function addCodeFromFile(state, dir)
{
    var f = file_text_open_read(string(dir))
    if(!f)
    {
        Log("Apollo/ERROR", $"failed to read file from path '{string(dir)}'")
        return;
    }
    var _code = file_text_read_whole(f)
    file_text_close(f)
    return state.addCode(_code)
}

function initializeMods()
{
    lua_init()

    global.modsList = variable_clone(global.optionsStruct.enabledMods)
    array_insert(global.modsList, 0, "base")

    global.loadedMods = []

    Log("Modloader/INFO", "Found mod: 'base' (builtin)")
    var modFile = file_text_open_read("data/mod.json")
    array_push(global.loadedMods, file_json_read(modFile))
    file_text_close(modFile)
    global.loadedMods[0].data = {}
    global.loadedMods[0].data.luaState = new LuaState()

    for(var i = 1; i < array_length(global.modsList); i++) // load mods and apply their localization data
    {
        try {
            var modFile = file_text_open_read("mods/" + global.modsList[i] + "/mod.json")
            var _mod = file_json_read(modFile)
            array_push(global.loadedMods, _mod)
            file_text_close(modFile)

            Log("Modloader/INFO", "Found mod: '" + _mod.displayName + "' (" + PROGRAM_DIR + "mods/" + _mod.id + ")")

            var state = new LuaState()

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

        var initPath = path + "init.lua"
        if(i == 0) initPath = "data/init.lua"
        if(file_exists(initPath))
        {
            addCodeFromFile(state, initPath)
            Log("Modloader/INFO", "Finished initializing mod '" + _mod.id + "' with " + string(state))
        }
        else if(i == 0) Log("Main/ERROR", "base mod contents could not be initialized! All vanilla mod features will be either missing or very broken!")
    }
}

enum ModAssetType
{
    Item,
    Buff,
    ModifierArt
}

global.spriteCache = {}
global.builtinSpriteList = []

// first feature to introduce significant mod load order, which allows for mods that resprite other mods (including base)
function loadSprite(name, assetType)
{
    if(struct_exists(global.spriteCache, name)) return global.spriteCache[$ name]

    var subPath = ""
    switch(assetType)
    {
        case ModAssetType.Item: subPath = "item/"; break;
        case ModAssetType.Buff: subPath = "buff/"; break;
        case ModAssetType.ModifierArt: subPath = "modifier/"; break;
    }

    var assetPath = undefined
    var jsonPath = undefined
    for(var i = 0; i < array_length(global.loadedMods); i++)
    {
        var _mod = global.loadedMods[i]
        var modId = _mod.id
        var path = _mod.id != "base" ? "mods/" + _mod.id + "/" : "data/"

        if(!directory_exists(path + "assets/sprites")) continue;

        path = path + "assets/sprites/" + subPath

        if(file_exists(path + name + ".png")) assetPath = path + name + ".png"
        if(file_exists(path + name + ".json")) jsonPath = path + name + ".json"
    }

    if(is_undefined(assetPath))
    {
        var builtinSpr = asset_get_index(name)
        if(sprite_exists(builtinSpr))
        {
            global.spriteCache[$ name] = builtinSpr
            array_push(global.builtinSpriteList, name)
            return builtinSpr
        }

        // this way we can get the call stack for completely free!
        try
        {
            a = a + 1
        }
        catch(err)
        {
            err.message = "No sprite exists with the name \"" + name + "\""
            array_delete(err.stacktrace, 0, 1)
            ThrowError(err, false, true)
        }

        return -1
    }

    var spr

    if(!is_undefined(jsonPath))
    {
        var json = undefined

        var file = file_text_open_read(jsonPath)
        json = file_json_read(file)
        file_text_close(file)

        var pivot = [0, 0]
        if(struct_exists(json, "pivot") && is_array(json.pivot) && array_length(json.pivot) >= 2)
        {
            pivot[0] = json.pivot[0]
            pivot[1] = json.pivot[1]
        }

        spr = sprite_add(
            assetPath,
            struct_exists(json, "frameCount") && is_numeric(json.frameCount) ? max(1, floor(real(json.frameCount))) : 1,
            false,
            false,
            pivot[0],
            pivot[1]
        )

        var w = sprite_get_width(spr)
        var h = sprite_get_height(spr)

        if(struct_exists(json, "bbox") && is_struct(json.bbox))
        {
            var shape = struct_exists(json.bbox, "type") && is_string(json.bbox.type) ? json.bbox.type : "box"
            var mode  = struct_exists(json.bbox, "mode") && is_string(json.bbox.mode) ? json.bbox.mode : "auto"

            switch(mode)
            {
                case "manual": mode = 2; break;
                case "full": mode = 1; break;
                case "auto": default: mode = 0; break;
            }

            switch(shape)
            {
                case "ellipse": shape = bboxkind_ellipse; break;
                case "precise": shape = bboxkind_precise; break;
                case "box": default: shape = bboxkind_rectangular; break;
            }

            sprite_collision_mask(
                spr,
                false,
                mode,
                struct_exists(json.bbox, "left") && is_numeric(json.bbox.left) ? real(json.bbox.left) : 0,
                struct_exists(json.bbox, "right") && is_numeric(json.bbox.right) ? real(json.bbox.right) : w - 1,
                struct_exists(json.bbox, "top") && is_numeric(json.bbox.top) ? real(json.bbox.top) : 0,
                struct_exists(json.bbox, "bottom") && is_numeric(json.bbox.bottom) ? real(json.bbox.bottom) : h - 1,
                shape,
                128
            )
        }
    }
    else
    {
        spr = sprite_add(assetPath, 1, false, false, 0, 0)

        var w = sprite_get_width(spr)
        var h = sprite_get_height(spr)

        sprite_collision_mask(spr, false, 0, 0, w - 1, 0, h - 1, bboxkind_rectangular, 128)
    }

    sprite_set_speed(spr, 1, spritespeed_framespergameframe)

    global.spriteCache[$ name] = spr

    return spr
}

function modLibrary(state) constructor
{
    self._state = state
    self.modId = ""

    self.vars = {}

    self.setVarFrom = function(to, from)
    {
        self.setVar(string(to), self.getVar(string(from)))
    }

    self.setVar = function(key, value)
    {
        var split = string_split(key, ".")
        var g = self.vars
        for(var i = 0; i < array_length(split) - 1; i++)
        {
            if(!struct_exists(g, split[i]))
            {
                g[$ split[i]] = {}
            }
            if(!is_struct(g[$ split[i]]) && !is_method(g[$ split[i]]))
                throw "Invalid path: '" + key + "' (at '" + split[i] + "')"

            g = g[$ split[i]]
        }
        g[$ split[array_length(split) - 1]] = value
    }

    self.getVar = function(key)
    {
        var split = string_split(key, ".")
        var g = self.vars
        for(var i = 0; i < array_length(split); i++)
        {
            if(!struct_exists(g, split[i]))
            {
                g[$ split[i]] = {}
            }
            if(!is_struct(g[$ split[i]]) && !is_method(g[$ split[i]]) && i < (array_length(split) - 1))
                throw "Invalid path: '" + key + "' (at '" + split[i] + "')"

            g = g[$ split[i]]
        }
        return g
    }

    self.createDamageEventContext = function(attacker, target, damage, proc, use_attacker_items = 1, force_crit = -1, isReduceable = 1)
    {
        return new DamageEventContext(attacker, target, damage, proc, use_attacker_items, force_crit, isReduceable)
    }

    // self.gmlMethod = function(luaFunctionName)
    // {
    //     return lualib_f_gmlMethod(luaFunctionName, self._state)
    // }

    self.events = {}
    self.events.doDamageEvent = function(ctx)
    {
        DamageEvent(DamageEventContext.fromLua(ctx))
    }

    self.unit = {}
    self.unit.inflictBuff = function(buff_id, context, duration = -1, stacks = 1)
    {
        return buff_instance_create(buff_id, DamageEventContext.fromLua(context), duration, stacks)
    }
    self.unit.inflictBuffSimple = function(buff_id, target, duration = -1, stacks = 1)
    {
        return buff_instance_create_headless(buff_id, lualib_fixInstanceId(target), duration, stacks)
    }

    self.instance = {
        get: function(ins, prop)
        {
            var ref = lualib_fixInstanceId(ins)
            if(!instance_exists(ref))
            {
                lua_show_error("Couldn't find instance " + string(ins));
            }
            else return variable_instance_get(ref, string(prop));

            return undefined;
        },
        set: function(ins, prop, val)
        {
            var ref = lualib_fixInstanceId(ins)
            if(!instance_exists(ref))
            {
                lua_show_error("Couldn't find instance " + string(ins));
            }
            else variable_instance_set(ref, string(prop), val);
        },
        exists: function(ins)
        {
            return instance_exists(lualib_fixInstanceId(ins))
        },
        create: function(x, y, obj)
        {
            return instance_create_depth(x, y, 0, lualib_fixRefId("object", ins))
        },
        createDepth: function(x, y, depth, obj)
        {
            return instance_create_depth(x, y, depth, lualib_fixRefId("object", ins))
        },
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

    self.log = function(value)
    {
        Log(self.modId + "/INFO", string(value))
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
