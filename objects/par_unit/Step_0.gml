if(fucked > 0)
	fucked = approach(fucked, 0, global.dt / 6)
else
	fucker = noone

if(y > room_height + 48)
    hp = 0

if(!on_ground)
    vsp = approach(vsp, 20, grv * global.dt)

var names = struct_get_names(skills)
for(var i = 0; i < array_length(names); i++)
{
    var skill = skills[$ names[i]]
    var def = skill.def

    if(skill.cooldown > 0)
        skill.cooldown = approach(skill.cooldown, 0, global.dt / 60)
    else if(skill.stocks < def.baseMaxStocks + bonus_stocks[$ names[i]])
    {
        skill.cooldown = def.baseStockCooldown
        skill.stocks = min(skill.stocks + def.rechargeStock, def.baseMaxStocks + bonus_stocks[$ names[i]])
    }
}

if(hp <= 0) && !ded
{
    ded = 1
    instance_destroy()
}
