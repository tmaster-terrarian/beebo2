array_push(global.enabledMods, MOD_ID);

global.itemdefs.example_item = itemdef("example_item", {
    rarity: item_rarity.rare,
    onHit: function(context, stacks)
    {
        if(random(1) < 0.25 * stacks * context.proc)
        {
            buff_instance_create_headless("cloak", context.attacker, 2 + stacks)
        }
    },
});

