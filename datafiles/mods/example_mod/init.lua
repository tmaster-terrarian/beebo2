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

registry.addBuff('cloak', {
    timed = true,
    duration = 3,
    ticksPerSecond = 0,
    stackable = false
})
