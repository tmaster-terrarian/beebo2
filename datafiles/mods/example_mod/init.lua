local ItemRarity = lib.enums.ItemRarity

-- lua functions that you plan on being called within something (methods) need to use an odd workaround because gamemaker is silly

---@param context DamageEventContext
---@param stacks number
-- just adding a bit of jsdoc here so that we can make use of the handy intellisense in vscode
example_item_onKill = function(context, stacks)
    lib.log("killed instance input: " .. String(context.target.INPUT))
    if(lib.math.RollChance(0.25 * context.proc * stacks)) then
        lib.unit.inflictBuffNoContext("cloak", context.attacker, stacks + 2)
        lib.log("cloak triggered!")
    end
end

lib.registerItemDef("example_item", {
    rarity = ItemRarity.rare,
    onKill = lib.gmlMethod("example_item_onKill") --must be the same name as the function
})

lib.registerBuffDef('cloak', {
    timed = true,
    duration = 3,
    ticksPerSecond = 0,
    stackable = false,
})
