// first 24 bits: unused
// next 8 bits:   ref type
// last 32 bits:  ref id
global.lualib_mask_ref = int64(0x700000FF00000000)

#macro LUA_MASK_REF global.lualib_mask_ref

function lualib_fixInstanceId(value)
{
    return handle_parse($"ref instance {int64(value)}")
}

function lualib_fixRefId(value, type = "instance")
{
    return handle_parse($"ref {type} {int64(value)}")
}

function lualib_fromLua(luaref)
{
    if(is_real(luaref) || !is_numeric(luaref)) return luaref

    return lualib_fixInstanceId(luaref)

    // var type = "instance"

    // Log("Main/INFOOOO", "invalid ref: " + string(int64(luaref)))

    // switch((int64(luaref) & int64(0x700000FF00000000)) >> int64(32))
    // {
    //     case 0x70000001: type = "ds_grid";        break;
    //     case 0x70000002: type = "ds_list";        break;
    //     case 0x70000003: type = "ds_map";         break;
    //     case 0x70000004: type = "ds_priority";    break;
    //     case 0x70000005: type = "ds_queue";       break;
    //     case 0x70000006: type = "ds_stack";       break;
    //     case 0x70000007: type = "instance";       break;
    //     case 0x70000008: type = "object";         break;
    //     case 0x70000009: type = "sprite";         break;
    //     case 0x7000000A: type = "sound";          break;
    //     case 0x7000000B: type = "room";           break;
    //     case 0x7000000C: type = "tiles";          break;
    //     case 0x7000000D: type = "path";           break;
    //     case 0x7000000E: type = "script";         break;
    //     case 0x7000000F: type = "font";           break;
    //     case 0x70000010: type = "timeline";       break;
    //     case 0x70000011: type = "shader";         break;
    //     case 0x70000012: type = "animationcurve"; break; // doubt this is what they are called in reality
    //     case 0x70000013: type = "sequence";       break;
    //     case 0x70000014: type = "particlesystem"; break; // same doubt here, but who knows since i never use these in beebo

    //     default: Log("Main/ERROR", "invalid ref: " + string(int64(luaref))); return int64(luaref); // value is not a valid handle, return int64 instead
    // }

    // return handle_parse($"ref {type} {int64(luaref) & int64(0x00000000FFFFFFFF)}")
}

function lualib_toLua(v)
{
    if(instance_exists(v))
    {
        return int64(v.id)
    }
    else if(is_handle(v))
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

function ref2int64(v)
{
    return int64(v)
    // var type = 0
    // var reftype
    // var _id = 0

    // try {
    //     reftype = string_split(string(v.id), " ")[1]
    //     _id = int64(v.id)
    // }
    // catch(error) { //ehehehehehehehhehehehehe
    //     reftype = string_split(string(v), " ")[1]
    //     _id = int64(v)
    // }

    // switch(reftype)
    // {
    //     case "ds_grid":        type = 0x80000001; break;
    //     case "ds_list":        type = 0x80000002; break;
    //     case "ds_map":         type = 0x80000003; break;
    //     case "ds_priority":    type = 0x80000004; break;
    //     case "ds_queue":       type = 0x80000005; break;
    //     case "ds_stack":       type = 0x80000006; break;
    //     case "instance":       type = 0x80000007; break;
    //     case "object":         type = 0x80000008; break;
    //     case "sprite":         type = 0x80000009; break;
    //     case "sound":          type = 0x8000000A; break;
    //     case "room":           type = 0x8000000B; break;
    //     case "tiles":          type = 0x8000000C; break;
    //     case "path":           type = 0x8000000D; break;
    //     case "script":         type = 0x8000000E; break;
    //     case "font":           type = 0x8000000F; break;
    //     case "timeline":       type = 0x80000010; break;
    //     case "shader":         type = 0x80000011; break;
    //     case "animationcurve": type = 0x80000012; break;
    //     case "sequence":       type = 0x80000013; break;
    //     case "particlesystem": type = 0x80000014; break;
    //     default: Log("Main/ERROR", "unrecognized type: " + reftype); return undefined;
    // }

    // // add type data to the byte just before the now int32 value
    // return int64(type) + _id
}

function lualib_f_gmlMethod(luaFunctionName, state)
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
                    a.attacker = int64(arg.attacker.id)
                    a.target = int64(arg.target.id)
                    array_push(arr, lua_byref(a))
                }
                else if(is_handle(arg))
                {
                    array_push(arr, int64(arg))
                }
                else
                {
                    array_push(arr, lua_byref(lualib_toLua(arg)))
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
    ')

    lua_add_function(state, "String", lualib_f_string)
}

function lualib_f_string(value)
{
    var val = value

    return string(val)
}

function int64_toString_evil(int)
{
    var str = ""
    for(var i = 0; i < 64; i++)
    {
        str = string((pow(int64(2), int64(i)) & int64(int)) >> int64(i)) + str
    }
    return "0b" + str
}
