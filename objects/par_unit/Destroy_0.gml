if(instance_exists(bigFlamo1)) bigFlamo1.stop()
if(instance_exists(bigFlamo2)) bigFlamo2.stop()

if(time_source_exists(_shield_recharge_handler)) call_cancel(_shield_recharge_handler)
