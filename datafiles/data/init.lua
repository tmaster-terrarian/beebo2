--#region items

registry.addItem("beeswax", {
    rarity = lib.enums.ItemRarity.common
})

registry.addItem("eviction_notice", {
    rarity = lib.enums.ItemRarity.legendary,

    ---@param context DamageEventContext
    ---@param stacks number
    onHit = function(context, stacks)
        if(context.attacker.hp/context.attacker.hp_max >= 0.8)
        then
            local offx = 0
            local offy = (context.attacker.bbox_top - context.attacker.bbox_bottom) / 2

            local p = lib.instance.createDepth(context.attacker.x + offx, context.attacker.y + offy, context.attacker.depth + 2, obj_paperwork)
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
    end
})

registry.addItem("serrated_stinger", {
    rarity = lib.enums.ItemRarity.common,

    ---@param context DamageEventContext
    ---@param stacks number
    onHit = function(context, stacks)
        if(lib.rng.Roll(0.1 * stacks * context.proc))
        then
            local ctx = lib.createDamageEventContext(context.attacker, context.target, context.attacker.base_damage * 0.2, 0)
                .exclude("serrated_stinger")
                .damageColor(lib.enums.DamageColor.bleed)

            lib.unit.inflictBuff("bleed", ctx, 3.0 * context.proc, 1)
        end
    end
})

registry.addItem("emergency_field_kit", {
    rarity = lib.enums.ItemRarity.legendary
})

registry.addItem("emergency_field_kit_consumed", {
    rarity = lib.enums.ItemRarity.none
})

registry.addItem("bloody_dagger", {
    rarity = lib.enums.ItemRarity.common
})

registry.addItem("lucky_clover", {
    rarity = lib.enums.ItemRarity.common
})

registry.addItem("heal_on_level", {
    rarity = lib.enums.ItemRarity.rare
})

registry.addItem("hyperthreader", {
    rarity = lib.enums.ItemRarity.legendary
})

registry.addItem("boost_damage", {
    rarity = lib.enums.ItemRarity.none
})

registry.addItem("boost_health", {
    rarity = lib.enums.ItemRarity.none
})

--#endregion

--#region buffs

registry.addBuff("bleed", {
    timed = true,
    duration = 3,
    ticksPerSecond = 4,
    stackable = true,
    tick = function(instance)
        lib.events.doDamageEvent(instance.context)
    end
})

registry.addBuff("collapse", {
    timed = true,
    duration = 3,
    ticksPerSecond = 0,
    stackable = true,
    --instance.context.damage = instance.context.attacker.base_damage * (4 * instance.stacks)
    onExpire = function(instance)
        lib.events.doDamageEvent(instance.context)
    end
})

--#endregion
