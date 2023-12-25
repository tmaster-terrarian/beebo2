var _boot_starttime = get_timer()
file_delete("latest.log")

// pixelate gui
display_set_gui_size(320, 180)

// read and apply screenSize and draw_debug flags
debug_log("Main", "getting settings")

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

gamepad_set_axis_deadzone(0, 0.25)
gamepad_set_axis_deadzone(1, 0.25)
gamepad_set_axis_deadzone(2, 0.25)
gamepad_set_axis_deadzone(3, 0.25)

// game is too fucking LOUD
audio_master_gain(0.5 * global.snd_volume);

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
	playerhurt,
	bleed
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
	buff,
	upgrade
}

enum SkillType
{
	Primary,
	Secondary,
	Utility,
	Special
}

enum TimeUnits
{
	miliseconds,
	centiseconds,
	seconds,
	minutes,
	hours
}

// classes
function DamageEventContext(attacker, target, proc_type, damage, proc, use_attacker_items = 1, force_crit = -1, reduceable = 1) constructor
{
	self.attacker = attacker
	self.target = target
	self.damage = damage
	self.proc = proc
	self.proc_type = proc_type

	self.use_attacker_items = use_attacker_items
	self.force_crit = force_crit
	self.reduceable = reduceable

	self.excludedItems = []

	// builder methods
	self.useAttackerItems = function(value = 1)
	{
		self.use_attacker_items = value
		return self
	}
	self.forceCrit = function(value = -1)
	{
		self.force_crit = value
		return self
	}
	self.reduceable = function(value = 1)
	{
		self.reducable = value
		return self
	}
	self.exclude = function(args)
	{
		for(var i = 0; i < argument_count; i++)
			array_push(self.excludedItems, argument[i])
		return self
	}
}

function damage_event(ctx)
{
	if(ctx.damage <= 0)
		return;

	var _damage_type = damage_notif_type.generic
	var crit = 0

	var attacker_has_items = (instance_exists(ctx.attacker) && variable_instance_exists(ctx.attacker, "items"))

	if(instance_exists(ctx.target))
	{
		var _dir = random_range(-1, 1)

		if(ctx.target.invincible)
		{
			instance_create_depth((ctx.target.bbox_left + ctx.target.bbox_right) / 2, (ctx.target.bbox_top + ctx.target.bbox_bottom) / 2, 10, fx_damage_number, {notif_type: _damage_type, value: string_loc("damage.immune"), dir: 0})
			return
		}

		if(instance_exists(ctx.attacker))
		{
			_dir = random_range(0.25, 1) * sign(ctx.target.x - ctx.attacker.x)

			ctx.attacker.invokeOnCombatEnter()

			var infightCheck = ((ctx.target.team != Team.player) && ctx.target.team == ctx.attacker.team) // check for same team, unless the team is player, to prevent stuff similar to the funny beetle guard tantrums in ror2

			if((ctx.target.team != ctx.attacker.team || infightCheck) && !instance_exists(ctx.target.target)) // the target's target becomes the attacker
			{
				ctx.target.target = ctx.attacker
				ctx.target.aggrotimer = 0
			}

			if(ctx.force_crit == 0)
			{
				crit = 0
			}
			if(random(1) < ctx.attacker.crit_chance) || ctx.force_crit
			{
				crit = 1
				_damage_type = damage_notif_type.crit
			}

			if(ctx.use_attacker_items && attacker_has_items)
			{
				if(ctx.proc_type == proctype.onhit)
				for(var i = 0; i < array_length(ctx.attacker.items); i++)
				{
					var _item = ctx.attacker.items[i]
					var _def = getdef(_item.item_id, deftype.item)
					if(_def.proc_type == proctype.onhit && !array_contains(ctx.excludedItems, _item.item_id) && !_item.triggered)
					{
						_def.proc(ctx, _item.stacks)
						_item.triggered = 1
					}
				}

				// this is where the real shit happens
				var bloody_dagger_bonus = ((ctx.target.facing == 1 && ctx.target.x >= ctx.attacker.x) || (ctx.target.facing == -1 && ctx.target.x < ctx.attacker.x)) * (0.2 * item_get_stacks("bloody_dagger", ctx.attacker))

				var dmg_fac = 1 + bloody_dagger_bonus // + etc

				ctx.damage *= dmg_fac
			}

			if(ctx.attacker.team == Team.player)
			{
				if(crit)
					audio_play_sound(sn_hit_crit, 5, false)
				else
					audio_play_sound(sn_hit, 5, false)
			}
		}
		else 
		{
			if(ctx.force_crit > -1)
			{
				crit = ctx.force_crit
				if(ctx.force_crit)
					_damage_type = damage_notif_type.crit
			}
		}

		ctx.damage *= (1 + crit)

		var dmg = ctx.damage
		if(ctx.reduceable)
		{
			var fac = 1

			// reduce damage based on various items the target carries

			dmg *= fac
		}
		ctx.target.hp -= dmg

		if(object_get_parent(ctx.target.object_index) == obj_player)
		{
			audio_play_sound(sn_player_hit, 5, false)
			_damage_type = damage_notif_type.playerhurt
		}

		instance_create_depth((ctx.target.bbox_left + ctx.target.bbox_right) / 2, (ctx.target.bbox_top + ctx.target.bbox_bottom) / 2, 10, fx_damage_number, {notif_type: _damage_type, value: ceil(dmg), dir: _dir})

		// activate attacker's on kill items and target's on death items if target died
		if(ctx.target.hp <= 0)
		{
			if(instance_exists(ctx.attacker) && ctx.use_attacker_items && attacker_has_items)
			{
				if(ctx.proc_type == proctype.onkill)
				for(var i = 0; i < array_length(ctx.attacker.items); i++)
				{
					var _item = ctx.attacker.items[i]
					var _def = getdef(_item.item_id, deftype.item)
					if(_def.proc_type == proctype.onkill && !array_contains(ctx.excludedItems, _item.item_id) && !_item.triggered)
					{
						_def.proc(ctx, _item.stacks)
						_item.triggered = 1
					}
				}

				if(ctx.attacker.team == Team.player)
				{
					ctx.attacker.xp += ctx.target.xpReward
					ctx.attacker.money += ctx.target.moneyReward
				}
			}
			if(item_get_stacks("emergency_field_kit", ctx.target) > 0)
			{
				ctx.target.hp = ctx.target.hp_max
				item_add_stacks("emergency_field_kit", ctx.target, -1, 0)
				item_add_stacks("emergency_field_kit_consumed", ctx.target, 1, 0)
			}
		}
		else
		{
			ctx.target.flash = 3
		}
	}
}

function heal_event(target, value, _healtype = healtype.generic)
{
	if(value == 0)
		return;

	var heal_fac = 1
	target.hp += value * heal_fac

	if(_healtype != healtype.regen)
		instance_create_depth((target.bbox_left + target.bbox_right) / 2, (target.bbox_top + target.bbox_bottom) / 2, 10, fx_damage_number, {notif_type: damage_notif_type.heal, value: value, dir: -target.facing})
}

// could this be the ultimate form of framerate independence?
global.fixedStep = {
	_functions: [],
	t: 0,

	addFunction: function(func, thisObject = self) {
		var _id = floor(get_timer() / 1000)
		var f = {
			_thisObject: thisObject,
			__func: func,
			_func: function() { with(_thisObject) other.__func() },
			uniqueId: _id
		}
		array_push(self._functions, f)
		return f
	},

	step: function() {
		for(var i = 0; i < array_length(self._functions); i++)
		{
			self._functions[i]._func()
		}
		self.t++
	}
}

#macro FTICK global.fixedStep.t

function addFixedStep(func)
{
	return global.fixedStep.addFunction(func, self)
}

function deleteFixedStep(func)
{
	global.______grahhhhhh = func.uniqueId // I LOVE SCOPE SO MUCH AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	var ind = array_find_index(global.fixedStep._functions, function(e, i) {
		return (e.uniqueId == global.______grahhhhhh)
	})

	if(ind != -1)
	{
		array_delete(global.fixedStep._functions, ind, 1)
	}
}

global.fixedStepTimeSource = time_source_create(time_source_game, 1/60, time_source_units_seconds, global.fixedStep.step, [], -1)

// global variables
global.itemdata =
{
	item_tables :
	{
		any : [{v: 4, w: 1}, {v: 3, w: 1}, {v: 2, w: 1}, {v: 1, w: 1}, {v: 0, w: 1}],
		any_obtainable : [{v: 3, w: 1}, {v: 2, w: 1}, {v: 1, w: 1}],
		chest_small : [{v: 3, w: 0.01}, {v: 2, w: 1.98}, {v: 1, w: 7.92}],
		chest_large : [{v: 3, w: 2}, {v: 2, w: 8}]
	},
	rarity_colors :
	[
		#798686,
		#E8F6F4,
		#38EB73,
		#F3235E,
		#D508E5
	],
	damage_type_colors :
	[
		#E8F6F4,
		#F3235E,
		#9CE562,
		#D508E5,
		#7b003b,
		#73252f
	]
}

global.timescale = 1
global.dt = 1
global.t = 0 // run timer
global.gameTimer = 0 // time elapsed since the gm object was created

global.pause = 0

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

// constants
#macro SC_W 320
#macro SC_H 180
#macro MINUTE 3600

// macro macros
#macro PAUSECHECK if(global.pause) return;

// functions
// the following eight functions are credited to D'Andrëw Box on Github and are licensed under the MIT license.
function array_fill(_array, _val)
{
	for (var i = 0; i < array_length(_array); i++)
	{
		_array[i] = _val;
	}
}

function array_clear(_array) // basically just a macro
{
	array_delete(_array, 0, array_length(_array));
}

function array_empty(_array) // basically just a macro, 2
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

function file_text_read_whole(_file)
{
	if (_file < 0) return "";

	var _file_str = ""
	while (!file_text_eof(_file)) {
		_file_str += file_text_readln(_file);
	}

	return _file_str;
}

function file_json_read(_file)
{
	var _str = file_text_read_whole(_file);
	return json_parse(_str);
}

function file_text_get_lines_array(_file)
{
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
function json2file(_filename, _json = {}, _iteration = 0)
{
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

function interpSine(x)
{
	return cos((x+1)*pi)/2+0.5
}

// thanks for being so awesome YellowAfterLife
function cycle(value, _min, _max) {
	var result, delta;
	delta = (_max - _min);
	result = (value - _min) % delta;
	if (result < 0) result += delta;
	return _min + result;
}
function angleRotate(angle, target, speed) {
	var diff;
	diff = cycle(target - angle, -180, 180);
	if (diff < -speed) return angle - speed;
	if (diff > speed) return angle + speed;
	return target;
}

function instance_get_struct(ins)
{
	var struct = {}
	var array = variable_instance_get_names(ins)
	for (var i = 0; i < array_length(array); i++)
	{
		struct[$ array[i]] = variable_instance_get(ins, array[i])
	}
	return struct
}

function create_fxtrail(obj, life = 15)
{
	return instance_create_depth(
		obj.x, obj.y, obj.depth + 2, fx_afterimage,
		{
			sprite_index: obj.sprite_index,
			image_index: obj.image_index,
			image_xscale: obj.image_xscale,
			image_yscale: obj.image_yscale,
			image_blend: obj.image_blend,
			image_angle: obj.image_angle,
			image_alpha: 0.5,
			life
		}
	)
}

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

function item_id_get_random(_by_rarity, _table = global.itemdata.item_tables.any_obtainable)
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
		case deftype.item:
			return global.itemdefs[$ _defid]
			break;
		case deftype.modifier:
			return global.modiferdefs[$ _defid]
			break;
		case deftype.buff:
			return global.buffdefs[$ _defid]
			break;
	}
}

function team_nearest(x, y, team)
{
	with(par_unit)
	{
		if(self.team != team) // if team doesnt match move out of the way
		{
			self.___x = self.x
			self.x -= 1000000
		}
	}

	var result = instance_nearest(x, y, par_unit)
	if(instance_exists(result) && result.team != team)
		result = noone

	with(par_unit)
	{
		if(self.team != team)
		{
			self.x = self.___x
			self.___x = undefined
		}
	}

	return result
}

function t_inframes(value, unit)
{
	switch(unit)
	{
		case TimeUnits.miliseconds:
		{
			return (value * 60) * 0.001
		}
		case TimeUnits.centiseconds:
		{
			return (value * 60) * 0.01
		}
		case TimeUnits.seconds:
		{
			return (value * 60)
		}
		case TimeUnits.minutes:
		{
			return (value * 60) * 60
		}
		case TimeUnits.hours: // who would ever use this for some timer in a roguelike
		{
			return (value * 60) * 60 * 60
		}
	}
}

function getraritycol(_invitem)
{
	return global.itemdata.rarity_colors[global.itemdefs[$ _invitem.item_id].rarity]
}

function random_weighted(list) // example values: [{v:3,w:1}, {v:4,w:3}, {v:2,w:5}]; v:value, w:weight.
{
	var sum = 0

	for(var i = 0; i < array_length(list); i++)
	{
		sum += list[i].w
	}
	var selected = random(1) * sum

	var total = 0
	var lastGoodIndex = -1
	var chosenIndex = -1
	for(var i = 0; i < array_length(list); i++)
	{
		total += list[i].w
		if(selected <= total)
		{
			chosenIndex = i
			break;
		}
		lastGoodIndex = i

		// fallback if nothing is found
		if(i == array_length(list) - 1)
		{
			chosenIndex = lastGoodIndex
		}
	}

	return list[chosenIndex].v;
}

function timer_to_timestamp(_t)
{
	var _c = floor((abs(_t) / 10000)) % 100
	var _s = floor((abs(_t) / 1000000)) % 60
	var _m = floor(((abs(_t) / 1000000) / 60)) % 60
	var _h = floor(((abs(_t) / 1000000) / 60) / 60)
	var h = string(_h) + ":"

	if(_c < 10) _c = "0" + string(_c)
	if(_s < 10) _s = "0" + string(_s)
	if(_m < 10) _m = "0" + string(_m)
	if(_h < 10) h = "0" + string(_h) + ":"

	var str = ((_t < 0) ? "-" : "") + ((_h) ? h : "") + $"{_m}:{_s}.{_c}"

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
	if(val < 1000)
		return (string(val))
	else if(val < 1000000)
		return (string(round(val / 1000)) + "K")
	else
		return (string(round(val / 1000000)) + "M")
}
function string_real_shortened_ceil(val)
{
	if(val < 1000)
		return (string(ceil(val)))
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
	return (variable_struct_exists(global.lang, global.locale) && variable_struct_exists(global.lang[$ global.locale], key)) ? global.lang[$ global.locale][$ key] : (variable_struct_exists(global.lang.en, key) ? global.lang.en[$ key] : key)
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
			_item.description = string_loc($"item.{_name}.description")
			_item.lore = string_loc($"item.{_name}.lore")
		})
		debug_log("system", "reloaded item language data")

		struct_foreach(global.modifierdefs as (_name, _item)
		{
			_item.displayname = string_loc($"modifier.{_name}.name")
			_item.description = string_loc($"modifier.{_name}.description")
		})
		debug_log("system", "reloaded modifier language data")

		struct_foreach(global.buffdefs as (_name, _item)
		{
			_item.displayname = string_loc($"buff.{_name}.name")
			_item.description = string_loc($"buff.{_name}.description") // likely going to be left underutilized :(
		})
		debug_log("system", "reloaded buff language data")

		struct_foreach(global.upgradedefs as (_name, _item)
		{
			_item.displayname = string_loc($"upgrade.{_name}.name")
			_item.description = string_loc($"upgrade.{_name}.description")
			_item.lore = string_loc($"upgrade.{_name}.lore")
		})
		debug_log("system", "reloaded gun upgrade language data")

		debug_log("system", $"language data reload completed, elapsed time: [{timer_to_timestamp(get_timer() - _starttime)}]")
	}
}
locale()

global.lang = { en: {}, es: {} }

locale.init()
debug_log("Main/INFO", $"loaded languages: {struct_get_names(global.lang)}")

// itemdefs.gml
function _itemdef(name) constructor {
	self.name = name
	displayname = string_loc($"item.{name}.name")
	description = string_loc($"item.{name}.description")
	lore = string_loc($"item.{name}.lore")
	proc_type = proctype.none
	rarity = item_rarity.none

	calc = function(stacks) { return 0 }
	draw = function(stacks) {}
	step = function(target, stacks) {}
	proc = function(context, stacks) {}
}

function itemdef(__struct, _struct = {})
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
		rarity : item_rarity.common
	}),
	// your time will come again soon my friend
	// eviction_notice : itemdef(new _itemdef("eviction_notice"), {
	// 	proc_type : proctype.onhit,
	// 	rarity : item_rarity.rare,
	// 	proc : function(context, stacks)
	// 	{
	// 		if(context.attacker.hp/context.attacker.hp_max >= 0.9) && sign(context.proc)
	// 		{
	// 			var offx = 0
	// 			var offy = (context.attacker.bbox_top + context.attacker.bbox_bottom) / 2

	// 			var p = instance_create_depth(context.attacker.x + offx, context.attacker.y + offy, context.attacker.depth + 2, obj_paperwork)
	// 			p.damage = context.attacker.base_damage * (4 + stacks) * context.proc
	// 			p.team = context.attacker.team
	// 			p.dir = point_direction(context.attacker.x + offx, context.attacker.y + offy, context.target.x, context.target.y)
	// 			p.pmax = point_distance(context.attacker.x + offx, context.attacker.y + offy, context.target.x, context.target.y)
	// 			p.target = context.target
	// 			p.parent = context.attacker
	// 		}
	// 	}
	// }),
	serrated_stinger : itemdef(new _itemdef("serrated_stinger"), {
		proc_type : proctype.onhit,
		rarity : item_rarity.common,
		proc : function(context, stacks)
		{
			if(random(1) <= (0.1 * stacks * context.proc))
				buff_instance_create("bleed", context.exclude("serrated_stinger"), 1).damage = context.attacker.base_damage
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
	}),
	heal_on_level : itemdef(new _itemdef("heal_on_level"), {
		rarity : item_rarity.common
	}),
	hyperthreader : itemdef(new _itemdef("hyperthreader"), {
		rarity : item_rarity.legendary
	})
}

global.itemdefs_by_rarity = [{}, {}, {}, {}, {}]
struct_foreach(global.itemdefs as (_name, _item)
{
	global.itemdefs_by_rarity[_item.rarity][$ _name] = _item
})

debug_log("Main/INFO", $"successfully created {itemdef.total_items} items")

function item_instance(__id, _stacks = 1) constructor
{
	item_id = __id
	stacks = _stacks
	triggered = 0
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

function item_add_stacks(item_id, target, stacks = 1, notify = 0)
{
	if(notify && stacks >= 1 && object_get_parent(target.object_index) == obj_player)
	{
		array_push(gm.item_pickup_queue, item_id)
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
		array_push(target.items, new item_instance(item_id, stacks))
	}
}

function item_set_stacks(item_id, target, stacks, notify = 0)
{
	if(notify && stacks >= 1 && object_get_parent(target.object_index) == obj_player)
	{
		array_push(gm.item_pickup_queue, item_id)
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
		array_push(target.items, new item_instance(item_id, stacks))
	}
}

// modifiers
function _modifierdef(name) constructor
{
	self.name = name
	displayname = string_loc($"modifier.{name}.name")
	description = string_loc($"modifier.{name}.description")

	on_pickup = function() {}
}

function modifierdef(__newstruct, _struct = {})
{
	static total_modifiers = 0
	total_modifiers++

	var names = variable_struct_get_names(_struct)
	var size = variable_struct_names_count(_struct);

	for (var i = 0; i < size; i++) {
		var name = names[i];
		var element = variable_struct_get(_struct, name);
		variable_struct_set(__newstruct, name, element)
	}
	delete _struct
	return __newstruct
}

global.modifierdefs =
{
	unknown : new _modifierdef("unknown"),
	reckless : modifierdef(new _modifierdef("reckless")),
	evolution : modifierdef(new _modifierdef("evolution"), {
		on_pickup : function()
		{
			var _item = item_id_get_random(1, global.itemdata.item_tables.chest_small)
			if(instance_exists(obj_player))
				item_add_stacks(_item, obj_player, 3)
			item_add_stacks(_item, statmanager, 3, 0)
		}
	})
}

debug_log("Main/INFO", $"successfully created {modifierdef.total_modifiers} modifiers")

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
		array_push(global.rundata.modifiers, new modifier_instance(modifier_id, stacks))
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
		array_push(global.rundata.modifiers, new modifier_instance(modifier_id, stacks))
	}
}

// LETS DO SOME STATUS EFFECT STUFF
function _buffdef(name) constructor
{
	self.name = name
	self.displayname = string_loc($"buff.{name}.name")

	self.timed = 0
	self.duration = 1
	self.stackable = 0

	self.ticksPerSecond = 0

	self.apply = function(instance) {}

	self.timer_step = function(instance) {
		if(self.timed)
		{
			PAUSECHECK
			if(instance.timer <= 0)
			{
				self.on_expire(instance)
				return
			}
			else if(self.ticksPerSecond > 0)
			{
				if((instance.timer % (1 / self.ticksPerSecond)) == 1/60)
				{
					self.tick(instance)
				}
			}
			instance.timer -= (1 / 60) // duration is in seconds
		}
	}

	self.step = function(instance) {}
	self.tick = function(instance) {}

	self.on_stack = function(instance) {}
	self.on_replaced = function(instance, newinstance) {}
	self.on_expire = function(instance) {
		buff_instance_remove(instance)
	}
	self.on_remove = function(instance) {
		debug_log("Main/INFO", $"buff {instance.buff_id} removed from {instance.context.target.id}:{object_get_name(instance.context.target.object_index)}")
	}
}

function buffdef(__newstruct, _struct = {})
{
	static total_buffs = 0
	total_buffs++

	var names = variable_struct_get_names(_struct)
	var size = variable_struct_names_count(_struct);

	for (var i = 0; i < size; i++) {
		var name = names[i];
		var element = variable_struct_get(_struct, name);
		variable_struct_set(__newstruct, name, element)
	}
	delete _struct
	return __newstruct
}

global.buffdefs =
{
	unknown: new _buffdef("unknown"),
	bleed: buffdef(new _buffdef("bleed"), {
		timed: 1,
		duration: 3,
		ticksPerSecond: 4,
		stackable: 1,
		apply: function(instance)
		{
			instance.timer = self.duration * instance.context.proc
		},
		tick: function(instance)
		{
			instance.context.damage = instance.context.attacker.base_damage * 2.4
			damage_event(instance.context)
		}
	}),
	collapse: buffdef(new _buffdef("collapse"), {
		timed: 1,
		duration: 3,
		ticksPerSecond: 0,
		stackable: 1,
		apply: function(instance)
		{
			instance.timer = self.duration
		},
		on_expire: function(instance)
		{
			instance.context.damage = instance.context.attacker.base_damage * (4 * instance.stacks)
			damage_event(instance.context)
			buff_instance_remove(instance)
		}
	})
}

debug_log("Main/INFO", $"successfully created {buffdef.total_buffs} buffs")

function buff_instance(buff_id, context, stacks) constructor
{
	self.buff_id = buff_id
	self.context = context
	self.stacks = stacks
	self.timer = -1

	var def = getdef(buff_id, deftype.buff)
	def.apply(self)
}

// applies a buff instance with id [buff_id] to [target]
//  context example: new DamageEventContext(attacker, target, proctype.none, 0, proc, 1, 0)
function buff_instance_create(buff_id, context, stacks = 1)
{
	var buff = new buff_instance(buff_id, context, stacks)
	var b = buff_get_instance(buff_id, context.target)
	if(b != -1)
	{
		var def = getdef(buff_id, deftype.buff)

		b.context = buff.context // overrides attacker, target, etc. (essentially a refresh)
		switch(buff_id) // timer stuff
		{
			case "bleed":
			{
				if(buff.timer > b.timer)
					b.timer += buff.timer
				break;
			}
			default:
			{
				if(buff.timer > b.timer)
					b.timer = buff.timer
				break;
			}
		}
		if(def.stackable)
			buff_instance_add_stacks(b, stacks)

		return b
	}
	else
		array_push(context.target.buffs, buff)
	return buff
}

function buff_instance_remove(instance)
{
	getdef(instance.buff_id, deftype.buff).on_remove(instance)
	for(var i = 0; i < array_length(instance.context.target.buffs); i++)
	{
		if(instance.context.target.buffs[i].buff_id == instance.buff_id)
		{
			array_delete(instance.context.target.buffs, i, 1)
			return;
		}
	}
}

function buff_instance_exists(buff_id, target) // returns 1 if found, otherwise returns 0
{
	for(var i = 0; i < array_length(target.buffs); i++)
	{
		if(target.buffs[i].buff_id == buff_id)
		{
			return 1
		}
	}
	return -1
}
function buff_get_instance(buff_id, target) // returns buff_instance:struct if found, otherwise returns -1
{
	for(var i = 0; i < array_length(target.buffs); i++)
	{
		if(target.buffs[i].buff_id == buff_id)
		{
			return target.buffs[i]
		}
	}
	return -1
}

function buff_instance_add_stacks(instance, stacks)
{
	var oldstacks = instance.stacks
	instance.stacks += stacks
	if(instance.stacks <= 0)
		getdef(instance.buff_id, deftype.buff).on_expire(instance)
	else if(instance.stacks > oldstacks)
		getdef(instance.buff_id, deftype.buff).on_stack(instance)
}
function buff_instance_set_stacks(instance, stacks)
{
	var oldstacks = instance.stacks
	instance.stacks = stacks
	if(instance.stacks <= 0)
		getdef(instance.buff_id, deftype.buff).on_expire(instance)
	else if(instance.stacks > oldstacks)
		getdef(instance.buff_id, deftype.buff).on_stack(instance)
}

function buff_get_stacks(buff_id, target)
{
	var b = buff_get_instance(buff_id, target)
	if(b)
		return b.stacks
	else
		return 0
}
function buff_add_stacks(buff_id, target, stacks)
{
	var def = getdef(buff_id, deftype.buff)
	var buff = buff_get_instance(buff_id, target)
	if(buff)
	{
		var oldstacks = buff

		buff.stacks += stacks
		if(buff.stacks <= 0)
			def.on_expire(buff)
		else if(buff.stacks > oldstacks)
			def.on_stack(buff)
	}
}
function buff_set_stacks(buff_id, target, stacks)
{
	var def = getdef(buff_id, deftype.buff)
	var buff = buff_get_instance(buff_id, target)
	if(buff)
	{
		var oldstacks = buff

		buff.stacks = stacks
		if(buff.stacks <= 0)
			def.on_expire(buff)
		else if(buff.stacks > oldstacks)
			def.on_stack(buff)
	}
}

function buff_get_timer(buff_id, target)
{
	if(buff_instance_exists(buff_id, target))
		return buff_get_instance(buff_id, target).timer
	else
		return 0
}
function buff_add_timer(buff_id, target, timer)
{
	for(var i = 0; i < array_length(target.buffs); i++)
	{
		if(target.buffs[i].buff_id == buff_id)
		{
			target.buffs[i].timer += timer
			if(target.buffs[i].timer <= 0)
				getdef(buff_id, deftype.buff).on_expire(target.buffs[i])
			return;
		}
	}
}
function buff_set_timer(buff_id, target, timer)
{
	for(var i = 0; i < array_length(target.buffs); i++)
	{
		if(target.buffs[i].buff_id == buff_id)
		{
			target.buffs[i].timer = timer
			if(target.buffs[i].timer <= 0)
				getdef(buff_id, deftype.buff).on_expire(target.buffs[i])
			return;
		}
	}
}

// gun modules
// (scrapped content)
function _upgradedef(_name) constructor {
	name = _name
	displayname = string_loc($"upgrade.{name}.name")
	description = string_loc($"upgrade.{name}.description")
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
		new spawn_card("obj_strikes_back", 1, 8)
	],
	[ // strong
		new spawn_card("obj_e_bombguy", 1, 40)
	],
	[ // boss
		new spawn_card("obj_e_strikes_backer", 1, 600)
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

		self.credits = self.creditsStart + (self.waveImmediateCreditsFraction[self.waveType]) * totalWaveCreds
		self.creditsPerSecond = 	   (1 - self.waveImmediateCreditsFraction[self.waveType]) * totalWaveCreds/self.wavePeriods[self.waveType]

		if(self.waveType == 1) // boss wave
		{
			var choice, r
			for(var c = 0; c < 100; c++) // doing this instead of a while loop in the case where nothing can spawn
			{
				r = irandom(array_length(global.spawn_cards[2]) - 1)
				var rr = global.spawn_cards[2][r]
				if(rr.cost <= self.credits)
				{
					choice = rr
					self.credits -= rr.cost

					instance_create_depth(obj_camera.tx, 152, 50, rr.index, {boss: true})

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
			var _catagory = random_weighted([{v: 2, w: 1}, {v: 1, w: 1}, {v: 0, w: 1}])
			self.lastSpawnCard = global.spawn_cards[_catagory][irandom(array_length(global.spawn_cards[_catagory]) - 1)]
			card = self.lastSpawnCard
			self.lastSpawnPos = {x: obj_camera.tx + random_range(-80, 80), y: ((card.spawnsOnGround) ? 152 : obj_camera.ty + random_range(-24, 48))}
		}

		var _spawnIndex = asset_get_index(card.index)
		if(self.spawnCounter < self.maxSpawns && card.cost <= self.credits && (card.cost >= self.credits / 6 && card.cost < 10000) && object_exists(_spawnIndex) && global.enemyCount < 30)
		{
			self.credits -= card.cost
			var xpReward = global.difficultyCoeff * card.cost * self.expMult
			var moneyReward = round(2 * global.difficultyCoeff * card.cost * self.expMult)

			instance_create_depth(self.lastSpawnPos.x, self.lastSpawnPos.y, 60, _spawnIndex, {xpReward, moneyReward})

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
	self.minval = min(minval, maxval)
	self.maxval = max(minval, maxval)

	toString = function()
	{
		return $"{minval} - {maxval}"
	}
}

// no more pains  ihope
function FixedTimeline(owner, keyframes) constructor
{
	static HitKeyframe = function(timeline, keyframe)
	{
		timeline.currentFrame++
		if(timeline.currentFrame == array_length(timeline.keyframes)) // reached the end of the line
		{
			timeline.currentFrame = 0
			time_source_reconfigure(timeline.timesource, time_source_game, timeline.keyframes[timeline.currentFrame].time, time_source_units_seconds, FixedTimeline.HitKeyframe, [timeline], -1)
		}
		else
		{
			with(timeline.owner)
				timeline.keyframes[timeline.currentFrame].action()

			time_source_reconfigure(timeline.timesource, time_source_game, timeline.keyframes[timeline.currentFrame].time, time_source_units_seconds, FixedTimeline.HitKeyframe, [timeline], -1)
			time_source_start(timeline.timesource)
		}
	}

	static Destroy = function(timeline) {
		time_source_destroy(timeline.timesource)
		delete timeline
	}

	self.Stop = function() {
		self.currentFrame = 0
		time_source_reconfigure(self.timesource, time_source_game, self.keyframes[self.currentFrame].time, time_source_units_seconds, FixedTimeline.HitKeyframe, [self], -1)
	}

	self.Start = function() {
		self.currentFrame = 0
		time_source_reconfigure(self.timesource, time_source_game, self.keyframes[self.currentFrame].time, time_source_units_seconds, FixedTimeline.HitKeyframe, [self], -1)
		time_source_start(self.timesource)
	}

	self.owner = owner
	self.keyframes = keyframes
	self.currentFrame = 0

	self.timesource = time_source_create(time_source_game, self.keyframes[self.currentFrame].time, time_source_units_seconds, FixedTimeline.HitKeyframe, [self], -1)
}
FixedTimeline(noone, [Keyframe(0, function() {})])

function Keyframe(time, action) // time is delay AFTER LAST KEYFRAME
{
	var obj = {}
	obj.time = time
	obj.action = action // function
	return obj
}

function State(func = noone) constructor
{
	self.baseDuration = 0.5
	self.duration = self.baseDuration
	self.age = 0

	self.onEnter = function(ins, obj) {
		ins.duration = ins.baseDuration
	}
	self.onExit = function(ins, obj) {
		ins.age = 0
		obj.attack_state = noone
	}
	self.update = function(ins, obj) {
		ins.age = approach(ins.age, ins.duration, global.dt / 60)
		if(ins.age >= ins.duration)
		{
			with(ins) onExit(self, obj)
		}
	}

	if(func != noone)
		func(self)
}

global._baseState = new State()

function _baseSkill() constructor
{
	self.name = "base"
	self.displayname = string_loc($"skill.base.name")
	self.description = string_loc($"skill.base.description")
	self.activationState = global._baseState
	self.baseMaxStocks = 1
	self.baseStockCooldown = 0.5
	self.beginCooldownOnEnd = 0
	self.fullRestockOnAssign = 1
	self.isCombatSkill = 0
	self.mustKeyPress = 0
	self.rechargeStock = 1
	self.requiredStock = 1
	self.stockToConsume = 1
	self.slot = "primary"
	self.priority = 0
	self.buffer = 0 // unused currently, will be used for buffering inputs
}

global.skilldefs = {
	base: new _baseSkill()
}

function Skill(name, func = noone) : _baseSkill() constructor
{
	self.name = string(name)
	self.displayname = string_loc($"skill.{self.name}.name")
	self.description = string_loc($"skill.{self.name}.description")

	if(func != noone)
		func(self)

	global.skilldefs[$ self.name] = self
}

function SkillInstance(skill) constructor
{
	self.def = skill
	self.stocks = skill.fullRestockOnAssign * skill.baseMaxStocks
	self.cooldown = !skill.fullRestockOnAssign * skill.baseStockCooldown
}

function CharacterDef(name, func = noone) constructor
{
	self.name = string(name)
	self.displayname = string_loc($"character.{self.name}.name")
	self.description = string_loc($"character.{self.name}.description")
	self.lore = string_loc($"character.{self.name}.lore")

	self.stats =
	{
		hp_max : 180,
		regen_rate : 1,
		curse : 1,
		spd : 2,
		jumpspd : -3.7,
		firerate : 5,
		bombrate : 0,
		spread : 4,
		damage : 10,
		ground_accel : 0.12,
		ground_fric : 0.08,
		air_accel : 0.07,
		air_fric : 0.02,
		jumps_max : 1,
		grv : 0.2,
		attack_speed : 1
	}
	self.level_stats =
	{
		hp_max: 30,
		damage: 2.4
	}

	self.skills = {
		primary:   new SkillInstance(global.skilldefs.base),
		secondary: new SkillInstance(global.skilldefs.base),
		utility:   new SkillInstance(global.skilldefs.base),
		special:   new SkillInstance(global.skilldefs.base)
	}

	self.attack_states = {
		primary:   variable_clone(self.skills.primary.def.activationState),
		secondary: variable_clone(self.skills.secondary.def.activationState),
		utility:   variable_clone(self.skills.utility.def.activationState),
		special:   variable_clone(self.skills.special.def.activationState)
	}

	if(func != noone)
		func(self)
}

// SKILL DEFINITIONS

var beeboPrimarySkill = new Skill("beebo.rapidfire", function(def) {
	def.baseMaxStocks = 1
	def.baseStockCooldown = 0
	def.beginCooldownOnEnd = 0
	def.fullRestockOnAssign = 1
	def.isCombatSkill = 1
	def.mustKeyPress = 0
	def.rechargeStock = 1
	def.requiredStock = 0
	def.stockToConsume = 0
	def.slot = "primary"
	def.priority = 0
	def.buffer = 0
})

var beeboSecondarySkill = new Skill("beebo.bomb_throw", function(def) {
	def.baseMaxStocks = 1
	def.baseStockCooldown = 3.5
	def.beginCooldownOnEnd = 0
	def.fullRestockOnAssign = 1
	def.isCombatSkill = 1
	def.mustKeyPress = 0
	def.rechargeStock = 1
	def.requiredStock = 1
	def.stockToConsume = 1
	def.slot = "secondary"
	def.priority = 1
	def.buffer = 1
})

var beeboUtilitySkill = new Skill("beebo.quick_evade", function(def) {
	def.baseMaxStocks = 1
	def.baseStockCooldown = 5
	def.beginCooldownOnEnd = 0
	def.fullRestockOnAssign = 1
	def.isCombatSkill = 0
	def.mustKeyPress = 0
	def.rechargeStock = 1
	def.requiredStock = 1
	def.stockToConsume = 1
	def.slot = "utility"
	def.priority = 2
	def.buffer = 0
})

var beeboSpecialSkill = new Skill("beebo.hotswap", function(def) {
	def.baseMaxStocks = 1
	def.baseStockCooldown = 6
	def.beginCooldownOnEnd = 0
	def.fullRestockOnAssign = 1
	def.isCombatSkill = 1
	def.mustKeyPress = 0
	def.rechargeStock = 1
	def.requiredStock = 1
	def.stockToConsume = 1
	def.slot = "special"
	def.priority = 1
	def.buffer = 1
})

var beeboPrimarySkillState = new State(function(def) {
	def.baseDuration = 5/60
	def.onEnter = function(ins, obj) {
		ins.duration = ins.baseDuration / obj.attack_speed

		with(obj)
		{
			screen_shake_set(1, 5)
			recoil = 3

			var v = spread
			var _obj = instance_create_depth(x + lengthdir_x(14, fire_angle) + gun_pos.x * sign(facing), y + lengthdir_y(14, fire_angle) + gun_pos.y - 1, depth - 3, obj_bullet)

			with (_obj)
			{
				parent = other
				team = other.team
				audio_play_sound(sn_player_shoot, 1, false);

				_speed = 12;
				direction = other.fire_angle + random_range(-v, v);
				image_angle = direction;

				damage = other.damage
			}
			with(instance_create_depth(x + lengthdir_x(4, fire_angle) + gun_pos.x * sign(facing), y + lengthdir_y(4, fire_angle) - 1 + gun_pos.y, depth - 5, fx_casing))
			{
				image_yscale = other.facing
				angle = other.fire_angle
				dir = other.facing
				hsp = -other.facing * random_range(1, 1.5)
				vsp = -1 + random_range(-0.2, 0.1)
			}

			heat = approach(heat, heat_max, heat_rate * global.dt)
			var n = irandom_range(0, (heat_max/ceil(heat))/round(global.dt))
			if(n == 0)
			{
				var dist = random_range(0.1, 1) * 12
				with(instance_create_depth(x + lengthdir_x(dist, fire_angle) + gun_pos.x * sign(facing), y - 2 + lengthdir_y(dist, fire_angle) + gun_pos.y, depth - 1, fx_dust))
				{
					vy = random_range(-1.5, -1) + other.vsp
					vx += other.hsp
				}
			}
			cool_delay = ins.duration + 30
		}
	}
}, beeboPrimarySkill)
beeboPrimarySkill.activationState = beeboPrimarySkillState

var beeboSecondarySkillState = new State(function(def) {
	def.baseDuration = 0.33
	def.onEnter = function(ins, obj) {
		ins.duration = ins.baseDuration / obj.attack_speed

		with(obj)
		{
			screen_shake_set(2, 10)
			recoil = 6

			var _obj = instance_create_depth(x + lengthdir_x(12, fire_angle) + gun_pos.x * sign(facing), y + lengthdir_y(12, fire_angle) + gun_pos.y - 1, depth - 2, obj_bomb, {damage_boosted : ((heat > 20) ? heat : 0)})

			with(_obj)
			{
				parent = other
				team = other.team
				audio_play_sound(sn_throw, 0, 0, 1, 0, 1)

				hsp = lengthdir_x(2, other.fire_angle) + (other.hsp * 0.5)
				vsp = lengthdir_y(2, other.fire_angle) + (other.vsp * 0.25) - 1

				damage = other.damage * (2 + 3 * (other.heat/other.heat_max))

				bulleted_delay = 20
			}
			repeat(6)
			{
				var dist = random_range(0.1, 1) * 12
				with(instance_create_depth(x + lengthdir_x(dist, fire_angle) + gun_pos.x * sign(facing), y - 2 + lengthdir_y(dist, fire_angle) + gun_pos.y, depth - 1, fx_dust))
				{
					vy = random_range(-1.5, -1) + other.vsp
					vx += other.hsp
					vx *= 1.5
					fric *= 0.2
				}
				audio_play_sound(sn_steam, 0, false, heat/heat_max)
			}
			heat = 0
		}
	}
}, beeboSecondarySkill)
beeboSecondarySkill.activationState = beeboSecondarySkillState

var beeboUtilitySkillState = new State(function(def) {
	def.baseDuration = 5/60

	def.onEnter = function(ins, obj) {
		ins.duration = ins.baseDuration

		with(obj)
		{
			hsp = (1.5 + (spd * 2) + (((spd / stats.spd) * 1) * on_ground) + (((spd / stats.spd - 2) * 0.1) * !on_ground)) * sign(facing)
			vsp = -1 * !on_ground

			sprite_index = spr_player_dash
			mask_index = mask_player
			image_index = 0

			timer0 = 0

			repeat(8)
			{
				with(instance_create_depth(x + random_range(-1, 4) * sign(facing), y - random(10), depth - 2, fx_dust))
				{
					vx = random_range(-3, -1) * sign(other.facing)
					vy = random_range(-0.5, 0.5)
				}
			}

			__utilityHit = []

			if(!variable_struct_exists(states, "SKILL_quick_evade"))
			{
				states.SKILL_quick_evade = function() {with(other) {
					can_jump = 1
					can_walljump = 0
					ghost = 0
					duck = 0
					fxtrail = 1
					hsp = approach(hsp, (spd + 1.5) * sign(facing), 0.25 * spd/stats.spd * global.dt)
					if(!on_ground)
						vsp = approach(vsp, 20, grv/2 * global.dt)

					if(on_ground && fxtrailtimer <= 1)
					{
						with(instance_create_depth(x + random_range(-1, 4) * sign(facing), y, depth - 2, fx_dust))
						{
							vx = random_range(-3, -1) * sign(other.facing)
							vy = random_range(-1.5, 0)
						}
					}

					var e = instance_place(x, y, par_unit)
					if(e && e.team != team && !array_contains(__utilityHit, e))
					{
						array_push(__utilityHit, e)
						damage_event(new DamageEventContext(id, e, proctype.onhit, base_damage * 0.5, 1, 1, 0))
					}

					if(abs(hsp) <= spd + 1.5)
					{
						state = "normal"
						__utilityHit = []
						fxtrail = 0
					}
				}}
			}
			state = "SKILL_quick_evade"
		}
	}
	self.update = function(ins, obj) {
		ins.age = approach(ins.age, ins.duration, global.dt / 60)
		if(ins.age >= ins.duration || obj.state != "SKILL_quick_evade")
		{
			obj.__utilityHit = []
			with(ins) onExit(self, obj)
			return;
		}
	}
	self.onExit = function(ins, obj) {
		ins.age = 0
		obj.attack_state = noone
	}
}, beeboUtilitySkill)
beeboUtilitySkill.activationState = beeboUtilitySkillState

global.chardefs = {
	base: new CharacterDef("base")
}

global.chardefs.beebo = new CharacterDef("beebo", function(def) {
	def.stats = {
		hp_max: 100,
		regen_rate: 1,
		curse: 1,
		spd: 2,
		jumpspd: -3.7,
		firerate: 5,
		bombrate: 80,
		spread: 4,
		damage: 12,
		ground_accel: 0.12,
		ground_fric: 0.08,
		air_accel: 0.07,
		air_fric: 0.02,
		jumps_max: 1,
		grv: 0.2,
		attack_speed: 1,
		heat_max: 100,
		heat_rate: 1,
		cool_rate: 1
	}
	def.level_stats = {
		hp_max: 30,
		damage: 2.4
	}

	def.skills = {
		primary:   new SkillInstance(global.skilldefs[$ "beebo.rapidfire"]),
		secondary: new SkillInstance(global.skilldefs[$ "beebo.bomb_throw"]),
		utility:   new SkillInstance(global.skilldefs[$ "beebo.quick_evade"]),
		special:   new SkillInstance(global.skilldefs[$ "beebo.hotswap"])
	}

	def.attack_states = {
		primary:   variable_clone(def.skills.primary.def.activationState),
		secondary: variable_clone(def.skills.secondary.def.activationState),
		utility:   variable_clone(def.skills.utility.def.activationState),
		special:   variable_clone(def.skills.special.def.activationState)
	}
})

global.chardefs.rival = new CharacterDef("rival", function(def) {
	def.stats = {
		hp_max: 100,
		regen_rate: 1,
		curse: 1,
		spd: 2,
		jumpspd: -3.7,
		firerate: 5,
		bombrate: 80,
		spread: 4,
		damage: 12,
		ground_accel: 0.12,
		ground_fric: 0.08,
		air_accel: 0.07,
		air_fric: 0.02,
		jumps_max: 1,
		grv: 0.2,
		attack_speed: 1
	}
	def.level_stats = {
		hp_max: 30,
		damage: 2.4
	}
})

// UI SHIZ

function ui_get_element(ui, x, y)
{
	for(var i = 0; i < array_length(ui.elements); i++)
	{
		var e = ui.elements[i]

		if(!is_instanceof(e, UI) && (x >= e.x && x <= e.x + e.w) && (y >= e.y && y <= e.y + e.h))
			return e
	}
	return noone
}

function ui_get_element_index(ui, x, y)
{
	for(var i = 0; i < array_length(ui.elements); i++)
	{
		var e = ui.elements[i]

		if((x >= e.x && x <= e.x + e.w) && (y >= e.y && y <= e.y + e.h))
			return i
	}
	return -1
}

function UI() constructor
{
	self.elements = []
	self.enabled = 1
	self.visible = 1

	self.selected = noone
	self.selectedIndex = 0

	self.x = 0
	self.y = 0
	self.w = 0
	self.h = 0

	self.step = function()
	{
		if(!self.enabled || !self.visible)
			return

		if(!global.controller)
		{
			self.selected = ui_get_element(self, round(window_mouse_get_x() / global.sc), round(window_mouse_get_y() / global.sc))
		}
		else
		{
			self.selected = self.elements[self.selectedIndex]
		}

		for(var i = 0; i < array_length(self.elements); i++)
		{
			var e = self.elements[i]
			if(e.enabled)
			{
				e.step()
				if(is_instanceof(e, UI))
				{
					if(e.selected != noone)
						self.selected = e.selected
				}
			}

			if(!is_instanceof(e, UI) && !is_instanceof(e, UIToggledElement))
				e.pressed = 0
		}

		if(self.selected != noone)
		{
			if(mouse_check_button_pressed(mb_left))
			{
				if(self.selected.enabled)
				{
					audio_play_sound(sn_click2, 0, 0)
				}
				self.selected.pressed = 1
			}
			if(mouse_check_button(mb_left))
			{
				if(self.selected.enabled)
				{
					self.selected.on_input()
				}
				if(!self.selected.toggle)
					self.selected.pressed = 1
			}
		}

		if(mouse_check_button_released(mb_left))
		{
			if(self.selected != noone)
			{
				if(self.selected.enabled)
				{
					self.selected.pressed = 1
					self.selected.on_confirm()
					audio_play_sound(sn_click3, 0, 0)
				}
				else
					audio_play_sound(sn_nuh_uh, 0, 0, 1, 0, random_range(0.9, 1.1))
			}
			for(var i = 0; i < array_length(self.elements); i++)
			{
				var e = self.elements[i]
				if(!is_instanceof(e, UI) && e.toggle)
				{
					if(self.selected != noone && e != self.selected && self.selected.toggle && self.selected.exclusive)
						if(e.exclusionMask == self.selected.exclusionMask)
							e.pressed = 0
				}
				else if(!is_instanceof(e, UI))
					e.pressed = 0
			}
		}
	}

	self.draw = function()
	{
		if(!self.visible)
			return

		for(var i = 0; i < array_length(self.elements); i++)
		{
			var e = self.elements[i]
			e.draw()
		}
	}
}

function UIElement(x, y, w, h) constructor
{
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.enabled = 1
	self.shaker = 0

	self.sprite = noone
	self.pressed = 0

	self.on_confirm = function() {}
	self.on_input = function() {}
	self.step = function() {}
	self.draw = function() {}

	self.toggle = 0
}

function UIToggledElement(x, y, w, h) constructor
{
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.enabled = 1
	self.shaker = 0

	self.sprite = noone
	self.pressed = 0
	self.exclusive = 0
	self.exclusionMask = 0b0000

	self.on_confirm = function() {}
	self.on_input = function() {}
	self.step = function() {}
	self.draw = function() {}

	self.toggle = 1
}

function UISpriteButton(x, y, w, h) : UIElement() constructor
{
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	self.sprite = spr_ui_button_green
	self.label = "Button"
	self.font = fnt_itemdesc

	self.draw = function()
	{
		var xx = self.x + irandom_range(-2, 2) * self.shaker
		var yy = self.y + irandom_range(-2, 2) * self.shaker

		draw_sprite_ext(self.sprite, self.pressed, xx, yy + 2 * self.pressed, self.w / sprite_get_width(self.sprite), self.h / sprite_get_height(self.sprite), 0, c_white, 1)

		draw_set_halign(fa_middle) draw_set_valign(fa_center) draw_set_color(c_white) draw_set_alpha(1) draw_set_font(self.font)
		draw_text(round(xx + self.w/2), round(yy + self.h/2) - 2 + 2 * self.pressed, self.label)
	}
}

function UIButtonSimple(x, y, w, h) : UIElement() constructor
{
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	self.label = "Button"
	self.font = fnt_itemdesc

	self.draw = function()
	{
		var xx = self.x + irandom_range(-2, 2) * self.shaker
		var yy = self.y + irandom_range(-2, 2) * self.shaker

		_draw_rect(xx, yy, xx + self.w - 1, yy + self.h - 1, c_black, 0.5 + self.pressed * 0.5, 0)

		if(self.pressed)
		{
			var x1 = xx - 0.5 - 1
			var x2 = xx + self.w - 1.5 + 1
			var y1 = yy - 0.5 - 1
			var y2 = yy + self.h - 1.5 + 1

			draw_line_width(x1 - 0.5, y1, x2 + 0.5, y1, 1) // top
			draw_line_width(x1, y1, x1, y2, 1) // left
			draw_line_width(x2, y1, x2, y2, 1) // right
			draw_line_width(x1 - 0.5, y2, x2 + 0.5, y2, 1) // bottom
		}

		draw_set_color(c_white)
		draw_set_halign(fa_middle) draw_set_valign(fa_center) draw_set_alpha(1) draw_set_font(self.font)
		draw_text(round(xx + self.w/2), round(yy + self.h/2) - 1, self.label)
	}
}

function UITextButton(x, y, w, h) : UIElement() constructor
{
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	self.label = "Button"
	self.font = fnt_itemdesc

	self.draw = function()
	{
		var xx = self.x + irandom_range(-2, 2) * self.shaker
		var yy = self.y + irandom_range(-2, 2) * self.shaker

		draw_set_color(c_white)

		draw_set_halign(fa_middle) draw_set_valign(fa_center) draw_set_alpha(1) draw_set_font(self.font)
		draw_text(round(xx + self.w/2) + self.pressed, round(yy + self.h/2) - 1, self.label)
	}
}

function UICategoryButton(x, y, w, h) : UIToggledElement() constructor
{
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	self.label = "Button"
	self.font = fnt_itemdesc

	self.draw = function()
	{
		var xx = self.x + irandom_range(-2, 2) * self.shaker
		var yy = self.y + irandom_range(-2, 2) * self.shaker

		draw_set_color(c_ltgray)

		if(self.pressed)
		{
			draw_set_color(c_white)
		}

		draw_set_halign(fa_left) draw_set_valign(fa_top) draw_set_alpha(1) draw_set_font(self.font)
		draw_text(round(xx) + pressed, round(yy), self.label)
	}
}

function UIText(x, y, w, color = c_white, alpha = 1) : UIToggledElement() constructor
{
	self.x = x
	self.y = y
	self.w = w
	self.h = 1

	self.color = color
	self.alpha = alpha

	self.label = "Text"
	self.font = fnt_itemdesc

	self.draw = function()
	{
		var xx = self.x + irandom_range(-2, 2) * self.shaker
		var yy = self.y + irandom_range(-2, 2) * self.shaker

		draw_set_halign(fa_left) draw_set_valign(fa_top) draw_set_font(self.font)
		draw_text_ext_color(round(xx), round(yy), self.label, -1, self.w, self.color, self.color, self.color, self.color, self.alpha)
	}
}

debug_log("Main", $"initialization completed, elapsed time: [{timer_to_timestamp(get_timer() - _boot_starttime)}]")
