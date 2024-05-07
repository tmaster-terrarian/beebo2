---@diagnostic disable: missing-return, unused-local
---@meta

-- !!IMPORTANT!!:
-- you are *not* supposed to `require()` this file, as the actually functional
-- code is directly injected into the init script of each mod on initialization.
-- (see [lualib.gml](../../scripts/lualib/lualib.gml))
-- 
-- Treat this as you would treat a `.d.ts` file - it's all just type information.
local NOTICE = nil

---@class Instance: GmlStruct

---@class DamageEventContext
---@field attacker Instance                             the initiator of the event
---@field target Instance                               the victim of the event
---@field damage Readonly<number>                       how much damage to be dealt<br>readonly - use the constructor to set it
---@field proc number                                   proc coefficient<br>(usually) multiplies with item activation chance
---@field use_attacker_items Readonly<boolean>          readonly - use the setter method
---@field force_crit Readonly<integer>                  readonly - use the setter method
---@field isReduceable Readonly<boolean>                readonly - use the setter method
---@field damage_color Readonly<lib.enums.DamageColor>   readonly - use the setter method
---@field crit Readonly<boolean>                        will this event crit/has the event dealt a critical hit?<br>readonly - use the setter method
---@field blocked Readonly<boolean>                     was the damage blocked in this event?
---@field excludedItems Readonly<string[]>              list of items that the event is not allowed to trigger<br>readonly - use the setter method
---@field nonlethal boolean                             whether or not this event should be able to kill if the damage is high enough
---@field chain Readonly<string[]>                      list of items that have triggered so far in the proc chain
local DamageEventContext = {}

---@param value boolean|number
---@return DamageEventContext
function DamageEventContext.useAttackerItems(value) end

---@param value integer
---@return DamageEventContext
function DamageEventContext.forceCrit(value) end

---@param value boolean|number
---@return DamageEventContext
function DamageEventContext.reduceable(value) end

---@param value string
---@return DamageEventContext
function DamageEventContext.exclude(value) end

---@param value lib.enums.DamageColor
---@return DamageEventContext
function DamageEventContext.damageColor(value) end

-- creates a copy of the event context
---@return DamageEventContext
function DamageEventContext.copy() end

---@class lib
lib = {
    ---@param attacker Instance
    ---@param target Instance
    ---@param damage number
    ---@param proc number
    ---@param use_attacker_items boolean?
    ---@param force_crit integer?
    ---@param reduceable boolean?
    ---@return DamageEventContext
    -- An object carrying lots of information for use in damage events
    createDamageEventContext = function(attacker, target, damage, proc, use_attacker_items, force_crit, reduceable) end,

    -- ---Creates a function that gets error-checked on Gamemaker's end whenever it's called.
    -- ---@deprecated
    -- ---@param luaFunction string
    -- ---@return GmlMethod
    -- gmlMethod = function(luaFunction) end,

    ---Access units (players/enemies) and do various things with them
    unit = {
        ---@param buff_id string
        ---@param context DamageEventContext
        ---@param duration number?
        ---@param stacks integer?
        ---@return table
        inflictBuff = function(buff_id, context, duration, stacks) end,

        ---@param buff_id string
        ---@param target Instance
        ---@param duration number?
        ---@param stacks integer?
        ---@return table
        inflictBuffSimple = function(buff_id, target, duration, stacks) end
    },

    ---Trigger various game events
    events = {
        ---@param ctx DamageEventContext
        doDamageEvent = function(ctx) end
    },

    ---Basic instance manipulation
    instance = {
        ---@param ins Instance
        ---@return boolean
        exists = function(ins) end,

        ---@param x number
        ---@param y number
        ---@param obj any
        create = function(x, y, obj) end,

        ---@param x number
        ---@param y number
        ---@param depth number
        ---@param obj any
        createDepth = function(x, y, depth, obj) end,

        ---@param ins Instance
        destroy = function(ins) end,
    },

    ---Various enums
    enums = {
        ---@enum lib.enums.Team
        Team = { player = 0, enemy = 1, neutral = 2 },

        ---@enum lib.enums.ItemRarity
        ItemRarity = { none = 0, common = 1, rare = 2, legendary = 3, special = 4 },

        ---@enum lib.enums.DamageColor
        DamageColor = { generic = 0, crit = 1, heal = 2, revive = 3, playerhurt = 4, bleed = 5, immune = 6 }
    },

    ---log a message to the console
    ---@param text any the value will be turned into a string
    log = function (text) end,

    ---Helpful randomness functions
    rng = {
        ---@param x number value greater than 0.0
        ---@return number
        Random = function(x) end,

        ---@param x integer value greater than 0
        ---@return integer
        RandomInt = function(x) end,

        ---@param min number
        ---@param max number
        ---@return number
        RandomRange = function(min, max) end,

        ---@param min integer
        ---@param max integer
        ---@return integer
        RandomRangeInt = function(min, max) end,

        ---@param val number value between 0.0 and 1.0<br>the comparison is `random(1) <= val`<br>if the value is equal to either end of the range; then it directly returns the value as a boolean
        ---@return boolean
        Roll = function(val) end,
    }
}

---@class Item
---@field item_id Readonly<string>
---@field stacks integer
local Item = {}

---@class ItemDef
---@field rarity lib.enums.ItemRarity?
local ItemDef = {}

---@param context DamageEventContext
---@param stacks integer
function ItemDef:onHit(context, stacks) end

---@param context DamageEventContext
---@param stacks integer
function ItemDef:onKill(context, stacks) end

---@class Modifier
---@field modifier_id Readonly<string>
---@field stacks integer
local Modifier = {}

---@class ModifierDef
local ModifierDef = {}

function ModifierDef:onPickup() end

---@class Buff
---@field buff_id Readonly<string>
---@field context DamageEventContext
---@field stacks integer
---@field timer Readonly<number>
local Buff = {}

---@class BuffDef
---@field timed boolean?
---@field duration number?
---@field ticksPerSecond number?
---@field stackable boolean?
local BuffDef = {}

---@param instance Buff
-- runs at the same speed as the framerate
function BuffDef:step(instance) end

---@param instance Buff
-- runs at a fixed rate (every `1 / ticksPerSecond` seconds)
function BuffDef:tick(instance) end

---@param instance Buff
function BuffDef:onStack(instance) end

---@param instance Buff
function BuffDef:onExpire(instance) end

---@class registry
registry = {
    ---@param id string
    ---@param def ItemDef?
    ---@return GmlStruct
    -- note: leaving the `def` argument blank will register an itemdef with no rarity (gray color) and no special functions
    addItem = function(id, def) end,

    ---@param id string
    ---@param def ModifierDef
    ---@return GmlStruct
    addModifier = function(id, def) end,

    ---@param id string
    ---@param def BuffDef
    ---@return GmlStruct
    addBuff = function(id, def) end,
}
