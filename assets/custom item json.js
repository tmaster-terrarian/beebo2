
// a custom itemdef using json
let itemJson = {
    id: "some_item",
    statChanges: [
        {
            targetStat: "max_hp", // must be a reference to a stat that the owner has.
            method: "add", // can be "add", "subtract", "multiply_by", or "divide_by". method is different from function because it is the change to be applied to the target stat
            value: {
                function: "multiply", // can be a slew of things, see below.
                value1: {
                    function: "item_stacks",
                    id: "some_item" // item_id reference (string)
                },
                value2: 12
            }
        }
    ],
    maxStacks: -1
}

let ex = {
    function: "hyperbolic", // returns (1 - 1/power(1 + value2 * value1, exp)). returns a value between 0 and 1.
    value1: { // the x in the equation. works best if non-negative.
        function: "item_stacks",
        id: "some_item", // item_id reference (string)
    },
    value2: 0.12, // (real, {0 < value <= 1}) the a in the equation.
    exp: 1, // ([optional] real, {0 < value <= 1}) makes the curve steeper or shallower. default is 1.
    fixOne: false // if true, then if x == 1 then the function will just return a. default is false.
}

ex = {
    function: "exponential", // returns power(value2, value1)
    value1: { // the x in the equation. works best if non-negative.
        function: "item_stacks",
        id: "some_item", // item_id reference (string)
    },
    value2: 0.12, // (real, {0 < value}) the a in the equation.
}

ex = {
    function: "get_stat", // returns the stat value of a par_unit instance
    stat: "base_damage", // the stat to get
    target: { // can be a get_instance function (below) or "owner", where "owner" refers to the instances holding this item
        function: "get_instance",
        type: "team", // values can be "team" or "player". "team" refers to instances on the given team. "player" refers to obj_player
        searchFor: "nearest" // values can be "nearest", "random", or "all", where "all" will get the average stat value
    }
}

data = json_parse(itemJson);
newItem = {}

if (variable_struct_exists(data, "id"))
{
    newItem.name = data.id
}
if (variable_struct_exists(data, "statChanges"))
{
    for (var i = 0; i < array_length(data.statChanges); i++)
    {
        //
    }
}

// i just realized this works a lot like scratch lmao
let parse_arg = (obj, ins, method = noone) => {
    if(!is_struct(obj)) // if the top argument in the chain is not a struct, abort everything
    {
        switch(method)
        {
            case "add": case "subtract":
            {
                return 0;
            }
            case "multiply_by": case "divide_by":
            {
                return 1;
            }
            default:
            {
                break;
            }
        }
        return 0;
    }
    switch(obj.function) // giantass switch statement
    {
        case "add": case "subtract": // subtract is basically a macro for add(value1: [...], value2: invert(...)), same thing with divide
        {
            var isSubtract = ((obj.function == "subtract") ? -1 : 1)
            return((is_struct(obj.value1) ? parse_arg(obj.value1, ins) : real(obj.value1)) + isSubtract * (is_struct(obj.value2) ? parse_arg(obj.value2, ins) : real(obj.value2)))
        }
        case "multiply": case "divide":
        {
            var isDivide = ((obj.function == "divide") ? -1 : 1)
            return((is_struct(obj.value1) ? parse_arg(obj.value1, ins) : real(obj.value1)) + power(is_struct(obj.value2) ? parse_arg(obj.value2, ins) : real(obj.value2), isDivide))
        }
        case "min":
        {
            return min((is_struct(obj.value1) ? parse_arg(obj.value1, ins) : real(obj.value1)), (is_struct(obj.value2) ? parse_arg(obj.value2, ins) : real(obj.value2)))
        }
        case "max":
        {
            return max((is_struct(obj.value1) ? parse_arg(obj.value1, ins) : real(obj.value1)), (is_struct(obj.value2) ? parse_arg(obj.value2, ins) : real(obj.value2)))
        }
        case "sign":
        {
            return sign(is_struct(obj.value) ? parse_arg(obj.value, ins) : real(obj.value))
        }
        case "abs":
        {
            return abs(is_struct(obj.value) ? parse_arg(obj.value, ins) : real(obj.value))
        }
        case "sin":
        {
            var deg
            if(variable_struct_exists(obj, "units"))
            {
                if(obj.units == "degrees")
                    deg = 1
                else if(obj.units == "radians")
                    deg = 0
            }
            else
                deg = 0
            if(deg)
                return dsin(is_struct(obj.value) ? parse_arg(obj.value, ins) : real(obj.value))
            else
                return sin(is_struct(obj.value) ? parse_arg(obj.value, ins) : real(obj.value))
        }
        case "cos":
        {
            var deg
            if(variable_struct_exists(obj, "units"))
            {
                if(obj.units == "degrees")
                    deg = 1
                else if(obj.units == "radians")
                    deg = 0
            }
            else
                deg = 0
            if(deg)
                return dcos(is_struct(obj.value) ? parse_arg(obj.value, ins) : real(obj.value))
            else
                return cos(is_struct(obj.value) ? parse_arg(obj.value, ins) : real(obj.value))
        }
        case "arcsin":
        {
            var deg
            if(variable_struct_exists(obj, "units"))
            {
                if(obj.units == "degrees")
                    deg = 1
                else if(obj.units == "radians")
                    deg = 0
            }
            else
                deg = 0
            if(deg)
                return darcsin(clamp((is_struct(obj.value1) ? parse_arg(obj.value1, ins) : real(obj.value1)) / (is_struct(obj.value2) ? parse_arg(obj.value2, ins) : real(obj.value2)), -1, 1))
            else
                return arcsin(clamp((is_struct(obj.value1) ? parse_arg(obj.value1, ins) : real(obj.value1)) / (is_struct(obj.value2) ? parse_arg(obj.value2, ins) : real(obj.value2)), -1, 1))
        }
        case "arccos":
        {
            var deg
            if(variable_struct_exists(obj, "units"))
            {
                if(obj.units == "degrees")
                    deg = 1
                else if(obj.units == "radians")
                    deg = 0
            }
            else
                deg = 0
            if(deg)
                return darccos(clamp((is_struct(obj.value1) ? parse_arg(obj.value1, ins) : real(obj.value1)) / (is_struct(obj.value2) ? parse_arg(obj.value2, ins) : real(obj.value2)), -1, 1))
            else
                return arccos(clamp((is_struct(obj.value1) ? parse_arg(obj.value1, ins) : real(obj.value1)) / (is_struct(obj.value2) ? parse_arg(obj.value2, ins) : real(obj.value2)), -1, 1))
        }
        case "invert":
        {
            return ((is_struct(obj.value) ? parse_arg(obj.value, ins) : real(obj.value)) * -1)
        }
        case "exponential":
        {
            return(power((is_struct(obj.value2) ? parse_arg(obj.value2, ins) : real(obj.value2)), (is_struct(obj.value1) ? parse_arg(obj.value1, ins) : real(obj.value1))))
        }
        case "hyperbolic": // most complicated (code-wise) math function
        {
            var value1 = (is_struct(obj.value1) ? parse_arg(obj.value1, ins) : real(obj.value1))
            var value2 = (is_struct(obj.value2) ? parse_arg(obj.value2, ins) : real(obj.value2))
            var exp = (is_struct(obj.exp) ? parse_arg(obj.exp, ins) : real(obj.exp))
            var fixOne = (is_struct(obj.fixOne) ? parse_arg(obj.fixOne, ins) : real(obj.fixOne))
            var final = (1 - 1/power(1 + value2 * value1, exp))
            if(fixOne >= 1 && value2 > final)
            {
                if(value1 == 1)
                    return value2
                else
                    return final
            }
            else
                return final
        }
        case "condition": // if the value "if" returns a number greater than or equal to 1, it returns the value of "then", otherwise it returns the value of "else"
        {
            if((is_struct(obj.if) ? parse_arg(obj.if, ins) : real(obj.if)) >= 1)
                return (is_struct(obj.then) ? parse_arg(obj.then, ins) : real(obj.then))
            else
                return (is_struct(obj.else) ? parse_arg(obj.else, ins) : real(obj.else))
        }
        // the following functions' results are hardcoded, and cannot take a function as an argument. (for different reasons depending on the function)
        case "item_stacks":
        {
            return item_get_stacks(string(obj.id), ins)
        }
        case "modifier_stacks":
        {
            return modifier_get_stacks(string(obj.id))
        }
        case "runtimer": // timer in frames since start of run (IS EFFECTED BY PAUSING AND TIMESCALE!!)
        {
            return global.t;
        }
        case "gametimer": // timer in frames since game started up (RESETS ON RUN END)
        {
            return global.gameTimer;
        }
        case "timescale": // the multiplier of game time (for slowdown and speedup effects, defaults to 1)
        {
            return global.timescale;
        }
        case "wave": // the current wave of the run
        {
            return global.wave;
        }
        case "player_number":
        {
            return global.playerCount;
        }
        case "enemy_number":
        {
            return global.enemyCount;
        }
        case "enemy_level": // if the ins running this code is an enemy, this will have the same value as level
        {
            return global.enemyLevel;
        }
        case "level": // if the ins running this code is an enemy, this will have the same value as enemy_level
        {
            return ins.level;
        }
        case "base_damage":
        {
            return ins.base_damage;
        }
        case "x":
        {
            return ins.x;
        }
        case "y":
        {
            return ins.y;
        }
        case "on_ground":
        {
            return ins.on_ground;
        }
    }
}
