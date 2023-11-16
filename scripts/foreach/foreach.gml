#macro as , function

/// @function foreach(struct as (element, [name], [index])
function foreach(struct, func) {
    var names = variable_struct_get_names(struct)
    var size = variable_struct_names_count(struct);
    
    for (var i = 0; i < size; i++) {
        var name = names[i];
        var element = variable_struct_get(struct, name);
        func(element, name, i);
    }
}
