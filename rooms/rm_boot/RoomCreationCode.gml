Log("Startup/INFO", $"About to startroom")

room_width = SC_W
room_height = SC_H

initializeMods()
Log("Modloader/INFO", $"successfully created {itemdef.total_items} items")
Log("Modloader/INFO", $"successfully created {modifierdef.total_modifiers} modifiers")
Log("Modloader/INFO", $"successfully created {buffdef.total_buffs} buffs")
Log("Modloader/INFO", $"finished loading mods")

Log("Startup/INFO", $"Startup completed, entering first room")

// room_goto(Room1)
