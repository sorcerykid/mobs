--------------------------------------------------------
-- Minetest :: Mobs Lite Mod (mobs)
--
-- See README.txt for licensing and release notes.
-- Copyright (c) 2016-2020, Leslie E. Krause
--
-- ./games/minetest_game/mods/mobs/weapons.lua
--------------------------------------------------------

mobs.register_projectile( "mobs:fireball", {
	visual = "sprite",
	visual_size = { x = 1.0, y = 1.0 },
	textures = { "mobs_fireball.png" },
	gravity = 0.0,
	trail_effect = {
		period = 0.2,
		amount = 8,
		expiry = 1.5,
		speed = -2.0,
		angle = 0.0,
		vel_y = 0.0,
		acc_y = 3.5,
		texture = "tnt_smoke.png",
		size = 2.0,
	},
	sounds = { launch = "tnt_ignite", impact = "tnt_explode", submerge = "" },
	timeout = 12.0,

	on_impact = function( self, pos, old_vel, obj )
		obj:punch( self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = { fleshy = 8 },
		}, nil )
	end,

	on_impact_nodes = function( self, pos )
		minetest.add_particlespawner( {
			amount = 200,
			time = 0.1,
			minpos = pos,
			maxpos = pos,
			minvel = { x = -4, y= 0, z = -4 },
			maxvel = { x = 4, y = 4, z = 4 },
			minacc = { x = 0, y = 0, z = 0 },
			maxacc = { x = 0, y = 0, z = 0 },
			minexptime = 0.6,
			maxexptime = 0.6,
			minsize = 1,
			maxsize = 3,
			collisiondetection = false,
			vertical = false,
			texture = "tnt_smoke.png",
		} )
--		mobs:explosion( pos, 1, 1, 0 )
	end
} )
