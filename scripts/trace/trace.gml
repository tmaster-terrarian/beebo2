/// @description  trace(...)
/// @param ...
function trace() {
	var r = "";
	for (var i = 1; i < argument_count; i++) {
		r += string(argument[i]) + (i < argument_count - 1 ? " " : "");
	}
	Log(string(argument[0]), r);
}
