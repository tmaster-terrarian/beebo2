local ItemRarity = lib.enums.ItemRarity

lib.registerItemDef("example_item", {
    rarity = ItemRarity.rare,

    -- just adding a bit of jsdoc here so that we can make use of the handy intellisense in vscode
    ---@param context DamageEventContext
    ---@param stacks number
    onKill = function(context, stacks)
        if(random(1) < 0.25 * context.proc * stacks)
        then
            lib.unit.inflictBuffNoContext("cloak", context.attacker, stacks + 2)
        end
    end,

    onHit = function(context, stacks)
        lib.logInfo(context.attacker)
    end
})

lib.registerBuffDef('cloak', {
    timed = true,
    duration = 3,
    ticksPerSecond = 0,
    stackable = false
})
