var _boot_starttime = get_timer()

#macro BASELINE_SCOPE ["~", "", ""]

global.__dbg_scope = [BASELINE_SCOPE]
global.__dbg_scopeName = "<unknown_object>"

randomize()
global.run_seed = random_get_seed()

file_delete("latest.log")

Log("Startup/INFO", $"Run seed: {global.run_seed}")

#macro SC_W 320
#macro SC_H 180

// read and apply screenSize and draw_debug flags
Log("Startup/INFO", "Reading player settings")

var __s = (320/SC_W)

ini_open("save.ini");
global.sc = clamp(floor(ini_read_real("settings", "res", floor(4 * __s))), floor(2 * __s), floor(6 * __s));
if(global.sc < floor(6 * __s))
{
	window_set_fullscreen(false);
	window_set_size((SC_W * global.sc), (SC_H * global.sc));
	window_center()
}
else
{
	window_set_fullscreen(true);
}
display_set_gui_size(SC_W, SC_H)

global.blurOnPause = clamp(floor(ini_read_real("settings", "blurOnPause", 1)), 0, 1);

global.draw_debug = ini_read_real("debug", "draw_debug", 0)
global.locale = ini_read_string("settings", "language", "en")

global.master_volume = ini_read_real("settings", "masterVolume", 0.5)
global.snd_volume = ini_read_real("settings", "soundVolume", 0.8)
global.bgm_volume = ini_read_real("settings", "musicVolume", 0.8)

ini_close()

gamepad_set_axis_deadzone(0, 0.3)
gamepad_set_axis_deadzone(1, 0.3)
gamepad_set_axis_deadzone(2, 0.3)
gamepad_set_axis_deadzone(3, 0.3)

// game is too fucking LOUD
audio_master_gain(0.5 * global.master_volume);

audio_group_set_gain(audiogroup_default, global.snd_volume, 0)
audio_group_load(audiogroup_music)

global.BGM = -1
global.BGM_EMITTER = audio_emitter_create()
global.BGM_BUS = audio_bus_create()
audio_emitter_bus(global.BGM_EMITTER, global.BGM_BUS)

global.BGM_LOWPASS = audio_effect_create(AudioEffectType.LPF2)
global.BGM_LOWPASS.cutoff = 20000
global.BGM_LOWPASS.q = 2
global.BGM_BUS.effects[0] = global.BGM_LOWPASS

global.__dbg_GlobalFunctions = getGlobalFunctionsList()

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
	bleed,
	immune
}

enum healtype
{
	generic,
	regen,
	hidden
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
	microseconds,
	milliseconds,
	centiseconds,
	frames,
	seconds,
	minutes,
	hours
}

global.__eventContextId = 0

// classes
function DamageEventContext(attacker, target, damage, proc, use_attacker_items = 1, force_crit = -1, reduceable = 1) constructor
{
	self.attacker = attacker
	self.target = target
	self.damage = damage
	self.proc = proc

	self.use_attacker_items = use_attacker_items
	self.force_crit = force_crit
	self.reduceable = reduceable
	self.damage_type = damage_notif_type.generic
	self.crit = 0

	self.blocked = 0

	self.excludedItems = []

	self.uniqueId = global.__eventContextId
	global.__eventContextId++

	// builder methods
	self.useAttackerItems = function(value = 1)
	{
		__dbg_stepIn("dev.bscit.beebo.DamageEventContext.useAttackerItems", _GMFILE_, _GMFUNCTION_)
		self.use_attacker_items = value
		__dbg_stepOut()
		return self
	}
	self.forceCrit = function(value = -1)
	{
		__dbg_stepIn("dev.bscit.beebo.DamageEventContext.forceCrit", _GMFILE_, _GMFUNCTION_)
		self.force_crit = value
		__dbg_stepOut()
		return self
	}
	self.isReduceable = function(value = 1)
	{
		__dbg_stepIn("dev.bscit.beebo.DamageEventContext.isReduceable", _GMFILE_, _GMFUNCTION_)
		self.reduceable = value
		__dbg_stepOut()
		return self
	}
	self.exclude = function(args)
	{
		__dbg_stepIn("dev.bscit.beebo.DamageEventContext.exclude", _GMFILE_, _GMFUNCTION_)
		for(var i = 0; i < argument_count; i++)
			array_push(self.excludedItems, string(argument[i]))
		__dbg_stepOut()
		return self
	}
	self.damageType = function(_type)
	{
		__dbg_stepIn("dev.bscit.beebo.DamageEventContext.damageType", _GMFILE_, _GMFUNCTION_)
		self.damage_type = _type
		__dbg_stepOut()
		return self
	}

	self.toString = function()
	{
		__dbg_stepIn("dev.bscit.beebo.DamageEventContext.toString", _GMFILE_, _GMFUNCTION_)
		var str = $"\{ uniqueId: {self.uniqueId}, attacker: {(instance_exists(self.attacker) ? (string(self.attacker.id) + " (" + object_get_name(self.attacker.object_index) + ")") : "noone")}, target: {(instance_exists(self.target) ? (string(self.target.id) + " (" + object_get_name(self.target.object_index) + ")") : "noone")}, damage: {self.damage}, procCoefficient: {self.proc}, procType: {self.proc_type}, useAttackerItems: {self.use_attacker_items}, criticalHit: {self.force_crit}, damageReduceable: {self.reduceable}, itemBlacklist: {self.excludedItems} \}"
		__dbg_stepOut()
		return str
	}

	self.chain = []
	self.nonlethal = 0

	// LogInfo("Main", "DamageEventContext created: " + string(self))
}

__dbg_stepIn("dev.bscit.beebo.GlobalScripts.boot", _GMFILE_, _GMFUNCTION_)

function damage_event(ctx)
{
	__dbg_stepIn("dev.bscit.beebo.damage_event", _GMFILE_, _GMFUNCTION_)
	var _damage_type = ctx.damage_type

	var damage = ctx.damage

	var attacker_has_items = (instance_exists(ctx.attacker) && variable_instance_exists(ctx.attacker, "items"))

	if(instance_exists(ctx.target))
	{
		var _dir = random_range(-1, 1)

		if(ctx.target.oneshotprotection > 0)
		{
			return
		}

		if(ctx.target.invincible)
		{
			instance_create_depth((ctx.target.bbox_left + ctx.target.bbox_right) / 2, (ctx.target.bbox_top + ctx.target.bbox_bottom) / 2, 10, fx_damage_number, {notif_type: damage_notif_type.immune, value: string_loc("damage.immune"), dir: 0})
			ctx.target.flash = 2
			ctx.blocked = 1
			return
		}

		if(instance_exists(ctx.attacker))
		{
			_dir = random_range(-0.25, 1) * sign(ctx.target.x - ctx.attacker.x)

			ctx.attacker.invokeOnCombatEnter()

			var infightCheck = ((ctx.target.team != Team.player) && ctx.target.team == ctx.attacker.team) // check for same team, unless the team is player, to prevent stuff similar to the funny beetle guard tantrums in ror2

			if((ctx.target.team != ctx.attacker.team || infightCheck) && !instance_exists(ctx.target.target)) // the target's target becomes the attacker
			{
				ctx.target.target = ctx.attacker
				ctx.target.aggrotimer = 0
			}

			if(ctx.force_crit == 0)
			{
				ctx.crit = 0
			}
			if(random(1) < ctx.attacker.crit_chance) || ctx.force_crit
			{
				ctx.crit = 1
				_damage_type = damage_notif_type.crit
			}

			if(!ctx.blocked)
			{
				var dmgFac = 1

				dmgFac += ((ctx.target.facing == 1 && ctx.target.x > ctx.attacker.x) || (ctx.target.facing == -1 && ctx.target.x < ctx.attacker.x)) * (0.2 * item_get_stacks("bloody_dagger", ctx.attacker))

				if(ctx.crit)
					dmgFac *= 2 * ctx.attacker.crit_modifier

				damage *= dmgFac

				if(ctx.attacker.team == Team.player)
				{
					if(ctx.crit)
						audio_play_sound(sn_hit_crit, 5, false)
					else
						audio_play_sound(sn_hit, 5, false)
				}
			}
		}
		else
		{
			if(ctx.force_crit > -1)
			{
				ctx.crit = ctx.force_crit
				if(ctx.force_crit)
					_damage_type = damage_notif_type.crit
			}
		}

		if(!ctx.blocked)
		{
			if(ctx.reduceable)
			{
				// do armor here pls
			}

			if(array_contains(global.players, ctx.target) && damage > ctx.target.total_hp_max * 0.9 && ctx.target.total_hp > ctx.target.total_hp_max * 0.9)
			{
				damage = ctx.target.total_hp_max * 0.9
				ctx.target.oneshotprotection = 6
			}

			var dmg = damage

			var _shield = ctx.target.shield
			ctx.target.shield = clamp(ctx.target.shield - damage, 0, ctx.target.max_shield)
			if(ctx.target.shield == 0)
			{
				// onShieldBroken event
			}

			ctx.target.hp -= max(damage - _shield, 0)

			if(ctx.target._shield_recharge_handler != -1 || time_source_exists(ctx.target._shield_recharge_handler))
				call_cancel(ctx.target._shield_recharge_handler)
			with(ctx.target)
			{
				_shield_recharge_handler = call_later(7, time_source_units_seconds, function() {
					_shield_recharge = 1
					_shield_recharge_handler = -1
				}, false)
			}
			ctx.target._shield = ctx.target.shield
			ctx.target._shield_recharge = 0

			if((ctx.nonlethal || ctx.target.oneshotprotection == 6) && ctx.target.hp < 1)
				ctx.target.hp = 1

			ctx.target.drawhp = 1
			ctx.target.hp_change_delay = 4 * max(ctx.proc, 0.25)

			if(array_contains(global.players, ctx.target))
			{
				audio_play_sound(sn_player_hit, 5, false)
			}

			// damage number
			instance_create_depth((ctx.target.bbox_left + ctx.target.bbox_right) / 2, (ctx.target.bbox_top + ctx.target.bbox_bottom) / 2, 10, fx_damage_number, {notif_type: _damage_type, value: ceil(damage), dir: _dir})
		}

		if(instance_exists(ctx.attacker) && ctx.use_attacker_items && attacker_has_items)
		{
			for(var i = 0; i < array_length(ctx.attacker.items); i++)
			{
				var _item = ctx.attacker.items[i]
				var _def = getdef(_item.item_id, deftype.item)
				if(!array_contains(ctx.excludedItems, _item.item_id) && !array_contains(ctx.chain, _item.item_id))
				{
					_def.onHit(ctx, _item.stacks)
				}
			}
		}

		// activate attacker's on kill items and target's on death items if target died
		if(ctx.target.hp <= 0)
		{
			if(instance_exists(ctx.attacker))
			{
				if(ctx.attacker.object_index == obj_player_benb)
				{
					var s = choose(sn_aaaaugh, sn_aaaaugh, sn_aaaaugh, sn_aaaugh_2, sn_aaaugh_2)
					audio_play_sound(s, 1, 0, 1.5, 0, random_range(0.9, 1.1))
				}
			}
			if(instance_exists(ctx.attacker) && ctx.use_attacker_items && attacker_has_items)
			{
				if(ctx.proc > 0)
				for(var i = 0; i < array_length(ctx.attacker.items); i++)
				{
					var _item = ctx.attacker.items[i]
					var _def = getdef(_item.item_id, deftype.item)
					if(!array_contains(ctx.excludedItems, _item.item_id) && !_item.triggered)
					{
						_def.onKill(ctx, _item.stacks)
						_item.triggered = 1
					}
				}

				if(ctx.attacker.team == Team.player)
				{
					for(var i = 0; i < array_length(global.players); i++)
						global.players[i].xp += ctx.target.xpReward
					global.money += ctx.target.moneyReward
				}
			}
			if(item_get_stacks("emergency_field_kit", ctx.target) > 0)
			{
				ctx.target.state = "normal"
				ctx.target.timer0 = 0
				ctx.target.hp = ctx.target.hp_max
				ctx.target.can_use_skills = 1
				item_add_stacks("emergency_field_kit", ctx.target, -1, 0)
				item_add_stacks("emergency_field_kit_consumed", ctx.target, 1, 0)
			}
		}
		else
		{
			ctx.target.flash = 3
		}
	}
	__dbg_stepOut()
}

function heal_event(target, value, _healtype = healtype.generic)
{
	__dbg_stepIn("dev.bscit.beebo.heal_event", _GMFILE_, _GMFUNCTION_)

	if(value == 0)
		return;

	var heal_fac = 1

	var val = value * heal_fac
	target.hp += val

	if(_healtype != healtype.regen && _healtype != healtype.hidden)
	{
		instance_create_depth((target.bbox_left + target.bbox_right) / 2, (target.bbox_top + target.bbox_bottom) / 2, 10, fx_damage_number, {notif_type: damage_notif_type.heal, value: val, dir: -target.facing})
	}

	__dbg_stepOut()
}

function __dbg_stepIn(str, FILE, FUNC)
{
	if(!variable_global_exists("__dbg_scope"))
		global.__dbg_scope = [BASELINE_SCOPE]
	array_insert(global.__dbg_scope, 0, [str, FILE, FUNC])
	global.__dbg_scopeName = FUNC
}
function __dbg_stepOut()
{
	array_shift(global.__dbg_scope)
}
function __dbg_clearScope()
{
	global.__dbg_scope = [BASELINE_SCOPE]
	global.__dbg_scopeName = "<unknown_object>"
}


function ThrowException(err, isEngineCrash = false)
{
    var _string = "gml.RuntimeException: " + err.message //string_replace(err.message, "<unknown_object>", global.__dbg_scopeName);

	var stack = err.stacktrace
	if(isEngineCrash)
	{
		for(var i = 0; i < array_length(stack); i++)
		{
			var line = string_split(stack[i], " ")

			// _string += "\n\tat " + global.__dbg_scope[i][0] + string_replace(line[1], "line", (!is_undefined(global.__dbg_scope[i][1]) ? global.__dbg_scope[i][1] : "unknown")) + ":" + line[2];
			_string += "\n\tat " + stack[i]
		}
		LogException(_string)
	}
	else
	{
		for(var i = 0; i < array_length(stack); i++)
		{
			var scope = stack[i][0], file = stack[i][1]
			if(i == 0)
				_string += "\n\tat " + scope + (file != "" ? "(" + file + ":" + string(err.line) + ")" : "")
			else
				_string += "\n\tat " + scope + (file != "" ? "(" + file + ")" : "")
		}
		LogException(_string)

		exception_unhandled_handler(undefined)
		show_error(err.message, true)
	}
}
function ThrowError(err) // harmless version of ThrowException (doesnt close the game)
{
    var _string = "gml.RuntimeError: " + err.message

	var stack = err.stacktrace
	for(var i = 0; i < array_length(stack); i++)
	{
		var scope = stack[i][0], file = stack[i][1]
		if(i == 0)
			_string += "\n\tat " + scope + (file != "" ? "(" + file + ":" + string(err.line) + ")" : "")
		else
			_string += "\n\tat " + scope + (file != "" ? "(" + file + ")" : "")
	}
	LogException(_string)
}

exception_unhandled_handler(function(err) {
	ThrowException(err, true)
	show_message("The game has crashed unexpectedly!\nDetails:\n\n###########################################\n" + err.longMessage + "###########################################")
	return 0
})

function __struct_get(struct, name, structname = -1)
{
	__dbg_stepIn("dev.bscit.beebo.__struct_get", _GMFILE_, _GMFUNCTION_)

	if(struct_exists(struct, name))
		return struct[$ name];

	var message = "Variable " + (structname == -1 ? "$$Anonymous_Struct$$" : string(structname)) + "." + string(name) + " not set before reading it."
	ThrowError({
		script: global.__dbg_scope[0][1],
		line: _GMLINE_ - 2,
		stacktrace: global.__dbg_scope,
		message: message
	})

	__dbg_stepOut()
}

// could this be the ultimate form of framerate independence?
global.fixedStep = {
	_functions: [],
	_queueFunctions: [],
	t: 0,

	addFunction: function(func, thisObject = self) {
		__dbg_stepIn("dev.bscit.beebo.fixedStep.addFunction", _GMFILE_, _GMFUNCTION_)
		var _id = floor(get_timer() / 1000)
		var f = {
			_thisObject: thisObject,
			__func: func,
			_func: function() { with(_thisObject) other.__func() },
			uniqueId: _id,
			t: 0
		}
		array_push(self._functions, f)
		__dbg_stepOut()
		return f
	},

	addQueueFunction: function(func, delaySeconds, thisObject = self) {
		__dbg_stepIn("dev.bscit.beebo.fixedStep.addQueueFunction", _GMFILE_, _GMFUNCTION_)
		var _id = floor(get_timer() / 1000)
		var f = {
			_thisObject: thisObject,
			__func: func,
			_func: function() { with(_thisObject) other.__func() },
			myT: delaySeconds * 60,
			startT: 0,
			uniqueId: _id
		}
		f.startT = self.t
		array_push(self._queueFunctions, f)
		__dbg_stepOut()
		return f
	},

	step: function() {
		__dbg_stepIn("dev.bscit.beebo.fixedStep.step", _GMFILE_, _GMFUNCTION_)
		for(var i = 0; i < array_length(self._functions); i++)
		{
			var f = self._functions[i]

			f._func()
			f.t++
		}
		for(var q = 0; q < array_length(self._queueFunctions); q++)
		{
			if(q >= array_length(self._queueFunctions))
				break

			var f = self._queueFunctions[q]
			if(floor(f.myT) == self.t - f.startT)
			{
				f._func()
				stopTimeout(f)
				q--
			}
		}
		self.t++
		__dbg_stepOut()
	}
}

#macro FIXED_TICK global.fixedStep.t

function addFixedStep(func)
{
	__dbg_stepIn("dev.bscit.beebo.addFixedStep", _GMFILE_, _GMFUNCTION_)
	var out = global.fixedStep.addFunction(func, self)
	__dbg_stepOut()
	return out
}

function setTimeout(func, delaySeconds)
{
	__dbg_stepIn("dev.bscit.beebo.setTimeout", _GMFILE_, _GMFUNCTION_)
	var out = global.fixedStep.addQueueFunction(func, delaySeconds, self)
	__dbg_stepOut()
	return out
}

function removeFixedStep(func)
{
	__dbg_stepIn("dev.bscit.beebo.removeFixedStep", _GMFILE_, _GMFUNCTION_)
	global.______grahhhhhh = func.uniqueId // I LOVE SCOPE SO MUCH AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	var ind = array_find_index(global.fixedStep._functions, function(e, i) {
		return (e.uniqueId == global.______grahhhhhh)
	})

	if(ind != -1)
	{
		array_delete(global.fixedStep._functions, ind, 1)
	}
	__dbg_stepOut()
}

function stopTimeout(func)
{
	__dbg_stepIn("dev.bscit.beebo.stopTimeout", _GMFILE_, _GMFUNCTION_)
	global.______grahhhhhh = func.uniqueId
	var ind = array_find_index(global.fixedStep._queueFunctions, function(e, i) {
		return (e.uniqueId == global.______grahhhhhh)
	})

	if(ind != -1)
	{
		array_delete(global.fixedStep._queueFunctions, ind, 1)
	}
	__dbg_stepOut()
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
		#73252f,
		#f1b00e
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
global.players = []
global.playerCount = 1
global.enemyCount = 0
global.fx_bias = 0
global.usesplitscreen = 0

global.friendlyfire = 0

global.money = 0

global.fnt_hudnumbers = font_add_sprite_ext(spr_hudnumbers, "/1234567890-KM$:", 0, 0)
global.fnt_hudstacks = font_add_sprite_ext(spr_hudstacksfnt, "1234567890-KM", 1, -1)

// macro macros
#macro PAUSECHECK if(global.pause) return;

// functions
// the following eight functions are credited to D'Andrëw Box on Github and are licensed under the MIT license.
function array_fill(_array, _val)
{
	__dbg_stepIn("mit.DAndrewBox.GML-Extended.lib.array.array_fill", _GMFILE_, _GMFUNCTION_)
	for (var i = 0; i < array_length(_array); i++)
	{
		_array[i] = _val;
	}
	__dbg_stepOut()
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
	__dbg_stepIn("mit.DAndrewBox.GML-Extended.lib.array.array_find_index_by_value", _GMFILE_, _GMFUNCTION_)

	for (var i = 0; i < array_length(_array); i++)
	{
		if (_array[i] == _val)
		{
			__dbg_stepOut()
			return i;
		}
	}

	__dbg_stepOut()
	return -1;
}

function file_text_read_whole(_file)
{
	__dbg_stepIn("mit.DAndrewBox.GML-Extended.lib.array.file_text_read_whole", _GMFILE_, _GMFUNCTION_)

	if (_file < 0) {__dbg_stepOut(); return ""};

	var _file_str = ""
	while (!file_text_eof(_file)) {
		_file_str += file_text_readln(_file);
	}

	__dbg_stepOut()

	return _file_str;
}

function file_json_read(_file)
{
	__dbg_stepIn("mit.DAndrewBox.GML-Extended.lib.array.file_json_read", _GMFILE_, _GMFUNCTION_)

	var _str = file_text_read_whole(_file);
	var out = json_parse(_str);

	__dbg_stepOut()
	return out
}

function file_text_get_lines_array(_file)
{
	__dbg_stepIn("mit.DAndrewBox.GML-Extended.lib.array.file_text_get_lines_array", _GMFILE_, _GMFUNCTION_)

	if (_file < 0) {__dbg_stepOut(); return []};

	var _file_arr = [];
	var _str = "";
	while (!file_text_eof(_file)) {
		_str = file_text_readln(_file);
		array_push(_file_arr, _str);
	}

	__dbg_stepOut()
	return _file_arr;
}

// do not pass in a value for _iteration when using this function !
function json2file(_filename, _json = {}, _iteration = 0)
{
	__dbg_stepIn("mit.DAndrewBox.GML-Extended.lib.array.json2file", _GMFILE_, _GMFUNCTION_)

	if (!is_struct(_json)) {__dbg_stepOut(); return ""};

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

	__dbg_stepOut()
	return _str;
}
// end of 3rd party functions

function interpSine(x) // funky curve from 0-1
{
	var out = cos((x+1)*pi)/2+0.5
	return out
}

function canHurt(obj1, obj2)
{
	var out = (obj1.team != obj2.team || global.friendlyfire)
	return out
}

function struct_clone(_struct = {})
{
	__dbg_stepIn("dev.bscit.beebo.struct_clone", _GMFILE_, _GMFUNCTION_)
	var __struct = {}

	// hhhhhh i hate scope issues so much
	var names = variable_struct_get_names(_struct)
	var size = variable_struct_names_count(_struct);

	for (var i = 0; i < size; i++) {
		var name = names[i];
		var element = variable_struct_get(_struct, name);
		variable_struct_set(__struct, name, element)
	}
	__dbg_stepOut()
	return __struct
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
	if(diff < -speed) return angle - speed;
	if(diff > speed) return angle + speed;
	return target;
}
function angleLerp(angle, target, t, speed = -1) {
	var diff = cycle(target - angle, -180, 180);
	speed = (target - angle) * t
	if(diff < -speed)
		return angle - speed;
	if(diff > speed)
		return angle + speed;
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
			image_angle: obj.image_angle,
			image_blend: obj.image_blend,
			image_alpha: 0.5,
			life
		}
	)
}

function create_fxtrail_ext(spr, ind, x, y, xscale, yscale, angle, color, alpha = 0.5, life = 15)
{
	return instance_create_depth(
		x, y, depth + 2, fx_afterimage,
		{
			sprite_index: spr,
			image_index: ind,
			image_xscale: xscale,
			image_yscale: yscale,
			image_angle: angle,
			image_blend: color,
			image_alpha: alpha,
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
		return struct_get_random(global.itemdefs_by_rarity[random_weighted(_table)])
	}
	else
	{
		return struct_get_random(global.itemdefs)
	}
}

function struct_get_random(_struct)
{
	var _array = struct_get_names(_struct)
	return _array[irandom(array_length(_array) - 1)]
}

function getdef(_defid, _deftype = 0)
{
	__dbg_stepIn("dev.bscit.beebo.getdef", _GMFILE_, _GMFUNCTION_)
	switch(_deftype)
	{
		case deftype.item:
			return __struct_get(global.itemdefs, _defid, "global.itemdefs")
			break;
		case deftype.buff:
			return __struct_get(global.buffdefs, _defid, "global.buffdefs")
			break;
		case deftype.modifier:
			return __struct_get(global.modifierdefs, _defid, "global.modifierdefs")
			break;
	}
	__dbg_stepOut()
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
		case TimeUnits.microseconds:
		{
			return value * 60 * 0.000001
		}
		case TimeUnits.milliseconds:
		{
			return value * 60 * 0.001
		}
		case TimeUnits.centiseconds:
		{
			return value * 60 * 0.01
		}
		case TimeUnits.frames:
		{
			return value
		}
		case TimeUnits.seconds:
		{
			return value * 60
		}
		case TimeUnits.minutes:
		{
			return value * 60 * 60
		}
		case TimeUnits.hours: // who would ever use this for some timer in a roguelike
		{
			return value * 60 * 60 * 60
		}
	}
}

function time_convert(value, units, newUnits)
{
	if(units == newUnits)
		return value;

	var FPS = 60 //game_get_speed(gamespeed_fps)

	switch(units)
	{
		case TimeUnits.microseconds:
			switch(newUnits)
			{
				case TimeUnits.microseconds: return value;
				case TimeUnits.milliseconds: return value * 0.001;
				case TimeUnits.centiseconds: return value * 0.0001;
				case TimeUnits.frames: 		 return value * 0.000001 * FPS;
				case TimeUnits.seconds: 	 return value * 0.000001;
				case TimeUnits.minutes: 	 return value * 0.000001 / 60;
				case TimeUnits.hours: 		 return value * 0.000001 / 60 / 60;
			}
		break;
		case TimeUnits.milliseconds:
			switch(newUnits)
			{
				case TimeUnits.microseconds: return value * 1000;
				case TimeUnits.milliseconds: return value;
				case TimeUnits.centiseconds: return value * 0.1;
				case TimeUnits.frames: 		 return value * 0.001 * FPS;
				case TimeUnits.seconds: 	 return value * 0.001;
				case TimeUnits.minutes: 	 return value * 0.001 / 60;
				case TimeUnits.hours: 		 return value * 0.001 / 60 / 60;
			}
		break;
		case TimeUnits.centiseconds:
			switch(newUnits)
			{
				case TimeUnits.microseconds: return value * 10000;
				case TimeUnits.milliseconds: return value * 10;
				case TimeUnits.centiseconds: return value;
				case TimeUnits.frames: 		 return value * 0.01 * FPS;
				case TimeUnits.seconds: 	 return value * 0.01;
				case TimeUnits.minutes: 	 return value * 0.01 / 60;
				case TimeUnits.hours: 		 return value * 0.01 / 60 / 60;
			}
		break;
		case TimeUnits.frames:
			switch(newUnits)
			{
				case TimeUnits.microseconds: return value / FPS * 1000000;
				case TimeUnits.milliseconds: return value / FPS * 1000;
				case TimeUnits.centiseconds: return value / FPS * 100;
				case TimeUnits.frames: 		 return value;
				case TimeUnits.seconds: 	 return value / FPS;
				case TimeUnits.minutes: 	 return value / FPS / 60;
				case TimeUnits.hours: 		 return value / FPS / 60 / 60;
			}
		break;
		case TimeUnits.seconds:
			switch(newUnits)
			{
				case TimeUnits.microseconds: return value * 1000000;
				case TimeUnits.milliseconds: return value * 1000;
				case TimeUnits.centiseconds: return value * 100;
				case TimeUnits.frames: 		 return value / FPS;
				case TimeUnits.seconds: 	 return value;
				case TimeUnits.minutes: 	 return value / 60;
				case TimeUnits.hours: 		 return value / 60 / 60;
			}
		break;
		case TimeUnits.minutes:
			switch(newUnits)
			{
				case TimeUnits.microseconds: return value * 1000000 * 60;
				case TimeUnits.milliseconds: return value * 1000 * 60;
				case TimeUnits.centiseconds: return value * 100 * 60;
				case TimeUnits.frames: 		 return value / FPS * 60;
				case TimeUnits.seconds: 	 return value * 60;
				case TimeUnits.minutes: 	 return value;
				case TimeUnits.hours: 		 return value / 60;
			}
		break;
		case TimeUnits.hours:
			switch(newUnits)
			{
				case TimeUnits.microseconds: return value * 1000000 * 60 * 60;
				case TimeUnits.milliseconds: return value * 1000 * 60 * 60;
				case TimeUnits.centiseconds: return value * 100 * 60 * 60;
				case TimeUnits.frames: 		 return value / FPS * 60 * 60;
				case TimeUnits.seconds: 	 return value * 60 * 60;
				case TimeUnits.minutes: 	 return value * 60;
				case TimeUnits.hours: 		 return value;
			}
		break;
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

function timer_to_string(_t)
{
	var __t = abs(_t) / 10000
	var _c = floor(__t) % 100
	var _s = floor(__t / 100) % 60
	var _m = floor((__t / 100) / 60) // % 60
	// var _h = floor(((__t / 100) / 60) / 60) // % 60
	// var h = string(_h) + ":"

	if(_c < 10) _c = "0" + string(_c)
	if(_s < 10) _s = "0" + string(_s)
	if(_m < 10) _m = "0" + string(_m)
	// if(_h < 10) h = "0" + string(_h) + ":"

	var str = $"{_m}:{_s}.{_c}"
	str = ((_t < 0) ? "-" : "") + str

	return str
}

function array_toString(array, separator, useBrackets = true)
{
	var str = ""

	if(useBrackets) str += "["
	for(var i = 0; i < array_length(array); i++)
	{
		if(is_string(array[i]))
			str += "'" + string(array[i]) + "'"
		else if(is_array(array[i]))
			str += array_toString(array[i], separator, true)
		else
			str += string(array[i])

		if(i < array_length(array) - 1 && array_length(array) > 1)
			str += string(separator)
	}
	if(useBrackets) str += "]"

	return str
}

function Log(src, str)
{
	var t = timer_to_string(get_timer())
	show_debug_message($"[{t}] [{src}]: {str}")

	var file = file_text_open_append("latest.log")
	file_text_write_string(file, $"[{t}] [{src}]: {str}")
	file_text_writeln(file)
	file_text_close(file)

	return {time: t, name: src, message: str}
}

function LogInfo(src, str)
{
	var t = timer_to_string(get_timer())
	show_debug_message($"[{t}] [{src}/INFO]: {str}")

	var file = file_text_open_append("latest.log")
	file_text_write_string(file, $"[{t}] [{src}/INFO]: {str}")
	file_text_writeln(file)
	file_text_close(file)

	return {time: t, name: src, message: str}
}

function LogException(str)
{
	show_debug_message(str)

	var file = file_text_open_append("latest.log")
	file_text_write_string(file, str)
	file_text_writeln(file)
	file_text_close(file)

	return {time: timer_to_string(get_timer()), name: "RuntimeException", message: str}
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

function instance_distance(ins1, ins2 = -1)
{
	if(ins2 != -1)
		return point_distance(ins1.x, ins1.y, ins2.x, ins2.y)
	return point_distance(x, y, ins1.x, ins1.y)
}

function instance_closest_bbox_edge_x(ins1, ins2 = noone) {
	if(ins2 != noone)
	{
		var diffx = ins2.x - ins1.x

		return (diffx > 0) ? ins2.bbox_right : ins2.bbox_left
	}
	else
	{
		var diffx = ins1.x - x

		return (diffx > 0) ? ins1.bbox_right : ins1.bbox_left
	}
}
function instance_closest_bbox_edge_y(ins1, ins2 = noone) {
	if(ins2 != noone)
	{
		var diffy = ins2.y - ins1.y

		return (diffy > 0) ? ins2.bbox_bottom : ins2.bbox_top
	}
	else
	{
		var diffx = ins1.x - x

		return (diffy > 0) ? ins1.bbox_bottom : ins1.bbox_top
	}
}

global.optionsStruct = {}
loadSettings()

// WOOO SEED LOADING YEA
if(global.optionsStruct.forcedRunSeed != -1)
{
	global.run_seed = global.optionsStruct.forcedRunSeed
	random_set_seed(global.optionsStruct.forcedRunSeed)
}

global.lang = { en: {}, es: {} }
global.langCache = {}

// localization
function string_loc(key) // example key: item.beeswax.name
{
	if(!variable_struct_exists(global.langCache, key))
	{
		var val = (variable_struct_exists(global.lang, global.locale) && variable_struct_exists(global.lang[$ global.locale], key)) ? global.lang[$ global.locale][$ key] : (variable_struct_exists(global.lang.en, key) ? global.lang.en[$ key] : key)
		global.langCache[$ key] = val
		return val
	}
	else
	{
		return global.langCache[$ key]
	}
}

function locale()
{
	static init = function(log = true)
	{
		delete global.lang
		delete global.langCache

		global.lang = { en: {}, es: {} }
		global.langCache = {}

		var file = file_text_open_read("data/lang.json")
		global.lang = file_json_read(file)
		file_text_close(file)

		if(log)
			Log("Main/INFO", $"loaded languages: {array_toString(struct_get_names(global.lang), ", ")}")
	}
	static reload = function()
	{
		var _starttime = get_timer()
		Log("Main/INFO", "reloading language data")

		locale.init()

		struct_foreach(global.itemdefs as (_name, _item)
		{
			_item.displayname = string_loc($"item.{_name}.name")
			_item.pickup = string_loc($"item.{_name}.pickup")
			_item.description = string_loc($"item.{_name}.description")
			_item.lore = string_loc($"item.{_name}.lore")
		})
		Log("Main/INFO", "reloaded item language data")

		struct_foreach(global.modifierdefs as (_name, _modifier)
		{
			_modifier.displayname = string_loc($"modifier.{_name}.name")
			_modifier.description = string_loc($"modifier.{_name}.description")
		})
		Log("Main/INFO", "reloaded modifier language data")

		struct_foreach(global.buffdefs as (_name, _buff)
		{
			_buff.displayname = string_loc($"buff.{_name}.name")
			_buff.description = string_loc($"buff.{_name}.description") // likely going to be left underutilized :(
		})
		Log("Main/INFO", "reloaded buff language data")

		Log("Main/INFO", $"language data reload completed, elapsed time: [{timer_to_string(get_timer() - _starttime)}]")
	}
}
locale()

locale.init(false)
Log("Startup/INFO", $"loaded languages: {array_toString(struct_get_names(global.lang), ", ")}")

// itemdefs.gml
function _itemdef(name) constructor {
	self.name = name
	displayname = string_loc($"item.{name}.name")
	pickup = string_loc($"item.{name}.pickup")
	description = string_loc($"item.{name}.description")
	lore = string_loc($"item.{name}.lore")
	proc_type = proctype.none
	rarity = item_rarity.none

	draw = function(stacks) {}
	step = function(target, stacks) {}
	onHit = function(context, stacks) {}
	onKill = function(context, stacks) {}
}

function itemdef(_name, _struct = {})
{
	static total_items = 0
	total_items++

	var __newstruct = new _itemdef(_name)

	// hhhhhh i hate scope issues so much
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

global.itemdefs =
{
	unknown : itemdef("unknown"),
	beeswax : itemdef("beeswax", {
		rarity : item_rarity.common
	}),
	eviction_notice : itemdef("eviction_notice", {
		rarity : item_rarity.legendary,
		onHit : function(context, stacks)
		{
			if(context.attacker.hp/context.attacker.hp_max >= 0.8)
			{
				var offx = 0
				var offy = (context.attacker.bbox_top - context.attacker.bbox_bottom) / 2

				var p = instance_create_depth(context.attacker.x + offx, context.attacker.y + offy, context.attacker.depth + 2, obj_paperwork)
				p.team = context.attacker.team
				p.dir = point_direction(context.attacker.x + offx, context.attacker.y + offy, context.target.x, context.target.y)
				p.pmax = point_distance(context.attacker.x + offx, context.attacker.y + offy, context.target.x, context.target.y)
				p.target = context.target
				p.parent = context.attacker

				p.context = new DamageEventContext(context.attacker, context.target, context.attacker.base_damage * (4 + stacks), 0)
					.forceCrit(context.crit)
					.useAttackerItems(1)
					.isReduceable(1)
					.exclude("eviction_notice")
			}
		}
	}),
	serrated_stinger : itemdef("serrated_stinger", {
		rarity : item_rarity.common,
		onHit : function(context, stacks)
		{
			if(random(1) < (0.1 * stacks * context.proc))
			{
				var ctx = new DamageEventContext(context.attacker, context.target, context.attacker.base_damage * 0.2, 0)
					.useAttackerItems(1)
					.isReduceable(1)
					.exclude("serrated_stinger")
					.damageType(damage_notif_type.bleed)

				var b = buff_instance_create("bleed", ctx, 3 * context.proc, 1)
			}
		}
	}),
	emergency_field_kit : itemdef("emergency_field_kit", {
		rarity : item_rarity.legendary
	}),
	emergency_field_kit_consumed : itemdef("emergency_field_kit_consumed", {
		rarity : item_rarity.none
	}),
	bloody_dagger : itemdef("bloody_dagger", {
		rarity : item_rarity.common
	}),
	lucky_clover : itemdef("lucky_clover", {
		rarity : item_rarity.common
	}),
	heal_on_level : itemdef("heal_on_level", {
		rarity : item_rarity.rare
	}),
	hyperthreader : itemdef("hyperthreader", {
		rarity : item_rarity.legendary
	}),
	boost_damage : itemdef("boost_damage", {
		rarity : item_rarity.none
	}),
	boost_health : itemdef("boost_health", {
		rarity : item_rarity.none
	})
}
global.itemdefs_by_rarity = [{}, {}, {}, {}, {}]

struct_foreach(global.itemdefs as (_name, _item)
{
	global.itemdefs_by_rarity[_item.rarity][$ _name] = _item
})

Log("Startup/INFO", $"successfully created {itemdef.total_items} items")

global.hi = getdef("hi", deftype.item)

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
		array_push(gm.item_pickup_queue, {item_id, target})
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
		array_push(gm.item_pickup_queue, {item_id, target})
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
function _modifierdef(_name) constructor
{
	self.name = _name
	displayname = string_loc($"modifier.{name}.name")
	summary = string_loc($"modifier.{name}.summary")
	description = string_loc($"modifier.{name}.description")

	on_pickup = function() {}
}

function modifierdef(_name, _struct = {})
{
	static total_modifiers = 0
	total_modifiers++

	var __newstruct = new _modifierdef(_name)

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

global.modifierdefs = {
	unknown: modifierdef("unknown"),
	cut_hp: modifierdef("cut_hp"),
	evolution: modifierdef("evolution", {
		on_pickup: function() {
			var item = item_id_get_random(1, global.itemdata.item_tables.chest_small)
			var stacks = 1
			var r = getdef(item, deftype.item).rarity
			if(r == item_rarity.common)
				stacks = 5
			if(r == item_rarity.rare)
				stacks = 3
			for(var i = 0; i < array_length(global.players); i++)
				item_add_stacks(item, global.players[i], stacks)
			item_add_stacks(item, statmanager, stacks)
		}
	})
}

Log("Startup/INFO", $"successfully created {modifierdef.total_modifiers} modifiers")

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

	self.apply = function(instance) {
		instance.timer = ceil(instance.timer * 60) / 60
	}

	self.timer_step = function(instance) {
		if(self.timed)
		{
			if(instance.timer <= 0)
			{
				self.on_expire(instance)
				return
			}
			else if(self.ticksPerSecond > 0)
			{
				if(ceil((instance.timer % (1 / self.ticksPerSecond)) * 60) == 1)
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
		Log("Main/INFO", $"buff {instance.buff_id} removed from {instance.context.target.id}:{object_get_name(instance.context.target.object_index)}")
	}
}

function buffdef(_name, _struct = {})
{
	static total_buffs = 0
	total_buffs++

	var __newstruct = new _buffdef(_name)

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
	unknown: buffdef("unknown"),
	bleed: buffdef("bleed", {
		timed: 1,
		duration: 3,
		ticksPerSecond: 4,
		stackable: 1,
		tick: function(instance)
		{
			damage_event(instance.context)
		}
	}),
	collapse: buffdef("collapse", {
		timed: 1,
		duration: 3,
		ticksPerSecond: 0,
		stackable: 1,
		// apply: function(instance)
		// {
		// 	instance.context.damage = instance.context.attacker.base_damage * (4 * instance.stacks)
		// },
		on_expire: function(instance)
		{
			damage_event(instance.context)
			buff_instance_remove(instance)
		}
	})
}

Log("Startup/INFO", $"successfully created {buffdef.total_buffs} buffs")

function buff_instance(buff_id, context, duration, stacks) constructor
{
	self.buff_id = buff_id
	self.context = context
	self.stacks = stacks
	self.timer = duration

	var def = getdef(buff_id, deftype.buff)
	def.apply(self)
}

// applies a buff instance with id [buff_id] to [target]
//  context example: new DamageEventContext(attacker, target, 0, proc, 1, 0)
function buff_instance_create(buff_id, context, duration = -1, stacks = 1)
{
	var buff = new buff_instance(buff_id, context, duration, stacks)
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

function buff_instance_create_headless(buff_id, target, duration = -1, stacks = 1)
{
	return buff_instance_create(buff_id, new DamageEventContext(noone, target, 0, 0, false, false, false), duration, stacks)
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
function spawn_card(index, weight, cost, spawnOffsetY = 0, spawnsOnGround = 1) constructor
{
	self.index = index
	self.weight = weight
	self.cost = cost
	self.spawnOffsetY = spawnOffsetY
	self.spawnsOnGround = spawnsOnGround
}

global.spawn_cards =
[
	[ // normal/small (beetle level)
		new spawn_card("obj_e_strikes_back", 1, 8),
		new spawn_card("obj_e_wall", 1, 18, -16)
	],
	[ // strong (elder lemurian type beat)
		new spawn_card("obj_e_bombguy", 1, 40)
	],
	[ // boss (stone titan shit yknow)
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
global.currentRoomInfo = {}

function Director(creditsStart, expMult, creditMult, waveInterval, interval, maxSpawns) constructor
{
	self.creditsStart = creditsStart
	self.expMult = expMult
	self.creditMult = creditMult
	self.waveInterval = waveInterval
	self.interval = interval
	self.maxSpawns = maxSpawns
	self.enabled = 0
	self.team = Team.enemy

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
	self.spawnRoomInfo = {}

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
			var choice = noone, r
			for(var i = 0; i < 3; i++)
			{
				if(choice != noone)
					break;
				for(var c = 0; c < 100; c++) // doing this instead of a while loop in the case where nothing can spawn
				{
					r = irandom(array_length(global.spawn_cards[i]) - 1)
					var rr = global.spawn_cards[i][r]
					if(rr.cost <= self.credits)
					{
						choice = rr
						break;
					}
				}
			}
			if(choice != noone)
			{
				gm.bossName = string_loc("boss." + choice.index + ".name")
				gm.bossSub = string_loc("boss." + choice.index + ".sub")

				var _spawnIndex = asset_get_index(choice.index)
				if(object_exists(_spawnIndex))
				{
					while(choice.cost <= self.credits)
					{
						var elite = (choice.cost * 6 <= self.credits) // make elite if affordable
						var cost = choice.cost * (1 + elite * 4)
						self.credits -= cost

						var xpReward = global.difficultyCoeff * cost * self.expMult
						var moneyReward = round(2 * global.difficultyCoeff * cost * self.expMult)

						trySpawnUnit(_spawnIndex, obj_camera.tx + irandom_range(-32, 32), ((choice.spawnsOnGround) ? 152 + choice.spawnOffsetY : obj_camera.ty + random_range(-24, 48)), self.team, {boss: true, xpReward, moneyReward, elite})
					}
				}
			}
		}
	}

	self.Disable = function()
	{
		self.enabled = 0
		self.waveType = 0
		self.credits = 0
		self.lastSpawnCard = noone
		self.lastSpawnPos = {x: obj_camera.tx, y: obj_camera.ty}
	}

	self.Step = function() // the spawn loop
	{
		if(!self.enabled)
			return;

		if(global.enemyCount < 30)
			self.generatorTicker = approach(self.generatorTicker, 60, global.dt)

		// aiming for 800!
		self.BuildCreditScore()

		if(self.spawnTimer > 0)
		{
			self.spawnTimer = max(0, self.spawnTimer - global.dt * 1/60)
		}
		else
		{
			var card = self.lastSpawnCard
			if(self.lastSpawnSucceeded == 0) // if the last spawn failed, obtain a new card
			{
				var _catagory = irandom_range(0, 2)
				var rrr = irandom(array_length(global.spawn_cards[_catagory]) - 1)

				self.lastSpawnCard = global.spawn_cards[_catagory][rrr]
				card = self.lastSpawnCard
				self.lastSpawnPos = {x: obj_camera.tx + random_range(-64, 64), y: ((card.spawnsOnGround) ? 152 + card.spawnOffsetY : obj_camera.ty + random_range(-24, 48))}
			}

			var _spawnIndex = asset_get_index(card.index)
			if(self.spawnCounter < self.maxSpawns && (card.cost <= self.credits) && (card.cost >= self.credits / 6 && card.cost < 600) && global.enemyCount < 30)
			{
				var elite = (card.cost * 6 <= self.credits)
				var cost = card.cost * (1 + elite * 4)
				self.credits -= cost
				var xpReward = global.difficultyCoeff * cost * self.expMult
				var moneyReward = round(2 * global.difficultyCoeff * cost * self.expMult)

				trySpawnUnit(_spawnIndex, self.lastSpawnPos.x, self.lastSpawnPos.y, self.team, {xpReward, moneyReward, boss: self.waveType, elite})

				self.lastSpawnPos = {x: obj_camera.tx + random_range(-64, 64), y: ((card.spawnsOnGround) ? 152 + card.spawnOffsetY : obj_camera.ty + random_range(-24, 48))}

				self.spawnCounter++
				self.lastSpawnSucceeded = 1
				self.spawnTimer = random_range(self.interval.minimum, self.interval.maximum)
			}
			else
			{
				self.spawnCounter = 0
				self.lastSpawnSucceeded = 0
				self.spawnTimer = random_range(self.waveInterval.minimum, self.waveInterval.maximum)
			}
		}
	}

	self.BuildCreditScore = function() // the credit generator
	{
		if(self.generatorTicker == 60)
		{
			if(self.generatorTickerSeconds < self.wavePeriods[self.waveType])
			{
				self.generatorTicker = 0
				self.generatorTickerSeconds++
				self.credits += self.creditsPerSecond
			}
			else self.Disable()
		}
	}
}

function range(minval, maxval) constructor
{
	self.minimum = min(minval, maxval)
	self.maximum = max(minval, maxval)

	toString = function()
	{
		return $"{minval}-{maxval}"
	}
}

function trySpawnUnit(ind, x, y, team, _args = {})
{
	var out = {succeeded: 0, onSpawnResult: 0}

	_args.team = team

	var ins = instance_create_depth(x, y, 60, ind, _args)
	out.succeeded = 1
	out.onSpawnResult = onUnitSpawn(ins)
	return out
}

function onUnitSpawn(ins)
{
	if(!instance_exists(ins))
		return -1
	var out = 0
	if(ins.boss)
	{
		item_add_stacks("boost_damage", ins, 1)
		item_add_stacks("boost_health", ins, 1)
		out = 1
	}
	return out
}

// no more pains  ihope
function FixedTimeline(owner, keyframes) constructor
{
	__dbg_stepIn("dev.bscit.beebo.FixedTimeline::new", _GMFILE_, _GMFUNCTION_)
	static HitKeyframe = function(timeline, keyframe)
	{
		__dbg_stepIn("dev.bscit.beebo.FixedTimeline.HitKeyFrame", _GMFILE_, _GMFUNCTION_)
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
		__dbg_stepOut()
	}

	static Destroy = function(timeline) {
		__dbg_stepIn("dev.bscit.beebo.FixedTimeline.Destroy", _GMFILE_, _GMFUNCTION_)
		time_source_destroy(timeline.timesource)
		delete timeline
		__dbg_stepOut()
	}

	self.Stop = function() {
		__dbg_stepIn("dev.bscit.beebo.FixedTimeline.prototype.Stop", _GMFILE_, _GMFUNCTION_)
		self.currentFrame = 0
		time_source_reconfigure(self.timesource, time_source_game, self.keyframes[self.currentFrame].time, time_source_units_seconds, FixedTimeline.HitKeyframe, [self], -1)
	}

	self.Start = function() {
		__dbg_stepIn("dev.bscit.beebo.FixedTimeline.prototype.Start", _GMFILE_, _GMFUNCTION_)
		self.currentFrame = 0
		time_source_reconfigure(self.timesource, time_source_game, self.keyframes[self.currentFrame].time, time_source_units_seconds, FixedTimeline.HitKeyframe, [self], -1)
		time_source_start(self.timesource)
		__dbg_stepOut()
	}

	self.owner = owner
	self.keyframes = keyframes
	self.currentFrame = 0

	self.timesource = time_source_create(time_source_game, self.keyframes[self.currentFrame].time, time_source_units_seconds, FixedTimeline.HitKeyframe, [self], -1)

	__dbg_stepOut()
}

function Keyframe(time, action) // time is delay AFTER LAST KEYFRAME
{
	__dbg_stepIn("dev.bscit.beebo.KeyFrame::new", _GMFILE_, _GMFUNCTION_)
	var obj = {}
	obj.time = time
	obj.action = action // function
	__dbg_stepOut()
	return obj
}

function State(func = noone) constructor
{
	__dbg_stepIn("dev.bscit.beebo.State::new", _GMFILE_, _GMFUNCTION_)
	self.baseDuration = 0.5
	self.duration = self.baseDuration
	self.age = 0

	self.onEnter = function(ins, obj) {
		__dbg_stepIn("dev.bscit.beebo.Skills.base.activationState.onEnter", _GMFILE_, _GMFUNCTION_)
		ins.duration = ins.baseDuration
		__dbg_stepOut()
	}
	self.onExit = function(ins, obj) {
		__dbg_stepIn("dev.bscit.beebo.Skills.base.activationState.onExit", _GMFILE_, _GMFUNCTION_)
		ins.age = 0
		obj.attack_state = noone
		__dbg_stepOut()
	}
	self.update = function(ins, obj) {
		__dbg_stepIn("dev.bscit.beebo.Skills.base.activationState.update", _GMFILE_, _GMFUNCTION_)
		ins.age = approach(ins.age, ins.duration, global.dt / 60)
		if(ins.age >= ins.duration)
		{
			with(ins) onExit(self, obj)
		}
		__dbg_stepOut()
	}

	if(func != noone)
		func(self)

	__dbg_stepOut()
}

global._baseState = new State()

function _baseSkill() constructor
{
	__dbg_stepIn("dev.bscit.beebo.Skills.base", _GMFILE_, _GMFUNCTION_)
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
	self.buffer = 0 // unused currently, may be used for buffering inputs
	self.spamCoeff = 1
	__dbg_stepOut()
}

global.skilldefs = {
	base: new _baseSkill()
}

function Skill(name, func = noone) : _baseSkill() constructor
{
	__dbg_stepIn("dev.bscit.beebo.Skill::new", _GMFILE_, _GMFUNCTION_)
	self.name = string(name)
	self.displayname = string_loc($"skill.{self.name}.name")
	self.description = string_loc($"skill.{self.name}.description")

	if(func != noone)
		func(self)

	global.skilldefs[$ self.name] = self
	__dbg_stepOut()
}

function SkillInstance(skill) constructor
{
	__dbg_stepIn("dev.bscit.beebo.SkillInstance::new", _GMFILE_, _GMFUNCTION_)
	self.def = skill
	self.stocks = skill.fullRestockOnAssign * skill.baseMaxStocks
	self.cooldown = !skill.fullRestockOnAssign * skill.baseStockCooldown
	__dbg_stepOut()
}

function CharacterDef(name, func = noone) constructor
{
	__dbg_stepIn("dev.bscit.beebo.CharacterDef::new", _GMFILE_, _GMFUNCTION_)
	self.name = string(name)
	self.displayname = string_loc($"character.{self.name}.name")
	self.description = string_loc($"character.{self.name}.description")
	self.lore = string_loc($"character.{self.name}.lore")

	self.stats =
	{
		hp_max : 100,
		regen_rate : 0,
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
		attack_speed : 1,
		shield : 0,
	}
	self.level_stats =
	{
		hp_max: 30,
		damage: 2.4,
        regen_rate: 0
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
	
	__dbg_stepOut()
}

initSkills()
initChars()

loadLevelData()

// UI SHIZ

function ui_get_element(ui, x, y)
{
	__dbg_stepIn("dev.bscit.beebo.ui_get_element", _GMFILE_, _GMFUNCTION_)
	for(var i = 0; i < array_length(ui.elements); i++)
	{
		var e = ui.elements[i]

		if(!is_instanceof(e, UI) && (x >= e.x && x <= e.x + e.w) && (y >= e.y && y <= e.y + e.h))
			return e
	}
	__dbg_stepOut()
	return noone
}

function ui_get_element_index(ui, x, y)
{
	__dbg_stepIn("dev.bscit.beebo.ui_get_element_index", _GMFILE_, _GMFUNCTION_)
	for(var i = 0; i < array_length(ui.elements); i++)
	{
		var e = ui.elements[i]

		if((x >= e.x && x <= e.x + e.w) && (y >= e.y && y <= e.y + e.h))
			return i
	}
	__dbg_stepOut()
	return -1
}

function UI() constructor
{
	__dbg_stepIn("dev.bscit.beebo.UI::new", _GMFILE_, _GMFUNCTION_)
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
		__dbg_stepIn("dev.bscit.beebo.UI.step", _GMFILE_, _GMFUNCTION_)
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
		__dbg_stepOut()
	}

	self.draw = function()
	{
		__dbg_stepIn("dev.bscit.beebo.UI.draw", _GMFILE_, _GMFUNCTION_)
		if(!self.visible)
			return

		for(var i = 0; i < array_length(self.elements); i++)
		{
			var e = self.elements[i]
			e.draw()
		}
		__dbg_stepOut()
	}
	__dbg_stepOut()
}

function UIElement(x, y, w, h) constructor
{
	__dbg_stepIn("dev.bscit.beebo.UIElement::new", _GMFILE_, _GMFUNCTION_)
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
	__dbg_stepOut()
}

function UIToggledElement(x, y, w, h) constructor
{
	__dbg_stepIn("dev.bscit.beebo.UIToggledElement::new", _GMFILE_, _GMFUNCTION_)
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
	__dbg_stepOut()
}

function UISpriteButton(x, y, w, h) : UIElement() constructor
{
	__dbg_stepIn("dev.bscit.beebo.UISpriteButton::new", _GMFILE_, _GMFUNCTION_)
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	self.sprite = spr_ui_button_green
	self.label = "Button"
	self.font = fnt_itemdesc

	self.draw = function()
	{
		__dbg_stepIn("dev.bscit.beebo.UISpriteButton.draw", _GMFILE_, _GMFUNCTION_)
		var xx = self.x + irandom_range(-2, 2) * self.shaker
		var yy = self.y + irandom_range(-2, 2) * self.shaker

		draw_sprite_ext(self.sprite, self.pressed, xx, yy + 2 * self.pressed, self.w / sprite_get_width(self.sprite), self.h / sprite_get_height(self.sprite), 0, c_white, 1)

		draw_set_halign(fa_middle) draw_set_valign(fa_center) draw_set_color(c_white) draw_set_alpha(1) draw_set_font(self.font)
		draw_text(round(xx + self.w/2), round(yy + self.h/2) - 2 + 2 * self.pressed, self.label)
		__dbg_stepOut()
	}
	__dbg_stepOut()
}

function UIButtonSimple(x, y, w, h) : UIElement() constructor
{
	__dbg_stepIn("dev.bscit.beebo.UIButtonSimple::new", _GMFILE_, _GMFUNCTION_)
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	self.label = "Button"
	self.font = fnt_itemdesc

	self.draw = function()
	{
		__dbg_stepIn("dev.bscit.beebo.UIButtonSimple.draw", _GMFILE_, _GMFUNCTION_)
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

		__dbg_stepOut()
	}
	__dbg_stepOut()
}

function UITextButton(x, y, w, h) : UIElement() constructor
{
	__dbg_stepIn("dev.bscit.beebo.UITextButton::new", _GMFILE_, _GMFUNCTION_)
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	self.label = "Button"
	self.font = fnt_itemdesc

	self.draw = function()
	{
		__dbg_stepIn("dev.bscit.beebo.UITextButton.draw", _GMFILE_, _GMFUNCTION_)
		var xx = self.x + irandom_range(-2, 2) * self.shaker
		var yy = self.y + irandom_range(-2, 2) * self.shaker

		draw_set_color(c_white)

		draw_set_halign(fa_middle) draw_set_valign(fa_center) draw_set_alpha(1) draw_set_font(self.font)
		draw_text(round(xx + self.w/2) + self.pressed, round(yy + self.h/2) - 1, self.label)

		__dbg_stepOut()
	}
	__dbg_stepOut()
}

function UICategoryButton(x, y, w, h) : UIToggledElement() constructor
{
	__dbg_stepIn("dev.bscit.beebo.UICategoryButton::new", _GMFILE_, _GMFUNCTION_)
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	self.label = "Button"
	self.font = fnt_itemdesc

	self.draw = function()
	{
		__dbg_stepIn("dev.bscit.beebo.UICategoryButton.draw", _GMFILE_, _GMFUNCTION_)
		var xx = self.x + irandom_range(-2, 2) * self.shaker
		var yy = self.y + irandom_range(-2, 2) * self.shaker

		draw_set_color(c_ltgray)

		if(self.pressed)
		{
			draw_set_color(c_white)
		}

		draw_set_halign(fa_left) draw_set_valign(fa_top) draw_set_alpha(1) draw_set_font(self.font)
		draw_text(round(xx) + pressed, round(yy), self.label)

		__dbg_stepOut()
	}
	__dbg_stepOut()
}

function UIText(x, y, w, color = c_white, alpha = 1) : UIToggledElement() constructor
{
	__dbg_stepIn("dev.bscit.beebo.UIText::new", _GMFILE_, _GMFUNCTION_)
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
		__dbg_stepIn("dev.bscit.beebo.UIText.draw", _GMFILE_, _GMFUNCTION_)
		var xx = self.x + irandom_range(-2, 2) * self.shaker
		var yy = self.y + irandom_range(-2, 2) * self.shaker

		draw_set_halign(fa_left) draw_set_valign(fa_top) draw_set_font(self.font)
		draw_text_ext_color(round(xx), round(yy), self.label, -1, self.w, self.color, self.color, self.color, self.color, self.alpha)

		__dbg_stepOut()
	}
	__dbg_stepOut()
}

global.enabledMods = []
mergeMods()
Log("Startup/INFO", $"completed merging mod contents with base game.")

Log("Startup/INFO", $"initialization completed, elapsed time: [{timer_to_string(get_timer() - _boot_starttime)}]")

__dbg_stepOut()
