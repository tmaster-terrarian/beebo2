function lualib_fixInstanceId(value)
{
    return handle_parse($"ref instance {int64(value)}")
}

function lualib_fixRefId(value, type = "instance")
{
    return handle_parse($"ref {type} {int64(value)}")
}

function luaRef_keys(luaRef)
{
    var state = new LuaState()
    state.set("o", luaRef)
    state.addCode("s={}n=0 for k,v in pairs(o)do n=n+1 s[n]=k end") // golfged
    var l = state.get("n")
    var arr = array_create(l)
    for(var i=0;i<l;i++){arr[i]=state.addCode($"return s[{i+1}]")} // golfged 2
    return arr
}

function luaRef_values(luaRef)
{
    var state = new LuaState()
    state.set("o", luaRef)
    state.addCode("s={}n=0 for k,v in pairs(o)do n=n+1 s[n]=v end") // s[n] = v instead of k
    var l = state.get("n")
    var arr = array_create(l)
    for(var i=0;i<l;i++){arr[i]=state.addCode($"return s[{i+1}]")}
    return arr
}

function luaTable_toArray(luaRef)
{
    var state = new LuaState()
    state.set("o", luaRef)
    var l = state.addCode("return #o")
    var arr = array_create(l)
    for(var i=0;i<l;i++){arr[i]=state.addCode($"return o[{i+1}]")}
    return arr
}

function lualib_f_gmlMethod(luaFunction, state)
{
    var obj = {
        func: function()
        {
            var c = undefined

            try
            {
                c = self.luaFunction.callExt(argument)
            }
            catch(error)
            {
                Log("Modloader/ERROR", $"An error occured while calling Lua function '{self.luaFunction.toString()}' (lua_State: {self.state.toString()})")
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
