function itemdef(_name, _struct = {})
{
	static total_items = 0
	total_items++

	var __newstruct = new _itemdef(_name)

	if(is_lua_ref(_struct))
	{
		__newstruct = luaRef_assignToStruct(__newstruct, _struct)
	}
	else
	{
		__newstruct = struct_assign(__newstruct, _struct)
	}

	if(_name != "unknown")
	Log("ModLoader/INFO", $"Registered Item '{_name}'")

	return __newstruct
}

function modifierdef(_name, _struct = {})
{
	static total_modifiers = 0
	total_modifiers++

	var __newstruct = new _modifierdef(_name)

	if(is_lua_ref(_struct))
	{
		__newstruct = luaRef_assignToStruct(__newstruct, _struct)
	}
	else
	{
		__newstruct = struct_assign(__newstruct, _struct)
	}

	if(_name != "unknown")
	Log("ModLoader/INFO", $"Registered Modifier '{_name}'")

	return __newstruct
}

function buffdef(_name, _struct = {})
{
	static total_buffs = 0
	total_buffs++

	var __newstruct = new _buffdef(_name)

	if(is_lua_ref(_struct))
	{
		__newstruct = luaRef_assignToStruct(__newstruct, _struct)

		if(_struct.get("onExpire") != undefined)
		{
			__newstruct.__on_expire = _struct.get("onExpire")
			__newstruct.onExpire = method(__newstruct, function(instance) {
				self.__on_expire.call(instance)
				buff_instance_remove(instance)
			})
		}
	}
	else
	{
		__newstruct = struct_assign(__newstruct, _struct)
	}

	if(_name != "unknown")
	Log("ModLoader/INFO", $"Registered Buff '{_name}'")

	return __newstruct
}
