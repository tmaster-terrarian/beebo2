function lualib_fixInstanceId(value)
{
    return handle_parse($"ref instance {int64(value.get("id"))}")
}

function lualib_fixRefId(value, type = "instance")
{
    return handle_parse($"ref {type} {int64(value.get("id"))}")
}

function luaRef_keys(luaRef)
{
    var state = luaRef.__state__

    state.set("o", luaRef)
    state.addCode(/*lua*/@'
        s = {}
        n = 0
        for k, v in pairs(o) do
            n = n + 1
            s[n] = k
        end
    ')
    state.set("o", undefined)

    var l = state.get("n")
    var arr = array_create(l)
    for(var i=0;i<l;i++){arr[i]=state.get("s").get(i+1)} // golfged
    return arr
}

function luaRef_values(luaRef)
{
    var state = luaRef.__state__
    state.set("o", luaRef)
    state.addCode(/*lua*/@'
        s = {}
        n = 0
        for k, v in pairs(o) do
            n = n + 1
            s[n] = v
        end
    ') // s[n] = v instead of k
    state.set("o", undefined)

    var l = state.get("n")
    var arr = array_create(l)
    for(var i=0;i<l;i++){arr[i]=state.get("s").get(i+1)}
    return arr
}

function luaRef_assignToStruct(struct, luaRef)
{
    var names = luaRef_keys(luaRef)
    var size = array_length(names)

    for (var i = 0; i < size; i++) {
        var name = names[i]
        var element = luaRef.get(name)
        if(is_lua_ref(element))
            if(element.__type__ == "LuaFunction")
                struct_set(struct, name, lualib_f_gmlMethod(element))
            else
                struct_set(struct, name, __a({}, element))
        else
            struct_set(struct, name, element)
    }
    return struct
}

function lualib_toArray(luaRef)
{
    var state = luaRef.__state__
    var l = luaRef.length()
    var arr = array_create(l)
    for(var i=0;i<l;i++){arr[i]=luaRef.get(i+1)}
    return arr
}

function lualib_get(state, path) // example: (state, "a.b.c") => 1
{
    var split = string_split(path, ".")
    var g = state
    for(var i = 0; i < array_length(split); i++)
    {
        g = g.get(split[i])
        if(g == undefined) break
    }
    return g
}

function lualib_set(state, path, value) // example: (state, "a.b.c", 3)
{
    var split = string_split(path, ".")
    var g = state
    for(var i = 0; i < array_length(split) - 1; i++)
    {
        g = g.get(split[i])
        if(g == undefined) return
    }
    g.set(split[array_length(split) - 1], value)
}

function lualib_f_gmlMethod(luaFunction, state)
{
    var obj = {
        func: function()
        {
            var arr = []
            for(var i = 0; i < argument_count; i++)
            {
                var arg = argument[i]
                array_push(arr, arg)
            }

            var c = undefined

            try
            {
                c = self.luaFunction.callExt(arr)
            }
            catch(error)
            {
                Log("Modloader/ERROR", $"An error occured while calling Lua function '{self.luaFunction}' (lua_State: {self.state.toString()})")
                ThrowError(error, true, true)
            }
            return c
        }
    }
    obj.luaFunction = luaFunction
    obj.state = state

    return obj.func
}

function lualib_addModLibrary(state, libStruct)
{
    state.set("lib", libStruct)
    state.addCode(/*lua*/@'events = {}
        function events.onStart()
            --
        end
    ')

    // no need for this after updating to Apollo v3 (probably)
        // nevermind lmao
    state.addCode(/*lua*/@'
        __idfields = __idfields or { };
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
    ')

    state.set("registry", {
        addItem: function(id, struct = {})
        {
            global.itemdefs[$ id] = itemdef(id, struct)
            var def = global.itemdefs[$ id]
            global.itemdefs_by_rarity[def.rarity][$ id] = def
            return def
        },
        addModifier: function(id, struct = {})
        {
            global.modifierdefs[$ id] = modifierdef(id, struct)
            var def = global.modifierdefs[$ id]
            return def
        },
        addBuff: function(id, struct = {})
        {
            global.buffdefs[$ id] = buffdef(id, struct)
            var def = global.buffdefs[$ id]
            return def
        }
    })
}
