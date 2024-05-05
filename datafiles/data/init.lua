--#region item registry

lib.registerItemDef("unknown")

lib.registerItemDef("beeswax", {
    rarity = lib.enums.ItemRarity.common
})

lib.registerItemDef("eviction_notice", {
    rarity = lib.enums.ItemRarity.legendary,

    ---@param context DamageEventContext
    ---@param stacks number
    onHit = lib.gmlMethod(function(context, stacks)
        if(context.attacker.hp/context.attacker.hp_max >= 0.8)
        then
            local offx = 0
            local offy = (context.attacker.bbox_top - context.attacker.bbox_bottom) / 2

            local p = instance_create_depth(context.attacker.x + offx, context.attacker.y + offy, context.attacker.depth + 2, obj_paperwork)
            p.team = context.attacker.team
            p.dir = point_direction(context.attacker.x + offx, context.attacker.y + offy, context.target.x, context.target.y)
            p.pmax = point_distance(context.attacker.x + offx, context.attacker.y + offy, context.target.x, context.target.y)
            p.target = context.target
            p.parent = context.attacker

            p.context = lib.createDamageEventContext(context.attacker, context.target, context.attacker.base_damage * (4 + stacks), 0)
                .forceCrit(context.crit)
                .useAttackerItems(1)
                .reduceable(1)
                .exclude("eviction_notice")
        end
    end)
})

lib.registerItemDef("serrated_stinger", {
    rarity = lib.enums.ItemRarity.common,

    ---@param context DamageEventContext
    ---@param stacks number
    onHit = lib.gmlMethod(function(context, stacks)
        if(lib.rng.RollChance(0.1 * stacks * context.proc))
        then
            local ctx = lib.createDamageEventContext(context.attacker, context.target, lib.instance.get(context.attacker, "base_damage") * 0.2, 0)
                .useAttackerItems(1)
                .reduceable(1)
                .exclude("serrated_stinger")
                .damageColor(lib.enums.DamageColor.bleed)

            lib.unit.inflictBuff("bleed", ctx, 3 * context.proc, 1)
        end
    end)
})

lib.registerItemDef("emergency_field_kit", {
    rarity = lib.enums.ItemRarity.legendary
})

lib.registerItemDef("emergency_field_kit_consumed", {
    rarity = lib.enums.ItemRarity.none
})

lib.registerItemDef("bloody_dagger", {
    rarity = lib.enums.ItemRarity.common
})

lib.registerItemDef("lucky_clover", {
    rarity = lib.enums.ItemRarity.common
})

lib.registerItemDef("heal_on_level", {
    rarity = lib.enums.ItemRarity.rare
})

lib.registerItemDef("hyperthreader", {
    rarity = lib.enums.ItemRarity.legendary
})

lib.registerItemDef("boost_damage", {
    rarity = lib.enums.ItemRarity.none
})

lib.registerItemDef("boost_health", {
    rarity = lib.enums.ItemRarity.none
})

--#endregion
