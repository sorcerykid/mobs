--------------------------------------------------------
-- Minetest :: Mobs Lite Mod (mobs)
--
-- See README.txt for licensing and release notes.
-- Copyright (c) 2016-2020, Leslie E. Krause
--
-- ./games/minetest_game/mods/mobs/animals.lua
--------------------------------------------------------

-------------------------------------------
-- Kitten (aka Kit Kat)
-------------------------------------------

mobs.register_mob( "mobs:kitten", {
	type = "animal",
	description = "Kitten",
	timeout = 120,

	mesh = "mobs_kitten.b3d",
	collisionbox = { -0.3, -0.3, -0.3, 0.3, 0.25, 0.3 },     -- cardinal: left, bottom, back, right, top, front
	drawtype = "front",
	visual = "mesh",
	visual_size = { x = 0.5, y = 0.5 },
	height = 1,
	y_offset = 0,
	density = 0.5,

	groups = { mob = 1, animal = 1, walks = 1, mobile = 1 },
	textures = { "mobs_kitten.png" },

	makes_footstep_sound = false,
	makes_bloodshed_effect = true,

	hunger_params = { offset = -0.5, spread = 2.5 },
	alertness_states = {
		ignore = { view_offset = 2, view_radius = 4, view_height = 4, view_acuity = 3 },
		follow = { view_offset = 2, view_radius = 10, view_height = 4, view_acuity = 3 },
		escape = { view_offset = 2, view_radius = 10, view_height = 4, view_acuity = 3 },
	},
	certainty = 1.0,
	sensitivity = 0.6,

	fear_factor = 0,
	flee_factor = 10,
	walk_velocity = 0.8,
	stray_velocity = 1.0,
	recoil_velocity = 1.0,
	run_velocity = 1.2,
	escape_range = 3.0,
	follow_range = 2.0,
	can_jump = false,
	can_walk = true,
	enable_fall_damage = true,

	watch_wielditems = {
		["mobs:meat_raw"] = "follow",
		["mobs:meat"] = "follow",
	},
	watch_players = { },

	hunger = 5,
	hp_max = 4,
	hp_low = 3,
	armor = 100,
	light_damage = 0,
	water_damage = 4,
	lava_damage = 8,

	sounds = {
		damage_tool = "mobs_damage_tool",
		damage_hand = "mobs_damage_hand",
		random = "mobs_kitten",
		escape = "mobs_kitten_escape",
	},

	animation = {
		stand_start = 97,
		stand_end = 192,
		walk_start = 0,
		walk_end = 96,
		run_start = 0,
		run_end = 96,
		speed_normal = 42,
		speed_run = 56,
	},
	drops = {
		{ name = "mobs:meat_raw", chance = 2, min = 1, max = 1 },
	},
} ) 

mobs.register_spawn_near( "mobs:kitten", {
	nodenames = { "default:wood" },
	max_light = default.LIGHT_MAX,
	min_light = 4,
	chance = 14,
	vert_shift = 0,
	safe_edge1 = vector.new( -200, -5, -200 ),
	safe_edge2 = vector.new( 200, 50, 200 ),
	is_area_safe = true,
} )

-------------------------------------------
-- Rat (aka Ratticus Rat)
-------------------------------------------

mobs.register_mob( "mobs:rat", {
	type = "animal",
	description = "Rat",
	timeout = 120,

	mesh = "mobs_rat.b3d",
	collisionbox = { -0.2, -1, -0.2, 0.2, -0.8, 0.2 },     -- cardinal: left, bottom, back, right, top, front
	drawtype = "front",
	visual = "mesh",
	height = 1,
	y_offset = 0,
	density = 0.4,

	groups = { mob = 1, animal = 1, walks = 1, mobile = 1 },
	textures = {
		"mobs_rat2.png", "mobs_rat2.png"
	},

	makes_footstep_sound = false,
	makes_bloodshed_effect = true,

	hunger_params = { offset = 0.0, spread = 2.5 },
	alertness_states = {
		ignore = { view_offset = 0, view_radius = 3, view_height = 3, view_acuity = 4 },
		follow = { view_offset = 0, view_radius = 6, view_height = 3, view_acuity = 6 },
		escape = { view_offset = 0, view_radius = 6, view_height = 3, view_acuity = 6 },
	},
	certainty = 1.0,
	sensitivity = 0.0,

	fear_factor = 8,
	flee_factor = 10,
	walk_velocity = 0.5,
	stray_velocity = 0.5,
	recoil_velocity = 0.5,
	run_velocity = 1.2,
	escape_range = 0.0,
	follow_range = 2.0,
	can_jump = false,
	can_walk = true,
	enable_fall_damage = true,

	watch_wielditems = {
		["mobs:meat_raw"] = "follow",
		["mobs:meat"] = "follow",
	},
	watch_players = { },

	hp_max = 2,
	hp_low = 1,
	armor = 100,
	light_damage = 0,
	water_damage = 6,
	lava_damage = 8,

	sounds = {
		damage_tool = "mobs_damage_tool",
		damage_hand = "mobs_damage_hand",
	},

	drops = {
		{ name = "default:dry_grass_1", chance = 6, min = 1, max = 2 },
		{ name = "default:dry_shrub", chance = 6, min = 1, max = 2 },
	},
} ) 

mobs.register_spawn_near( "mobs:rat", {
	nodenames = { "default:furnace" },
	max_light = 8,
	min_light = 2,
	chance = 2,
	vert_shift = 0,
	safe_edge1 = vector.new( -200, -10, -200 ),
	safe_edge2 = vector.new( 200, 5, 200 ),
	is_area_safe = true,
} )

-------------------------------------------
-- Wild Hare
-------------------------------------------

mobs.register_mob( "mobs:hare", {
	type = "animal",
	description = "Wild Hare",
	timeout = 45,

	mesh = "mobs_bunny.b3d",
	collisionbox = { -0.3, -0.75, -0.3, 0.3, 0.3, 0.3 },	-- cardinal: left, bottom, back, right, top, front
	drawtype = "front",
	visual = "mesh",
	visual_size = { x = 1.5, y = 1.5 },
	height = 1,
	y_offset = 0,
	density = 0.6,

	groups = { mob = 1, animal = 1, walks = 1, jumps = 1, mobile = 1, herbivore = 1 },
	textures = { "mobs_bunny_grey.png" },

	makes_footstep_sound = false,
	makes_bloodshed_effect = true,

	hunger_params = { offset = 0.0, spread = 2.0 },
	alertness_states = {
		ignore = { view_offset = 0, view_radius = 2, view_height = 6, view_acuity = 0 },
		follow = { view_offset = 0, view_radius = 12, view_height = 6, view_acuity = 3 },
		escape = { view_offset = 0, view_radius = 12, view_height = 6, view_acuity = 3 },
	},
	certainty = 1.0,
	sensitivity = 0.5,

	fear_factor = 6,
	flee_factor = 10,
	walk_velocity = 3.0,
	stray_velocity = 1.0,
	recoil_velocity = 2.0,
	run_velocity = 3.5,
	escape_range = 3.0,
	follow_range = 3.0,
	can_jump = true,
	can_walk = true,
	enable_fall_damage = true,

	watch_wielditems = {
		["default:apple"] = "follow",
		["default:orange"] = "follow",
	},
	watch_players = { },

	hp_max = 4,
	hp_low = 3,
	armor = 100,
	light_damage = 0,
	water_damage = 2,
	lava_damage = 6,

	sounds = {
		damage_tool = "mobs_damage_tool",
		damage_hand = "mobs_damage_hand",
	},

	animation = {
		stand_start = 1,
		stand_end = 15,
		walk_start = 16,
		walk_end = 24,
		run_start = 16,
		run_end = 24,
		speed_normal = 15,
		speed_run = 25,
	},
	drops = {
	},
} ) 

mobs.register_spawn_near( "mobs:hare", {
	nodenames = { "default:dirt_with_grass" },
	max_light = default.LIGHT_MAX,
	min_light = 10,
	chance = 8,
	vert_shift = 0,
	safe_edge1 = vector.new( -200, -5, -200 ),
	safe_edge2 = vector.new( 200, 50, 200 ),
	is_area_safe = true,
} )

-------------------------------------------
-- Chicken (aka Chuck-A-Luck)
-------------------------------------------

mobs.register_mob( "mobs:chicken", {
	type = "animal",
	description = "Chicken",
	timeout = 60,

	mesh = "mobs_chicken.x",
	collisionbox = { -0.3, -1.05, -0.3, 0.3, 0.05, 0.3 },
	drawtype = "front",
	visual = "mesh",
	visual_size = { x = 1.5, y = 1.5 },
	height = 2,
	y_offset = 3,
	density = 0.4,

	groups = { mob = 1, animal = 1, walks = 1, jumps = 1, mobile = 1, herbivore = 1 },
	textures = {
		"mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png",
		"mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png",
	},

	makes_footstep_sound = true,
	makes_bloodshed_effect = true,

	hunger_params = { offset = 0.0, spread = 2.0 },
	alertness_states = {
		ignore = { view_offset = 2, view_radius = 4, view_height = 4, view_acuity = 0 },
		follow = { view_offset = 2, view_radius = 6, view_height = 4, view_acuity = 2 },
		escape = { view_offset = 2, view_radius = 6, view_height = 4, view_acuity = 2 },
	},
	certainty = 1.0,
	sensitivity = 0.3,

	fear_factor = 2,
	flee_factor = 10,
	walk_velocity = 1.5,
	stray_velocity = 1.0,
	recoil_velocity = 2.0,
	run_velocity = 2.0,
	follow_range = 3.0,
	escape_range = 3.0,
	can_jump = true,
	can_walk = true,
	enable_fall_damage = true,

	watch_wielditems = {
		["default:apple"] = "follow",
		["default:orange"] = "follow",
	},
	watch_players = { },

	hunger = 10,
	hp_max = 10,
	hp_low = 9,
	armor = 100,
	damage = 1,
	light_damage = 0,
	water_damage = 6,
	lava_damage = 6,

	animation = {
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 36,
		run_start = 37,
		run_end = 49,
		punch_start = 37,
		punch_end = 49,
		speed_normal = 15,
		speed_run = 15,
	},
	sounds = {
		random = "mobs_chicken",
		damage_tool = "mobs_damage_tool",
		damage_hand = "mobs_damage_hand",
	},
	drops = {
		{ name = "default:junglesapling", chance = 4, min = 1, max = 2 },
		{ name = "default:pine_sapling", chance = 4, min = 1, max = 2 },
		{ name = "default:acacia_sapling", chance = 6, min = 1, max = 2 },
		{ name = "default:aspen_sapling", chance = 6, min = 1, max = 2 },
	},
} ) 

mobs.register_spawn_near( "mobs:chicken", {
	nodenames = { "default:dirt", "default:sand" },
	max_light = default.LIGHT_MAX,
	min_light = 10,
	chance = 12,
	vert_shift = 0,
	safe_edge1 = vector.new( -350, -5, -350 ),
	safe_edge2 = vector.new( 350, 50, 350 ),
	is_area_safe = true,
} )
