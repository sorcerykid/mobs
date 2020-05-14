--------------------------------------------------------
-- Minetest :: Mobs Lite Mod (mobs)
--
-- See README.txt for licensing and release notes.
-- Copyright (c) 2016-2020, Leslie E. Krause
--
-- ./games/minetest_game/mods/mobs/monsters.lua
--------------------------------------------------------

-------------------------------------------
-- Ghastly the Ghost
-------------------------------------------

mobs.register_mob( "mobs:ghost", {
	type = "monster",
	description = "Ghastly the Ghost",
	timeout = 45,

	mesh = "mobs_ghost.b3d",
	collisionbox = { -0.25, 0, -0.3, 0.25, 1.3, 0.3 },     -- cardinal: left, bottom, back, right, top, front
	drawtype = "front",
	visual = "mesh",
	visual_size = { x = 1, y = 1 },
	height = 2,
	y_offset = 0,
	density = 0.5,
	gravity = -0.1,

	groups = { mob = 1, monster = 1, flies = 1, jumps = 1, mobile = 1 },
	textures = { "mobs_ghost.png" },
	makes_footstep_sound = false,
	makes_bloodshed_effect = false,

	hunger_params = { offset = -0.1, spread = 3.0 },
	alertness_states = {
		ignore = { view_offset = 2, view_radius = 8, view_height = 8, view_acuity = 0 },
		search = { view_offset = 2, view_radius = 14, view_height = 8, view_acuity = 3, view_filter =  function ( self, obj, clarity )
			return clarity == 0.0 and "search" or "attack"
		end },
		attack = { view_offset = 2, view_radius = 14, view_height = 8, view_acuity = 3 , view_filter =  function ( self, obj, clarity )
			return clarity == 0.0 and "search" or "attack"
		end },
		escape = { view_offset = 2, view_radius = 14, view_height = 8, view_acuity = 3 },
	},
	awareness_stages = {
		attack = { decay = 15.0, abort_state = "ignore" },
		escape = { decay = 10.0, abort_state = "ignore" },
	},

	certainty = 1.0,
	sensitivity = 0.2,

	fear_factor = 8,
	flee_factor = 10,
	attack_type = "melee",
	standoff = 4.0,
	attack_range = 6.0,
	search_range = 2.5,
	escape_range = 2.5,
	sneak_velocity = 0.5,
	walk_velocity = 0.5,
	recoil_velocity = 1.5,
	run_velocity = 1.5,
	stray_velocity = 1.5,
	can_jump = true,
	can_fly = true,
	can_walk = false,

	watch_players = { },

	hunger = 5,
	hp_max = 10,
	hp_low = 9,
	damage = 2,
	armor = 100,
	light_damage = 10,
	water_damage = 0,
	lava_damage = 0,

	sounds = {
		random = "mobs_ghost",
		attack = "mobs_ghost",
	},

	animation = {
		stand_start = 0,
		stand_end = 80,
		walk_start = 102,
		walk_end = 122,
		run_start = 102,
		run_end = 122,
		punch_start = 102,
		punch_end = 122,
		speed_normal = 10,
		speed_run = 25,
	},
	drops = {
		{ name = "default:coal_lump", chance = 2, min = 1, max = 4 },
	},
} ) 

mobs.register_spawn( "mobs:ghost", {
	nodenames = { "default:gravel" },
	max_light = 3,
	min_light = 0,
	chance = 15,
	max_object_count = 1,
	max_height = 0,
	min_height = -1023,
} )

-------------------------------------------
-- Spider (aka Spidey)
-------------------------------------------

mobs.register_mob( "mobs:spider", {
	type = "monster",
	description = "Spider",
	timeout = 60,

	mesh = "mobs_spider.x",
	collisionbox = { -0.7, -0.01, -0.7, 0.7, 0.6, 0.7 },
	drawtype = "front",
	visual = "mesh",
	visual_size = { x = 5, y = 5 },
	height = 1,
	y_offset = 0,
	density = 0.3,

	groups = { mob = 1, monster = 1, walks = 1, jumps = 1, mobile = 1 },
	textures = { "mobs_spider.png" },
	makes_footstep_sound = false,
	makes_bloodshed_effect = true,

	gibbage_params = {
		pieces = { "teeny", "teeny", "teeny" },
		sound = "mobs_gib_chunky",
		damage_groups = { blast_stim = 3 },
		textures = { "mobs_spider_gib.png" }
	},

	gibbage_params = {
		pieces = { "teeny", "teeny" },
		sound = "mobs_gib_chunky",
		damage_groups = { blast_stim = 3 },
		textures = { "mobs_paniki_gib.png" }
	},

	hunger_params = { offset = 0.3, spread = 4.0 },
	alertness_states = {
		ignore = { view_offset = 6, view_radius = 6, view_height = 6, view_acuity = 3 },
		search = { view_offset = 6, view_radius = 12, view_height = 6, view_acuity = 5, view_filter =  function ( self, obj, clarity )
			return clarity == 0.0 and "search" or "attack"
		end },
		attack = { view_offset = 6, view_radius = 12, view_height = 6, view_acuity = 5, view_filter =  function ( self, obj, clarity )
			return clarity == 0.0 and "search" or "attack"
		end },
		escape = { view_offset = 6, view_radius = 12, view_height = 6, view_acuity = 5 },
	},
	awareness_stages = {
		search = { decay = 18.0, abort_state = "ignore" },
		attack = { decay = 0.0, abort_state = "search" },
		escape = { decay = 18.0, abort_state = "ignore" },
	},

	certainty = 1.0,
	sensitivity = 0.2,

	fear_factor = 10,
	flee_factor = 8,
	attack_type = "melee",
	attack_range = 3.0,
	search_range = 3.0,
	escape_range = 3.0,
	sneak_velocity = 0.5,
	walk_velocity = 1.0,
	stray_velocity = 1.0,
	recoil_velocity = 0.5,
	run_velocity = 3.0,
	can_walk = true,
	can_jump = true,

	watch_players = { },

	hunger = 6,
	hp_max = 16,
	hp_low = 4,
	armor = 80,
	damage = 4,
	light_damage = 2,
	water_damage = 2,
	lava_damage = 6,

	animation = {
		stand_start = 1,
		stand_end = 1,
		walk_start = 20,
		walk_end = 40,
		run_start = 20,
		run_end = 40,
		punch_start = 50,
		punch_end = 90,
		speed_normal = 15,
		speed_run = 30,
	},
	sounds = {
		random = "mobs_spider",
		attack = "mobs_spider",
		damage_tool = "mobs_damage_tool",
		damage_hand = "mobs_damage_hand",
	},
	drops = {
		{ name = "farming:blueberries", chance = 6, min = 1, max = 2 },
		{ name = "farming:raspberries", chance = 6, min = 1, max = 2 },
		{ name = "default:grass_1", chance = 8, min = 1, max = 2 },
		{ name = "default:shrub", chance = 8, min = 1, max = 2 },
	},
	on_rightclick = nil,
} ) 

mobs.register_spawn( "mobs:spider", {
	nodenames = { "default:cobble" },
	max_light = 3,
	min_light = 0,
	chance = 200, 
	max_object_count = 1,
	max_height = 0,
	min_height = -31,
} )

-------------------------------------------
-- Bat (aka Paniki)
-------------------------------------------

mobs.register_mob( "mobs:bat", {
	type = "monster",
	description = "Bat",
	timeout = 30,

	mesh = "mobs_paniki.b3d",  --paniki from minetest defense
	collisionbox = { -0.4, -0.2, -0.4, 0.4, 0.6, 0.4 },
	drawtype = "side",
	visual = "mesh",
	visual_size = { x = 1.2, y = 1.2 },
	height = 1,
	y_offset = 0,
	gravity = -0.1,
	density = 0.3,

	groups = { mob = 1, monster = 1, flies = 1, jumps = 1, mobile = 1 },
	textures = { "mobs_paniki.png" },  --paniki from minetest defense
	makes_footstep_sound = false,
	makes_bloodshed_effect = true,

	hunger_params = { offset = 1.0, spread = 1.0 },
	alertness_states = {
		ignore = { view_offset = 10, view_radius = 15, view_height = 15, view_acuity = 3 },
		search = { view_offset = 10, view_radius = 20, view_height = 15, view_acuity = 5, view_filter =  function ( self, obj, clarity )
			return clarity == 0.0 and "search" or "attack"
		end },
		attack = { view_offset = 10, view_radius = 20, view_height = 15, view_acuity = 5, view_filter =  function ( self, obj, clarity )
			return clarity == 0.0 and "search" or "attack"
		end },
		escape = { view_offset = 10, view_radius = 20, view_height = 15, view_acuity = 3 },
	},
	awareness_stages = {
		search = { decay = 14.0, abort_state = "ignore" },
		attack = { decay = 0.0, abort_state = "search" },
		escape = { decay = 14.0, abort_state = "ignore" },
	},

	certainty = 1.0,
	sensitivity = 0.3,

	fear_factor = 8,
	flee_factor = 6,
	attack_type = "melee",
	attack_range = 3.0,
	search_range = 5.0,
	escape_range = 5.0,
	sneak_velocity = 1.0,
	walk_velocity = 1.0,
	stray_velocity = 0.5,
	recoil_velocity = 0.5,
	run_velocity = 2.0,
	can_jump = true,
	can_fly = true,
	can_walk = false,

	watch_players = { },

	hunger = 6,
	hp_max = 8,
	hp_low = 2,
	armor = 100,
	damage = 2,
	light_damage = 2,
	water_damage = 6,
	lava_damage = 6,

	animation = {
		stand_start = 30,
		stand_end = 59,
		walk_start = 30,
		walk_end = 59,
		run_start = 60,
		run_end = 89,
		punch_start = 60,
		punch_end = 89,
		speed_normal = 30,
		speed_run = 30,
	},
	sounds = {
		random = "mobs_bat",
		attack = "mobs_bat",
		damage_tool = "mobs_damage_tool",
		damage_hand = "mobs_damage_hand",
	},
	drops = {
		{ name = "default:apple", chance = 4, min = 1, max = 2 },
		{ name = "default:orange", chance = 4, min = 1, max = 2 },
	},
} )

mobs.register_spawn_near( "mobs:bat", {
	nodenames = { "default:leaves" },
	max_light = 3,
	min_light = 0,
	chance = 8,
	vert_shift = 0,
	safe_edge1 = vector.new( -350, -5, -350 ),
	safe_edge2 = vector.new( 350, 50, 350 ),
	is_area_safe = true,
} )

-------------------------------------------
-- Oerrki (aka Okie)
-------------------------------------------

mobs.register_mob( "mobs:griefer_ghost", {
	type = "monster",
	description = "Oerrki",
	timeout = 60,

	mesh = "mobs_oerkki.x",
	collisionbox = { -0.4, -0.01, -0.4, 0.4, 1.9, 0.4 },
	drawtype = "front",
	visual = "mesh",
	visual_size = { x = 5, y = 5 },
	height = 2,
	y_offset = 0,
	density = 0.5,
	
	groups = { mob = 1, monster = 1, walks = 1, jumps = 1, mobile = 1 },
	textures = { "mobs_oerkki.png" },
	makes_footstep_sound = true,
	makes_bloodshed_effect = false,

	hunger_params = { offset = 0.3, spread = 6.0 },
	alertness_states = {
		ignore = { view_offset = 5, view_radius = 10, view_height = 8, view_acuity = 2 },
		search = { view_offset = 5, view_radius = 20, view_height = 8, view_acuity = 2, view_filter =  function ( self, obj, clarity )
			return clarity == 0.0 and "search" or "attack"
		end },
		attack = { view_offset = 5, view_radius = 20, view_height = 8, view_acuity = 2, view_filter =  function ( self, obj, clarity )
			return clarity == 0.0 and "search" or "attack"
		end },
		escape = { view_offset = 5, view_radius = 20, view_height = 8, view_acuity = 2 },
	},
	awareness_stages = {
		search = { decay = 8.0, abort_state = "ignore" },
		attack = { decay = 25.0, abort_state = "search" },
		escape = { decay = 8.0, abort_state = "ignore" },
	},

	certainty = 1.0,
	sensitivity = 0.6,

	fear_factor = 4,
	flee_factor = 10,
	attack_type = "melee",
	attack_range = 3.0,
	search_range = 4.0,
	escape_range = 4.0,
	sneak_velocity = 0.5,
	walk_velocity = 1.0,
	stray_velocity = 1.0,
	recoil_velocity = 0.5,
	run_velocity = 3.0,
	can_jump = true,
	can_walk = true,

	watch_players = { },

	hunger = 2,
	hp_max = 12,
	hp_low = 4,
	armor = 80,
	damage = 2,
	light_damage = 6,
	water_damage = 2,
	lava_damage = 2,

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
		random = "mobs_oerkki",
		attack = "mobs_oerkki",
	},
	drops = {
		{ name = "default:papyrus", chance = 6, min = 1, max = 2 },
		{ name = "default:cactus", chance = 6, min = 1, max = 2 },
		{ name = "farming:pumpkin_slice", chance = 8, min = 1, max = 2 },
		{ name = "farming:melon_slice", chance = 8, min = 1, max = 2 },
	},
} )

mobs.register_spawn( "mobs:griefer_ghost", {
	nodenames = { "default:stone" },
	max_light = 3,
	min_light = 0,
	chance = 12000,
	max_object_count = 1,
	max_height = -512,
	min_height = -1023
} )

------------------

mobs.register_spawner_node( "mobs:cursed_stone", {
	description = "Cursed Stone",
	tiles = {
		"mobs_cursed_stone_top.png",
		"mobs_cursed_stone_bottom.png",
		"mobs_cursed_stone.png",
		"mobs_cursed_stone.png",
		"mobs_cursed_stone.png",
		"mobs_cursed_stone.png"
	},
	is_ground_content = false,
	groups = { cracky = 1, level = 2 },
	drop = "default:goldblock",
	sounds = default.node_sound_stone_defaults( ),
	chance = 6,
	min_light = 0,
	max_light = 3,
	mob_name = "mobs:griefer_ghost",
} )

minetest.register_craft( {
	output = "mobs:cursed_stone",
	recipe = {
		{ "default:obsidian", "default:obsidian", "default:obsidian" },
		{ "default:obsidian", "default:goldblock", "default:obsidian" },
		{ "default:obsidian", "default:obsidian", "default:obsidian" },
	}
} )
