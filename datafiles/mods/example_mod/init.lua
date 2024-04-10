lib.registerItemDef({
    name = "example_item",
    rarity = 2,
    onKill = function(context, stacks)
        if(random(1) < 0.25 * context.proc * stacks)
        then
            buff_instance_create_headless("cloak", context.attacker, stacks + 2)
        end
    end
})
