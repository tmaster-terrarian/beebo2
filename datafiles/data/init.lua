--#region item registry

lib.registerItemDef("beeswax", {
    rarity = lib.enums.ItemRarity.common
})

--#region eviction_notice functions

---@param context DamageEventContext
---@param stacks number
eviction_notice_onHit = function(context, stacks)
    if(context.attacker.hp/context.attacker.hp_max >= 0.8)
    then
        local offx = 0
        local offy = (lib.instance.get(context.attacker, "bbox_top") - lib.instance.get(context.attacker, "bbox_bottom")) / 2

        local att = {
            team = lib.instance.get(context.attacker, "team"),
            x = lib.instance.get(context.attacker, "x"),
            y = lib.instance.get(context.attacker, "y"),
            hp = lib.instance.get(context.attacker, "hp"),
            hp_max = lib.instance.get(context.attacker, "hp_max"),
            depth = lib.instance.get(context.attacker, "depth")
        }
        local tar = {
            x = lib.instance.get(context.target, "x"),
            y = lib.instance.get(context.target, "y")
        }

        local p = instance_create_depth(context.attacker.x + offx, context.attacker.y + offy, context.attacker.depth + 2, obj_paperwork)
        lib.instance.set(p, "team", att.team)
        lib.instance.set(p, "dir", point_direction(context.attacker.x + offx, context.attacker.y + offy, context.target.x, context.target.y))
        lib.instance.set(p, "pmax", point_distance(context.attacker.x + offx, context.attacker.y + offy, context.target.x, context.target.y))
        lib.instance.set(p, "target", context.target)
        lib.instance.set(p, "parent", context.attacker)

        lib.instance.set(p, "context", lib.createDamageEventContext(context.attacker, context.target, lib.instance.get(context.attacker, "base_damage") * (4 + stacks), 0)
            .forceCrit(context.crit)
            .useAttackerItems(1)
            .reduceable(1)
            .exclude("eviction_notice")
        )
    end
end

--#endregion

lib.registerItemDef("eviction_notice", {
    rarity = lib.enums.ItemRarity.legendary,
    onHit = lib.gmlMethod("eviction_notice_onHit", 2)
})

--#region serrated_stinger functions

---@param context DamageEventContext
---@param stacks number
serrated_stinger_onHit = function(context, stacks)
    if(lib.math.RollChance(0.1 * stacks * context.proc))
    then
        local ctx = lib.createDamageEventContext(context.attacker, context.target, lib.instance.get(context.attacker, "base_damage") * 0.2, 0)
            .useAttackerItems(1)
            .reduceable(1)
            .exclude("serrated_stinger")
            .damageType(lib.enums.DamageColor.bleed)

        lib.unit.inflictBuff("bleed", ctx, 3 * context.proc, 1)
    end
end

--#endregion

lib.registerItemDef("serrated_stinger", {
    rarity = lib.enums.ItemRarity.common,
    onHit = lib.gmlMethod("serrated_stinger_onHit", 2)
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
