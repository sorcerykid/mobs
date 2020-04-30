--------------------------------------------------------
-- Minetest :: Mobs Lite Mod (mobs)
--
-- See README.txt for licensing and release notes.
-- Copyright (c) 2016-2020, Leslie E. Krause
--
-- ./games/minetest_game/mods/mobs/extras.lua
--------------------------------------------------------


minetest.register_craftitem( "mobs:meat", {
	description = "Cooked Meat",
	inventory_image = "mobs_meat.png",
	on_use = minetest.item_eat( 4 ),
} )

minetest.register_craftitem( "mobs:meat_raw", {
	description = "Raw Meat",
	inventory_image = "mobs_meat_raw.png",
	on_use = minetest.item_eat( 1 ),
} )

minetest.register_craft( {
	type = "cooking",
	output = "mobs:meat",
	recipe = "mobs:meat_raw",
} )

minetest.register_alias( "default:meat_raw", "mobs:meat_raw" )
minetest.register_alias( "default:meat", "mobs:meat" )
