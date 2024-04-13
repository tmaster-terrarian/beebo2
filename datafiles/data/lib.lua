---@diagnostic disable: missing-return
---@meta

---@class ItemDef
---@field rarity lib.enums.ItemRarity?
local ItemDef = {}

---@param context DamageEventContext
---@param stacks integer
function ItemDef:onHit(context, stacks) end

---@param context DamageEventContext
---@param stacks integer
function ItemDef:onKill(context, stacks) end

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
function BuffDef:on_stack(instance) end

---@param instance Buff
function BuffDef:on_expire(instance) end

---@class Buff
---@field buff_id Readonly<string>
---@field context DamageEventContext
---@field stacks number
---@field timer Readonly<number>
local Buff = {}

---@class Instance

---@class DamageEventContext
---@field attacker Instance|unknown                     the initiator of the event
---@field target Instance|unknown                       the victim of the event
---@field damage Readonly<number>                       how much damage to be dealt<br>readonly - use the constructor to set it
---@field proc number                                   proc coefficient<br>(usually) multiplies with item activation chance
---@field use_attacker_items Readonly<boolean>          readonly - use the setter method
---@field force_crit Readonly<integer>                  readonly - use the setter method
---@field isReduceable Readonly<boolean>                readonly - use the setter method
---@field damage_type Readonly<lib.enums.DamageColor>   readonly - use the setter method
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
function DamageEventContext.damageType(value) end

---@class lib
lib = {
    ---@param id string
    ---@param def ItemDef?
    -- note: leaving the `def` argument blank will register an itemdef with no rarity (gray color)
    registerItemDef = function(id, def) end,

    ---@param id string
    ---@param def BuffDef
    registerBuffDef = function(id, def) end,

    ---@param attacker table
    ---@param target table
    ---@param damage number
    ---@param proc number
    ---@param use_attacker_items boolean?
    ---@param force_crit integer?
    ---@param reduceable boolean?
    ---@return DamageEventContext
    -- An object carrying lots of information for use in damage events
    createDamageEventContext = function(attacker, target, damage, proc, use_attacker_items, force_crit, reduceable) end,

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
        inflictBuffNoContext = function(buff_id, target, duration, stacks) end
    },

    ---Trigger various game events
    events = {
        ---@param ctx DamageEventContext
        doDamageEvent = function(ctx) end
    },

    ---Basic instance manipulation
    instance = {
        ---@param ins Instance
        ---@param name string
        ---@return any
        get = function(ins, name) end,

        ---@param ins Instance
        ---@param name string
        ---@param value any
        set = function(ins, name, value) end,

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

    ---@param text any
    logInfo = function (text) end
}
