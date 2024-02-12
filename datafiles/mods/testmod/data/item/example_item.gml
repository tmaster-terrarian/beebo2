global.itemdefs.example_item = itemdef("example_item", {
    rarity: item_rarity.rare,
    onHit: function(context, stacks)
    {
        if(random_range(0, 1) <= 0.25 * stacks * context.proc)
        {
            var b = buff_instance_create_headless("cloak", context.attacker, 2 + stacks)
        }
    }
})
