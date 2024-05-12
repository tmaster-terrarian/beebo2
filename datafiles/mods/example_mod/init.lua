local ItemRarity = lib.enums.ItemRarity

registry.addItem("example_item", {
    rarity = ItemRarity.rare,

    onKill = function(context, stacks)
        if(lib.rng.Roll(0.25 * context.proc * stacks))
        then
            lib.unit.inflictBuffSimple("cloak", context.attacker, stacks + 2)

            lib.log("cloak triggered!")
        end
    end
})

registry.addItem("example_item2", {
    rarity = ItemRarity.common,

    onHit = function(context, stacks)
        local ctx = lib.createDamageEventContext(context.attacker, context.target, context.attacker.base_damage / 15, 0)
            .exclude("example_item2")

        lib.unit.inflictBuff("fire", ctx, 1.5 + 1.5 * stacks, 1)
    end
})

registry.addBuff('cloak', {
    timed = true,
    duration = 3,
    ticksPerSecond = 0,
    stackable = false
})
