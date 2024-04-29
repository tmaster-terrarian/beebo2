function lualib_fixInstanceId(value)
{
    return handle_parse($"ref instance {int64(value)}")
}

function lualib_fromLua(luaref, type = "instance")
{
    handle_parse($"ref {type} {int64(luaref)}")
}

function lualib_toLua(v)
{
    if(is_handle(v))
    {
        return int64(v)
    }
    else if(is_struct(v))
    {
        var keys = variable_struct_get_names(v)
        for(var i = 0; i < array_length(keys); i++)
        {
            v[$ keys[i]] = lualib_toLua(v[$ keys[i]])
        }
        return v
    }
    else if(is_array(v))
    {
        for(var i = 0; i < array_length(v); i++)
        {
            v[i] = lualib_toLua(v[i])
        }
        return v
    }
    else
    {
        return v
    }
}

function lualib_gmlMethod(luaFunctionName, state)
{
    var obj = {
        func: function()
        {
            var arr = []
            for(var i = 0; i < argument_count; i++)
            {
                var arg = argument[i]
                if(is_instanceof(arg, DamageEventContext))
                {
                    var a = struct_assign({}, arg)
                    a.attacker = int64(arg.attacker)
                    a.target = int64(arg.target)
                    array_push(arr, lua_byref(a))
                }
                else if(is_handle(arg))
                {
                    array_push(arr, int64(arg))
                }
                else
                {
                    array_push(arr, lua_byref(arg))
                }
            }

            var c = undefined

            try
            {
                c = lua_call_w(self.state, self.luaFunctionName, arr)
            }
            catch(error)
            {
                Log("Modloader/ERROR", $"An error occured while calling Lua function '{string(self.luaFunctionName)}' (luaStateID: {string(self.state)})")
                ThrowError(error, true, true)
            }
            return c
        }
    }
    obj.luaFunctionName = luaFunctionName
    obj.state = state

    return obj.func
}

function lualib_addModLibrary(state, libStruct)
{
    lua_global_set(state, "lib", libStruct)

    lua_add_code(state, /*lua*/@'
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

        -- ref = {
        --     __r2i = { },
        --     __i2r = { },
        --     __next = 0
        -- }
        -- function ref.toid(fn)
        --     local id = ref.__r2i[fn]
        --     if (id == nil) then
        --         id = ref.__next
        --         ref.__next = id + 1
        --         ref.__r2i[fn] = id
        --         ref.__i2r[id] = fn
        --     end
        --     return id
        -- end
        -- function ref.fromid(id)
        --     return ref.__i2r[id]
        -- end
        -- function ref.free(fn)
        --     local id
        --     if (type(fn) == "number") then
        --         id = fn
        --         fn = ref.__i2r[id]
        --     else
        --         id = ref.__r2i[fn]
        --     end
        --     ref.__r2i[fn] = nil
        --     ref.__i2r[id] = nil
        -- end
    ')

    lua_add_function(state, "String", lualib_string)
}

function lualib_string(value)
{
    return string(value)
}
