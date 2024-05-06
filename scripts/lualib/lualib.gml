function lualib_fixInstanceId(value)
{
    return handle_parse($"ref instance {int64(value.get("id"))}")
}

function lualib_fixRefId(value, type = "instance")
{
    return handle_parse($"ref {type} {int64(value)}")
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

    var l = state.get("n")
    var arr = array_create(l)
    for(var i=0;i<l;i++){arr[i]=state.get("s").get(i+1)} // golfged
    return arr
}

function luaRef_values(luaRef)
{
    var state = luaRef.__state__
    state.set("o", luaRef)
    state.addCode("s={}n=0 for k,v in pairs(o)do n=n+1 s[n]=v end") // s[n] = v instead of k
    var l = state.get("n")
    var arr = array_create(l)
    for(var i=0;i<l;i++){arr[i]=state.get("s").get(i+1)}
    return arr
}

function lualib_toArray(luaRef)
{
    var state = luaRef.__state__
    state.set("o", luaRef)
    var l = state.addCode("return #o")
    var arr = array_create(l)
    for(var i=0;i<l;i++){arr[i]=state.addCode($"return o[{i+1}]")}
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
                c = lualib_get(self.state, self.luaFunction).callExt(arr)
            }
            catch(error)
            {
                Log("Modloader/ERROR", $"An error occured while converting Lua function '{self.luaFunction}' (lua_State: {self.state.toString()})")
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
    state.set("event_onStart", state.addCode("return function() end"))

    // no need for this after updating to Apollo v3 (probably)
    // state.addCode(/*lua*/@'
    //     __idfields = __idfields or { };
    //     debug.setmetatable(0, {
    //         __index = function(self, name)
    //             if (__idfields[name]) then
    //                 return _G[name];
    //             else
    //                 return lib.instance.get(self, name);
    //             end
    //         end,
    //         __newindex = lib.instance.set,
    //     })
    // ')

    state.set("coop", {
        
    })
}
