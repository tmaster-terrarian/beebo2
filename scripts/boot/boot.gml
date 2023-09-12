var _boot_starttime = get_timer()
file_delete("latest.log")

// pixelate gui
display_set_gui_size(320, 180)

// game is too fucking LOUD
audio_master_gain(0.5);

// read and apply screenSize and draw_debug flags
debug_log("startup", "getting settings")

ini_open("save.ini");
global.sc = clamp(floor(ini_read_real("settings", "res", 4)), 2, 6);
if(global.sc < 6)
{
    window_set_fullscreen(false);
    window_set_size((320 * global.sc), (180 * global.sc));
}
else
{
    window_set_fullscreen(true);
}
window_center()

global.draw_debug = ini_read_real("debug", "draw_debug", 0)
global.locale = ini_read_string("settings", "lang", "en")

global.snd_volume = ini_read_real("settings", "sound_volume", 0.5)
global.bgm_volume = ini_read_real("settings", "music_volume", 0.8)
ini_close()

// enums
enum Team
{
    player,
	enemy,
	neutral
}

enum proctype
{
	onhit,
	onkill,
	none
}

enum item_rarity
{
	none,
	common,
	rare,
	legendary,
	special
}

enum damage_notif_type
{
	generic,
	crit,
	heal,
	revive,
	playerhurt
}

enum healtype
{
	generic,
	regen
}

enum deftype
{
	item,
	modifier,
	upgrade
}

// classes
function damage_event(attacker, target, proc_type, damage, proc, attacker_has_items = 1, force_crit = -1, reduceable = 1)
{
	var _damage_type = damage_notif_type.generic
	var crit = 0

	if(instance_exists(target) && !target.invincible)
	{
		var _dir = 1

		if(instance_exists(attacker))
		{
			_dir = sign(target.x - attacker.x)

			if(random(1) < attacker.crit_chance) || force_crit
			{
				crit = 1
				_damage_type = damage_notif_type.crit
			}
			if(force_crit == 0)
			{
				crit = 0
				_damage_type = damage_notif_type.generic
			}

			if(attacker_has_items)
			{
				for(var i = 0; i < array_length(attacker.items); i++)
				{
					if(variable_struct_exists(global.itemdefs, attacker.items[i].item_id))
					{
						var _item = global.itemdefs[$ attacker.items[i].item_id]
						var _stacks = attacker.items[i].stacks
						if(_item.proc_type == proc_type)
						{
							_item.proc(attacker, target, damage, proc, _stacks)
						}
					}
				}

				var dmg_fac = 1
				dmg_fac += ((target.facing == 1 && target.x >= attacker.x) || (target.facing == -1 && target.x < attacker.x)) * (0.2 * item_get_stacks("bloody_dagger", attacker))

				damage *= dmg_fac
			}

			if(attacker.team == Team.player)
			{
				if(!crit)
					audio_play_sound(sn_hit, 5, false)
				else
					audio_play_sound(sn_hit_crit, 5, false)
			}
		}
		else 
		{
			if(force_crit > -1)
			{
				crit = force_crit
				if(force_crit)
					_damage_type = damage_notif_type.crit
			}
		}

		damage *= (1 + crit)

		var dmg = damage
		if(reduceable)
		{
			for(var i = 0; i < array_length(target.items); i++)
			{
				dmg = global.itemdefs[$ target.items[i].item_id].on_owner_damaged(target, dmg, target.items[i].stacks)
			}
		}
		target.hp -= dmg

		if(target.object_index == obj_player || target.object_index == obj_player_rival)
		{
			audio_play_sound(sn_player_hit, 5, false)
			_damage_type = damage_notif_type.playerhurt
		}

		instance_create_depth((target.bbox_left + target.bbox_right) / 2, (target.bbox_top + target.bbox_bottom) / 2, 10, fx_damage_number, {notif_type: _damage_type, value: ceil(dmg), dir: _dir})

		// activate on kill items if target died
		if(target.hp <= 0) && (target.object_index != obj_player) && (target.object_index != obj_player_rival)
		{
			if(instance_exists(attacker)) && (attacker_has_items)
			{
				for(var i = 0; i < array_length(attacker.items); i++)
				{
					if(variable_struct_exists(global.itemdefs, attacker.items[i].item_id))
					{
						var _item = global.itemdefs[$ attacker.items[i].item_id]
						var _stacks = attacker.items[i].stacks
						if(_item.proc_type == proctype.onkill)
						{
							_item.proc(attacker, target, damage, proc, _stacks)
						}
					}
				}

				if(attacker.object_index == obj_player || attacker.object_index == obj_player_rival)
				{
					attacker.xp += target.xpReward
				}
			}
			for(var i = 0; i < array_length(target.items); i++)
			{
				if(variable_struct_exists(global.itemdefs, target.items[i].item_id))
				{
					var _item = global.itemdefs[$ target.items[i].item_id]
					if(_item.name == "emergency_field_kit")
					{
						target.hp = target.hp_max
						item_add_stacks("emergency_field_kit", target, -1, 0)
						item_add_stacks("emergency_field_kit_consumed", target, 1, 0)
					}
				}
			}
		}
		else
		{
			target.flash = 3
		}
	}
}

function heal_event(target, value, _healtype = healtype.generic)
{
	var heal_fac = 1
	target.hp += value * heal_fac

	if(_healtype != healtype.regen)
		instance_create_depth((target.bbox_left + target.bbox_right) / 2, (target.bbox_top + target.bbox_bottom) / 2, 10, fx_damage_number, {notif_type: damage_notif_type.heal, value: value, dir: -target.facing})
}

// global variables
function itemdata()
{
	static item_tables =
	{
		any : [{v: 4, w: 1}, {v: 3, w: 1}, {v: 2, w: 1}, {v: 1, w: 1}, {v: 0, w: 1}],
		any_obtainable : [{v: 3, w: 1}, {v: 2, w: 1}, {v: 1, w: 1}],
		chest_small : [{v: 3, w: 0.01}, {v: 2, w: 1.98}, {v: 1, w: 7.92}],
		chest_large : [{v: 3, w: 2}, {v: 2, w: 8}]
	}
	static rarity_colors =
	[
		#798686,
		#E8F6F4,
		#38EB73,
		#F3235E,
		#D508E5
	]
	static damage_type_colors =
	[
		#E8F6F4,
		#F3235E,
		#9CE562,
		#D508E5,
		#7b003b
	]
}
itemdata()

global.timescale = 1
global.dt = 1
global.t = 0 // run timer
global.gameTimer = 0 // time elapsed since the gm object was created

global.pause = 0

// global.retro = 0 // experimental color limit shader

global.snd_volume = 1
global.bgm_volume = 1
global.controller = false
global.cutscene = false
global.introsequence = false
global.gamestarted = false
global.pausetimer = false
global.gunlesspercent = false
global.players = [obj_player, obj_player]
global.playerCount = 1
global.enemyCount = 0
global.fx_bias = 0
global.usesplitscreen = 0

global.fnt_hudnumbers = font_add_sprite_ext(spr_hudnumbers, "/1234567890-KM", 0, -1)
global.fnt_hudstacks = font_add_sprite_ext(spr_hudstacksfnt, "1234567890KM", 1, -1)

#macro SC_W 320
#macro SC_H 180

#macro PAUSECHECK if(global.pause) return;

#macro MINUTE 3600

// functions
// the following eight functions are credited to D'Andrëw Box on Github and are licensed under the MIT license.
function array_fill(_array, _val)
{
	for (var i = 0; i < array_length(_array); i++)
	{
		_array[i] = _val;
	}
}

function array_clear(_array)
{
	array_delete(_array, 0, array_length(_array));
}

function array_empty(_array)
{
	return (array_length(_array) == 0);
}

function array_find_index_by_value(_array, _val)
{
	for (var i = 0; i < array_length(_array); i++)
	{
		if (_array[i] == _val)
		{
			return i;
		}
	}
	return -1;
}

function file_text_read_whole(_file) {
	if (_file < 0) return "";

	var _file_str = ""
	while (!file_text_eof(_file)) {
	    _file_str += file_text_readln(_file);
	}

	return _file_str;
}

function file_json_read(_file) {
	var _str = file_text_read_whole(_file);
	return json_parse(_str);
}

function file_text_get_lines_array(_file) {
	if (_file < 0) return [];

	var _file_arr = [];
	var _str = "";
	while (!file_text_eof(_file)) {
		_str = file_text_readln(_file);
	    array_push(_file_arr, _str);
	}

	return _file_arr;
}

// do not pass in a value for _iteration when using this function !
function json2file(_filename, _json = {}, _iteration = 0) {
	if (!is_struct(_json)) return "";

	var _str	= "{";
	var _keys	= struct_get_names(_json);
	array_sort(_keys, true);
	for (var i = 0; i < array_length(_keys); i++) {
		var _value = _json[$ _keys[i]];
		if (is_struct(_value)) {
			_value = json2file("", _value, _iteration + 1);
		} else if (is_string(_value)) {
			_value = string("\"{0}\"", _value);
			_value = string_replace_all(_value, "\n", "\\n");
		}
		_str += "\n\t";
		for (var j = 0; j < _iteration; j++) {
			_str += "\t";
		}
		_str += string(
			"\"{0}\": {1}",
			_keys[i],
			_value
		);
		_str += ( i != array_length(_keys) - 1 ? "," : "" );
	}
	_str += "\n";
	for (var j = 0; j < _iteration; j++) {
		_str += "\t";
	}
	_str += "}";

	if (_filename != "") {
		var _file = file_text_open_write(_filename);
		file_text_write_string(_file, _str);
		file_text_close(_file);
	}

	return _str;
}
// end of 3rd party functions

function screen_shake_set(_strength, _frames)
{
	with(obj_camera)
	{
		if (_strength > shake)
		{
			shake_strength = _strength
			shake = _strength
			shake_length = _frames
		}
	}
}
function screen_shake_add(_strength, _frames)
{
	with(obj_camera)
	{
		shake_strength = _strength
		shake += _strength
		shake_length = _frames
	}
}

function item_id_get_random(_by_rarity, _table = itemdata.item_tables.any_obtainable)
{
	if(_by_rarity)
	{
		var _array = struct_get_names(global.itemdefs_by_rarity[random_weighted(_table)])
		return _array[irandom(array_length(_array) - 1)]
	}
	else
	{
		var _array = struct_get_names(global.itemdefs)
		return _array[irandom(array_length(_array) - 1)]
	}
}

function struct_get_random(_struct)
{
	var _array = struct_get_names(_struct)
	return _array[irandom(array_length(_array) - 1)]
}

function getdef(_defid, _deftype = 0)
{
	switch(_deftype)
	{
		case deftype.item: default:
		{
			return global.itemdefs[$ _defid]
			break;
		}
		case deftype.modifier:
		{
			return global.modiferdefs[$ _defid]
			break;
		}
		case deftype.upgrade:
		{
			return global.upgradedefs[$ _defid]
			break;
		}
	}
}

function getraritycol(_invitem)
{
	return itemdata.rarity_colors[global.itemdefs[$ _invitem.item_id].rarity]
}

function random_weighted(_list) // example values: [{v:3,w:1}, {v:4,w:3}, {v:2,w:5}]; v:value, w:weight. automatically sorted by lowest weight.
{
	var _tw = 0
	var _w = 0
	var _v = 0

	var _l = []; array_copy(_l, 0, _list, 0, array_length(_list))
	array_sort(_l, function(_e1, _e2) { return sign(_e1.w - _e2.w) })

	for(var i = 0; i < array_length(_l); i++)
	{
		_tw += _l[i].w
	}

	var _rand = random(_tw)
	for(var j = 0; j < array_length(_l); j++)
	{
		if(_rand <= _l[j].w + _w)
			return _l[j].v
		else
			_w += _l[j].w
	}
	return array_last(_l).v
}

function timer_to_timestamp(_t)
{
	var _c = floor((abs(_t) / 10000) % 100)
	var _s = floor((abs(_t) / 1000000) % 60)
	var _m = floor(_s / 60) % 60
	var _h = floor(_m / 60) % 60
	var h = string(_h) + ":"

	if(_c < 10) _c = "0" + string(_c)
	if(_s < 10) _s = "0" + string(_s)
	if(_m < 10) _m = "0" + string(_m)
	if(_h < 10) h = "0" + string(_h) + ":"

	var str = ((_t < 0) ? "-" : "") + ((_h) ? h : "") + $"{_m}:{_s}:{_c}"

	return str
}

function debug_log(src, str)
{
	show_debug_message($"[{timer_to_timestamp(get_timer())}] [{src}]: {str}")

	var file = file_text_open_append("latest.log")
	file_text_write_string(file, $"[{timer_to_timestamp(get_timer())}] [{src}]: {str}")
	file_text_writeln(file)
	file_text_close(file)
}

function get_nearest_notme(_x, _y, inst)
{
	var __x = _x
	var __y = _y
	x -= 1000000
	y -= 1000000
	var _inst = instance_nearest(__x, __y, inst)
	x += 1000000
	y += 1000000
	return (_inst != id) ? _inst : noone
}

function string_real_shortened(val)
{
	var _val
	if(val < 1000)
		return (string(val))
	else if(val < 1000000)
		return (string(round(val / 1000)) + "K")
	else
		return (string(round(val / 1000000)) + "M")
}
function string_real_shortened_ceil(val)
{
	var _val
	if(val < 1000)
		return (string(val))
	else if(val < 1000000)
		return (string(ceil(val / 1000)) + "K")
	else
		return (string(ceil(val / 1000000)) + "M")
}

function string_to_real(str)
{
    var _str = string_split(str, ".")
    var _dec = (array_length(_str) > 1) ? real(string_digits(_str[1])) * 1/(power(10, string_length(_str[1]))) : 0
	return (string_starts_with(str, "-") ? -1 : 1) * (real(string_digits(_str[0])) + _dec)
}

function string_is_real(str)
{
	return !((string_digits(str) == "") || (string_replace(string_replace(str, ".", ""), "-", "") != string_digits(str)))
}

// localization
function string_loc(key) // example key: item.beeswax.name
{
	return (variable_struct_exists(global.lang, global.locale) && variable_struct_exists(global.lang[$ global.locale], string_replace_all(key, ".", "_"))) ? global.lang[$ global.locale][$ string_replace_all(key, ".", "_")] : (variable_struct_exists(global.lang.en, string_replace_all(key, ".", "_")) ? global.lang.en[$ string_replace_all(key, ".", "_")] : key)
}

function locale()
{
	static init = function()
	{
		delete global.lang

		global.lang = { en: {}, es: {} }

		var file = file_text_open_read("data/lang.json")
		global.lang = file_json_read(file)
		file_text_close(file)
	}
	static reload = function()
	{
		var _starttime = get_timer()
		debug_log("system", "reloading language data")

		locale.init()
		debug_log("system", $"loaded languages: {struct_get_names(global.lang)}")

		struct_foreach(global.itemdefs as (_name, _item)
		{
			_item.displayname = string_loc($"item.{_name}.name")
			_item.shortdesc = string_loc($"item.{_name}.shortdesc")
			_item.lore = string_loc($"item.{_name}.lore")
		})
		debug_log("system", "reloaded item language data")

		struct_foreach(global.modifierdefs as (_name, _item)
		{
			_item.displayname = string_loc($"modifier.{_name}.name")
			_item.desc = string_loc($"modifier.{_name}.desc")
		})
		debug_log("system", "reloaded modifier language data")

		struct_foreach(global.upgradedefs as (_name, _item)
		{
			_item.displayname = string_loc($"upgrade.{_name}.name")
			_item.desc = string_loc($"upgrade.{_name}.desc")
			_item.lore = string_loc($"upgrade.{_name}.lore")
		})
		debug_log("system", "reloaded gun module language data")

		debug_log("system", $"language data reload completed, elapsed time: [{timer_to_timestamp(get_timer() - _starttime)}]")
	}
}
locale()

global.lang = { en: {}, es: {} }

locale.init()
debug_log("startup", $"loaded languages: {struct_get_names(global.lang)}")

// itemdefs.gml
function _itemdef(_name) constructor {
    name = _name
    displayname = string_loc($"item.{name}.name")
    shortdesc = string_loc($"item.{name}.shortdesc")
    lore = string_loc($"item.{name}.lore")
	proc_type = proctype.none
    rarity = item_rarity.none

    calc = function(_s) { return 0 }
    draw = function(_s = 1) {}
    step = function(target, _s) {}
    proc = function(_a, _t, _d, _p, _s) {}
	on_owner_damaged = function(_o, _d, _s) { return _d }
}

function itemdef(__struct, _struct)
{
	static total_items = 0
	total_items++

	// hhhhhh i hate scope issues so much
	var names = variable_struct_get_names(_struct)
    var size = variable_struct_names_count(_struct);

    for (var i = 0; i < size; i++) {
        var name = names[i];
        var element = variable_struct_get(_struct, name);
        variable_struct_set(__struct, name, element)
    }
	delete _struct
	return __struct
}

global.itemdefs =
{
	unknown : new _itemdef("unknown"),
	beeswax : itemdef(new _itemdef("beeswax"), {
		rarity : item_rarity.common,
		calc : function(_s)
		{
			return 0.1 * _s
		}
	}),
	eviction_notice : itemdef(new _itemdef("eviction_notice"), {
		proc_type : proctype.onhit,
		rarity : item_rarity.rare,
		proc : function(_a, _t, _d, _p, _s) //attacker, target, damage, proc coefficient, item stacks
		{
			if(_a.hp/_a.hp_max >= 0.9) && sign(_p)
			{
				var offx = 0
				var offy = 0
				if(_a == obj_player)
				{
					offy = -12
				}

				var p = instance_create_depth(_a.x + offx, _a.y + offy, _a.depth + 2, obj_paperwork)
				p.damage = _a.base_damage * (4 + _s) * _p
				p.team = _a.team
				p.dir = point_direction(_a.x + offx, _a.y + offy, _t.x, _t.y)
				p.pmax = point_distance(_a.x + offx, _a.y + offy, _t.x, _t.y)
				p.target = _t
				p.parent = _a
			}
		}
	}),
	serrated_stinger : itemdef(new _itemdef("serrated_stinger"), {
		proc_type : proctype.onhit,
		rarity : item_rarity.common,
		proc : function(_a, _t, _d, _p = 1, _s = 1)
		{
			if(random(1) <= (0.1 * _s * _p))
				_inflict(_t, new statmanager._bleed(_a, _p, _a.base_damage))
		}
	}),
	amorphous_plush : itemdef(new _itemdef("amorphous_plush"), {
		rarity : item_rarity.rare,
		step : function(target, _s)
		{
			if(instance_exists(target) && (target.t % 600) == 30) && (target.object_index != obj_catfriend) && (instance_number(obj_catfriend) < 1)
			{
				var o = instance_create_depth(target.x + random_range(-8, 8), target.y, 0, obj_catfriend, { team : target.team, parent : target})
				o.stats.hp_max += (0.1 * o.stats.hp_max * (_s - 1))
				o.stats.spd += (0.1 * o.stats.spd * (_s - 1))
				o.stats.damage += (0.2 * o.stats.damage * (_s - 1))
			}
		}
	}),
	emergency_field_kit : itemdef(new _itemdef("emergency_field_kit"), {
		rarity : item_rarity.legendary
	}),
	emergency_field_kit_consumed : itemdef(new _itemdef("emergency_field_kit_consumed"), {
		rarity : item_rarity.none
	}),
	bloody_dagger : itemdef(new _itemdef("bloody_dagger"), {
		rarity : item_rarity.common
	}),
	lucky_clover : itemdef(new _itemdef("lucky_clover"), {
		rarity : item_rarity.common
	})
}

global.itemdefs_by_rarity = [{}, {}, {}, {}, {}]
struct_foreach(global.itemdefs as (_name, _item)
{
    global.itemdefs_by_rarity[_item.rarity][$ _name] = _item
})

debug_log("startup", $"successfully created {itemdef.total_items} items")

function inventory_item(__id, _stacks = 1) constructor
{
    item_id = __id
    stacks = _stacks
}

function item_get_stacks(item_id, target)
{
    for(var i = 0; i < array_length(target.items); i++)
    {
        if(target.items[i].item_id == item_id)
        {
            return target.items[i].stacks
        }
    }
    return 0
}

function item_add_stacks(item_id, target, stacks = 1, notify = 1)
{
	if(notify && stacks >= 1 && target.object_index == obj_player)
	{
		array_push(oCamera.item_pickup_queue, item_id)
	}

    for(var i = 0; i < array_length(target.items); i++)
    {
        if(target.items[i].item_id == item_id)
        {
            target.items[i].stacks += stacks
			if(target.items[i].stacks <= 0)
				array_delete(target.items, i, 1)
			return
        }
    }
	if(stacks > 0)
	{
		array_push(target.items, new inventory_item(item_id, stacks))
	}
}

function item_set_stacks(item_id, target, stacks, notify = 1)
{
	if(notify && stacks >= 1 && target.object_index == obj_player)
	{
		array_push(oCamera.item_pickup_queue, item_id)
	}

    for(var i = 0; i < array_length(target.items); i++)
    {
        if(target.items[i].item_id == item_id)
        {
            target.items[i].stacks = stacks
			if(target.items[i].stacks <= 0)
				array_delete(target.items, i, 1)
			return;
        }
    }
	if(stacks > 0)
	{
		array_push(target.items, new inventory_item(item_id, stacks))
	}
}

// modifiers
function _modifierdef(_name) constructor
{
	name = _name
	displayname = string_loc($"modifier.{name}.name")
	desc = string_loc($"modifier.{name}.desc")

	on_pickup = function() {}
}

function modifierdef(__blankdef, _struct)
{
	static total_modifiers = 0
	total_modifiers++

	var names = variable_struct_get_names(_struct)
    var size = variable_struct_names_count(_struct);

    for (var i = 0; i < size; i++) {
        var name = names[i];
        var element = variable_struct_get(_struct, name);
        variable_struct_set(__blankdef, name, element)
    }
	delete _struct
	return __blankdef
}

global.modifierdefs =
{
	unknown : new _modifierdef("unknown"),
	reckless : modifierdef(new _modifierdef("reckless"), {
	}),
	evolution : modifierdef(new _modifierdef("evolution"), {
		on_pickup : function()
		{
			var _item = item_id_get_random(1, itemdata.item_tables.chest_small)
			if(instance_exists(obj_player))
				item_add_stacks(_item, obj_player, 3)
			item_add_stacks(_item, statmanager, 3, 0)
		}
	})
}

debug_log("startup", $"successfully created {modifierdef.total_modifiers} modifiers")

function modifier(_modifier_id, _stacks = 1) constructor
{
	modifier_id = _modifier_id
	stacks = _stacks
}

function modifier_get_stacks(modifier_id)
{
    for(var i = 0; i < array_length(global.rundata.modifiers); i++)
    {
        if(global.rundata.modifiers[i].modifier_id == modifier_id)
        {
            return global.rundata.modifiers[i].stacks
        }
    }
    return 0
}

function modifier_add_stacks(modifier_id, stacks = 1)
{
    for(var i = 0; i < array_length(global.rundata.modifiers); i++)
    {
        if(global.rundata.modifiers[i].modifier_id == modifier_id)
        {
            global.rundata.modifiers[i].stacks += stacks
			if(global.rundata.modifiers[i].stacks <= 0)
				array_delete(global.rundata.modifiers, i, 1)
			return;
        }
    }
	if(stacks > 0)
	{
		array_push(global.rundata.modifiers, new modifier(modifier_id, stacks))
	}
}

function modifier_set_stacks(modifier_id, stacks)
{
    for(var i = 0; i < array_length(global.rundata.modifiers); i++)
    {
        if(global.rundata.modifiers[i].modifier_id == modifier_id)
        {
            global.rundata.modifiers[i].stacks = stacks
			if(global.rundata.modifiers[i].stacks <= 0)
				array_delete(global.rundata.modifiers, i, 1)
			return;
        }
    }
	if(stacks > 0)
	{
		array_push(global.rundata.modifiers, new modifier(modifier_id, stacks))
	}
}

// gun modules
function _upgradedef(_name) constructor {
    name = _name
    displayname = string_loc($"upgrade.{name}.name")
    desc = string_loc($"upgrade.{name}.desc")
    lore = string_loc($"upgrade.{name}.lore")
    rarity = item_rarity.none
	firerate = 5
	bombrate = 80
	bulletprojectile = obj_bullet
	bombprojectile = obj_bomb

    step = function(target) {}
    on_pickup = function(target) {}
    fire = function(target)
	{
		with(target)
		{
			var v = spread
			var _obj = instance_create_depth(x + lengthdir_x(14, fire_angle) + gun_pos.x * sign(facing), y + lengthdir_y(14, fire_angle) + gun_pos.y - 1, depth - 3, other.bulletprojectile)

			with (_obj)
			{
				parent = other
				team = other.team
				audio_play_sound(sn_player_shoot, 1, false);

				_speed = 12;
				direction = other.fire_angle + random_range(-v, v);
				image_angle = direction;

				damage = other.damage * 0.8333
			}
			with(instance_create_depth(x + lengthdir_x(4, fire_angle) + gun_pos.x * sign(facing), y + lengthdir_y(4, fire_angle) - 1 + gun_pos.y, depth - 5, fx_casing))
			{
				image_yscale = other.facing
				angle = other.fire_angle
				dir = other.facing
				hsp = -other.facing * random_range(1, 1.5)
				vsp = -1 + random_range(-0.2, 0.1)
			}

			return _obj;
		}
	}
    fire_bomb = function(target)
	{
		with(target)
		{
			var _obj = instance_create_depth(x + lengthdir_x(12, fire_angle) + gun_pos.x * sign(facing), y + lengthdir_y(12, fire_angle) + gun_pos.y - 1, depth - 2, other.bombprojectile)

			with(_obj)
			{
				parent = other
				team = other.team
				damage = other.damage * 4

				hsp = lengthdir_x(2, other.fire_angle) + (other.hsp * 0.5)
				vsp = lengthdir_y(2, other.fire_angle) + (other.vsp * 0.25) - 1
			}

			return _obj;
		}
	}
}

function upgradedef(__struct, _struct)
{
	static total_upgrades = 0
	total_upgrades++

	// hhhhhh i hate scope issues so much
	var names = variable_struct_get_names(_struct)
    var size = variable_struct_names_count(_struct);

    for (var i = 0; i < size; i++) {
        var name = names[i];
        var element = variable_struct_get(_struct, name);
        variable_struct_set(__struct, name, element)
    }
	delete _struct
	return __struct
}

global.upgradedefs =
{
	base : new _upgradedef("base"),
	bomberman : upgradedef(new _upgradedef("bomberman"), {
		rarity : item_rarity.common,
		bulletprojectile : obj_bullet
	})
}

// run data storage method
function _rundata() constructor
{
	start_time = $"{current_month}-{current_day}-{current_year} {current_hour}-{current_minute}-{current_second}"
	wave = -1
	money = 0
	run_time = 0
	total_dmg = 0
	modifiers = []
	items = []
	gun_upgrade = ""

	save = function()
	{
		if(!directory_exists("past_runs"))
			directory_create("past_runs")

		var file = file_text_open_write(working_directory + $"past_runs/{start_time}.json")
		file_text_write_string(file, json2file("", self))
		file_text_close(file)
	}

	ResetStartTime = function()
	{
		start_time = $"{current_month}-{current_day}-{current_year} {current_hour}-{current_minute}-{current_second}"
	}
}
global.rundata = new _rundata()

// SPAWNING AND DIFFICULTY
function spawn_card(index, weight, cost, spawnsOnGround = 1) constructor
{
	self.index = index
	self.weight = weight
	self.cost = cost
	self.spawnsOnGround = spawnsOnGround
}

global.spawn_cards =
[
	[ // normal
		new spawn_card("obj_e_bombguy", 1, 30)
	],
	[ // strong
		new spawn_card("obj_test", 1, 40)
	],
	[ // boss
		new spawn_card("obj_test", 1, 600)
	]
]

for(var i = 0; i < 3; i++)
{
	array_sort(global.spawn_cards[i], function(_e1, _e2) { return sign(_e1.cost - _e2.cost) })
}

// global.spawn_cards[random_weighted([{v: 2, w: 1}, {v: 1, w: 2}, {v: 0, w: 4}])]

global.difficultySetting = 2 // regular difficulty is 2
global.difficultyCoeff = 1
global.wave = 0
global.enemyLevel = 1
global.enemyItems = []

function Director(creditsStart, expMult, creditMult, waveInterval, interval, maxSpawns) constructor
{
	self.creditsStart = creditsStart
	self.expMult = expMult
	self.creditMult = creditMult
	self.waveInterval = waveInterval
	self.interval = interval
	self.maxSpawns = maxSpawns
	self.enabled = 0

	self.credits = 0
	self.creditsPerSecond = 0

	self.waveType = 0
	self.waveImmediateCreditsFraction = [0.15, 0.3]
	self.wavePeriods = [30, 60]
	self.waveBaseCredits = [159, 500]

	self.generatorTicker = 0
	self.generatorTickerSeconds = 0

	self.spawnTimer = 0
	self.spawnCounter = 0
	self.lastSpawnSucceeded = 0
	self.lastSpawnCard = noone
	self.lastSpawnPos = {x: SC_W / 2, y: SC_H / 2}

	self.Enable = function()
	{
		self.enabled = 1
		self.generatorTicker = 0
		self.generatorTickerSeconds = 0
		self.spawnTimer = 0
		self.spawnCounter = 0
		self.lastSpawnSucceeded = 0
		self.lastSpawnCard = noone

		var totalWaveCreds = self.waveBaseCredits[self.waveType] * global.difficultyCoeff

		self.credits = self.creditsStart + self.waveImmediateCreditsFraction[self.waveType] * totalWaveCreds
		self.creditsPerSecond = 	 (1 - self.waveImmediateCreditsFraction[self.waveType]) * totalWaveCreds/self.wavePeriods[self.waveType]

		if(self.waveType == 1) // boss wave
		{
			var choice, r
			for(var c = 0; c < 100; c++) // doing this instead of a while loop in the case where nothing can spawn
			{
				r = irandom(array_length(global.spawn_cards[2]) - 1)
				var rr = global.spawn_cards[2][r]
				if(rr.cost <= self.credits) // 10000 is a placeholder value for "most expensive option available"
				{
					choice = rr
					self.credits -= rr.cost

					// spawn

					break
				}
			}
		}
	}

	self.Disable = function()
	{
		self.enabled = 0
		self.waveType = 0
	}

	self.Step = function() // the spawn loop
	{
		if(!self.enabled)
			return;

		if(global.enemyCount < 30)
			self.generatorTicker = approach(self.generatorTicker, 60, global.dt)

		// aiming for 800!
		self.BuildCreditScore()
		self.spawnTimer = max(0, self.spawnTimer - global.dt)

		if(self.spawnTimer > 0) return;

		var card = self.lastSpawnCard
		if(self.lastSpawnSucceeded == 0) // if the last spawn failed, obtain a new card
		{
			var _catagory = random_weighted([{v: 0, w: 2}, {v: 1, w: 1}])
			self.lastSpawnCard = global.spawn_cards[_catagory][irandom(array_length(global.spawn_cards[_catagory]) - 1)]
			card = self.lastSpawnCard
			self.lastSpawnPos = {x: obj_player.x, y: obj_player.y}
		}

		var _spawnIndex = asset_get_index(card.index)
		if(self.spawnCounter < self.maxSpawns && card.cost <= self.credits && (card.cost >= self.credits / 6 && card.cost < 10000) && _spawnIndex != -1 && global.enemyCount < 30)
		{
			self.credits -= card.cost
			var xpReward = global.difficultyCoeff * card.cost * self.expMult
			var moneyReward = round(2 * global.difficultyCoeff * card.cost * self.expMult)

			instance_create_depth(self.lastSpawnPos.x + irandom_range(-32, 32), self.lastSpawnPos.y + irandom_range(-32, 0), 60, _spawnIndex, {xpReward, moneyReward})

			self.spawnCounter++
			self.lastSpawnSucceeded = 1
			self.spawnTimer = random_range(self.interval.minval, self.interval.maxval)
		}
		else
		{
			self.spawnCounter = 0
			self.lastSpawnSucceeded = 0
			self.spawnTimer = random_range(self.waveInterval.minval, self.waveInterval.maxval)
		}
	}

	self.BuildCreditScore = function() // the credit generator
	{
		if(self.generatorTicker == 60 && self.generatorTickerSeconds < self.wavePeriods[self.waveType])
		{
			self.generatorTicker = 0
			self.generatorTickerSeconds++
			self.credits += self.creditsPerSecond
		}
	}
}

function range(minval, maxval) constructor
{
	self.minval = minval
	self.maxval = maxval

	toString = function()
	{
		return $"({minval} - {maxval})"
	}
}

debug_log("startup", $"initialization completed, elapsed time: [{timer_to_timestamp(get_timer() - _boot_starttime)}]")
