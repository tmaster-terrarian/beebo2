local ItemRarity = lib.enums.ItemRarity

lib.registerItemDef("example_item", {
    rarity = ItemRarity.rare,

    ---@param context DamageEventContext
    ---@param stacks number
    onKill = lib.gmlMethod(function(context, stacks)
        lib.log("killed instance: "..tostring(context.target))
        if(lib.rng.Roll(0.25 * context.proc * stacks)) then
            lib.unit.inflictBuffNoContext("cloak", context.attacker, stacks + 2)
            lib.log("cloak triggered!")
        end
    end)
})

lib.registerBuffDef('cloak', {
    timed = true,
    duration = 3,
    ticksPerSecond = 0,
    stackable = false,

    ---@param instance Buff
    step = lib.gmlMethod(function(instance)
        instance.context.target.image_alpha = 0.5
    end),

    ---@param instance Buff
    on_expire = lib.gmlMethod(function(instance)
        instance.context.target.image_alpha = 1.0
    end)
})
