event_inherited();
if(ded)
call_later(1, time_source_units_seconds, function() {
	instance_create_depth(x, y, depth, object_index)
})
