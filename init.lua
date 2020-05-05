--------------------------------------------------------
-- Minetest :: Mobs Lite Mod (mobs)
--
-- See README.txt for licensing and release notes.
-- Copyright (c) 2016-2020, Leslie E. Krause
--
-- ./games/minetest_game/mods/mobs/init.lua
--------------------------------------------------------

mobs = { }

local registry = {
	players = { },
	avatars = { },
	spawnitems = { },
}

world_gravity = -10
liquid_density = 0.5
liquid_viscosity = 0.6

--------------------

local random = math.random
local floor = math.floor
local min = math.min
local max = math.max
local sqrt = math.sqrt
local pow = math.pow
local abs = math.abs
local pi = math.pi
local atan2 = math.atan2
local sin = math.sin
local cos = math.cos

local rad_360 = 2 * pi
local rad_180 = pi
local rad_90 = pi / 2
local rad_60 = pi / 3
local rad_45 = pi / 4
local rad_30 = pi / 6
local rad_20 = pi / 9
local rad_0 = 0

--------------------

local function Timekeeper( this )
	local timer_defs = { }
	local clock = 0.0
	local delay = 0.0
	local self = { }

	self.shift = function ( dtime )
		delay = delay + dtime
	end

	self.unshift = function ( )
		delay = 0.0
	end

	self.start = function ( period, name, func )
		timer_defs[ name ] = { cycles = 0, period = period, expiry = clock + delay + period, started = clock, func = func }
	end

	self.start_now = function ( period, name, func )
		if func( this, 0, period, 0.0, 0.0 ) then
			timer_defs[ name ] = { cycles = 0, period = period, expiry = clock + period, started = clock, func = func }
		end
	end

	self.clear = function ( name )
		timer_defs[ name ] = nil
	end

	self.on_step = function ( dtime )
		clock = clock + dtime

		local timers = { }
		for k, v in pairs( timer_defs ) do
			if clock >= v.expiry and clock > v.started then
				timer_defs[ k ].expiry = clock + v.period
				timer_defs[ k ].cycles = v.cycles + 1
				-- callback( this, cycles, period, elapsed, overrun )
				if v.func and v.func( this, v.cycles, v.period, clock - v.started, clock - v.expiry ) then
					self.clear( k )
				end
				timers[ k ] = v
			end
		end
		return timers
	end

	return self
end

--------------------

mobs.effect( pos, amount, texture, min_size, max_size, radius, gravity )
	minetest.add_particlespawner({
		amount = amount,
		time = 0.5,
		minpos = { x = pos.x, y = pos.y, z = pos.z },
		maxpos = { x = pos.x, y = pos.y + 1.5, z = pos.z },
		minvel = {x = -radius, y = -radius, z = -radius},
		maxvel = {x = radius, y = radius, z = radius},
		minacc = {x = 0, y = gravity, z = 0},
		maxacc = {x = 0, y = gravity, z = 0},
		minexptime = 0.1,
		maxexptime = 1,
		minsize = min_size,
		maxsize = max_size,
		texture = texture,
	})
end

local function smoke_effect( pos )
	mobs.effect( pos, 8, "tnt_smoke.png", 1.4, 1.6, 2, 0 )
end

local function blood_effect( pos )
	mobs.effect( pos, 4, "mobs_blood.png", 1.2, 1.4, 2, -10 )
end

--------------------

local function node_locator( pos, size, time, color )
	if is_debug then
		minetest.add_particle( {
			pos = pos,
			velocity = { x=0, y=0, z=0 },
			acceleration = { x=0, y=0, z=0 },
			exptime = time + 4,
			size = size,
			collisiondetection = false,
			vertical = true,
			texture = "wool_" .. color .. ".png",
		})
	end
end

local function printf( ... )
	print( string.format( ... ) )
end

--------------------

local function normalize_angle( r )
	-- stackoverflow.com/questions/1878907/the-smallest-difference-between-2-angles
	return atan2( sin( r ), cos( r ) )
end

local function get_vector_angle( p1, p2 )
	return atan2( p2.z - p1.z, p2.x - p1.x )
end

local function get_vector_height( p1, p2 )      -- get altitude from p1 to p2
	return abs( p2.y - p1.y )
end

local function get_vector_length( p1, p2 )      -- get distance from p1 to p2
	return sqrt( pow( p2.x - p1.x, 2 ) + pow( p2.z - p1.z, 2 ) )
end

local function get_vector_incline( p1, p2 )
	local h = get_vector_length( p1, p2 )
	local v = p2.y - p1.y
	return v / h
end

local function ramp( f, cur_v, max_v )
	-- min function handles NaN, but let's err on the side of caution
	return max_v == 0 and f or f * min( 1, cur_v / max_v )
end

local function sign( v )
	return random( 2 ) == 1 and v or -v
end

local function lower_random( v_limit, v_ratio )
	return sign( v_ratio * random( ) * v_limit )
end

local function upper_random( v_limit, v_ratio )
	return sign( v_limit - v_ratio * random( ) * v_limit )
end

local function get_power_decrease( scale, power, value )
	return value <= 1 - scale and 1.0 or
		max( 1 - pow( ( scale + value - 1 ) / scale, 1 + power ), 0 )
end

local function get_power_increase( scale, power, value )
	return value >= scale and 1.0 or
		1 - math.pow( ( scale - value ) / scale, 1 + power )
end

local function check_limits( v, min_v, max_v )
	return v >= min_v and v <= max_v
end

local function random_range( min_v, max_v )
	return random( min_v * 100, max_v * 100 ) / 100
end

--------------------

minetest.register_on_leaveplayer( function( player, is_timeout )
	local name = player:get_player_name( )

	-- delete all target references (if applicable)
	for id, this in pairs( registry.avatars ) do
		if this.target == player then
			this:reset_target( )
		end
	end
	registry.players[ name ] = nil
end )

minetest.register_on_joinplayer( function( player )
	local name = player:get_player_name( )
	registry.players[ name ] = player
end )

--------------------

local builtin_item = minetest.registered_entities[ "__builtin:item" ]

builtin_item.old_on_activate = builtin_item.on_activate
builtin_item.old_set_item = builtin_item.set_item

builtin_item.set_item = function ( self, itemstring )
	self:old_set_item( itemstring )
	self.item_name = ItemStack( self.itemstring ):get_name( )
end

builtin_item.on_activate = function ( self, staticdata, dtime, id )
	self:old_on_activate( staticdata, dtime )
	registry.spawnitems[ id ] = self.object
end

builtin_item.on_deactivate = function ( self, id )
	for id, this in pairs( registry.avatars ) do
		if this.target == self.object then
			this:reset_target( )
		end
	end
	registry.spawnitems[ id ] = nil
end

--------------------

local globaltimer = Timekeeper( { } )

minetest.register_globalstep( function ( dtime )
	globaltimer.on_step( dtime )
end )

--------------------

mobs.register_mob = function ( name, def )
	minetest.register_entity( name, {
		type = def.type,
		hp_max = def.hp_max,
		hp_low = def.hp_low,
		physical = true,
		mesh = def.mesh,
		collisionbox = def.collisionbox,
		visual = def.visual,
		visual_size = def.visual_size,
		height = def.height,
		y_offset = def.y_offset,
		gravity = def.gravity or world_gravity,
		density = def.density or 0.5,
		textures = def.textures,
		makes_footstep_sound = def.makes_footstep_sound,
		makes_bloodshed_effect = def.makes_bloodshed_effect,
		death_message = def.death_message,
		alertness_states = def.alertness_states,
		sensitivity = def.sensitivity or 0.0,
		certainty = def.certainty or 1.0,
		attack_range = def.attack_range,
		escape_range = def.escape_range,
		follow_range = def.follow_range,
		pickup_range = def.pickup_range,
		sneak_velocity = def.sneak_velocity,
		walk_velocity = def.walk_velocity,
		run_velocity = def.run_velocity,
		stray_velocity = def.stray_velocity,
		recoil_velocity = def.recoil_velocity,
		standoff = def.standoff or 5,
		damage = def.damage,
		light_damage = def.light_damage or 0,
		water_damage = def.water_damage or 0,
		lava_damage = def.lava_damage or 0,
		enable_fall_damage = def.enable_fall_damage,
		drops = def.drops,
		armor = def.armor,
		yaw_origin = def.drawtype == "front" and 0 or -rad_90,
		drawtype = def.drawtype,
		on_rightclick = def.on_rightclick,
		attack_type = def.attack_type,
		projectile = def.projectile,
		shoot_period = def.shoot_period,
		shoot_chance = def.shoot_chance,
		weapon_params = def.weapon_params,
		watch_wielditems = def.watch_wielditems,
		watch_spawnitems = def.watch_spawnitems,
		watch_players = def.watch_players,
		sounds = def.sounds,
		animation = def.animation,
		fear_factor = def.fear_factor,
		flee_factor = def.flee_factor,
		can_jump = def.can_jump or false,
		can_fly = def.can_fly or false,
		can_walk = def.can_walk or false,
		enable_climbing = true,
		enable_swimming = true,
		shoot_count = 0,
		timeout = def.timeout,
		is_tamed = false,
		description = def.description,
		custom = def.custom or { },

		-- prepare noise generator with seed, octaves, persistence, spread
		hunger_noise = PerlinNoise( random( 1000 ), 1, 0, def.hunger_params.spread ),
		hunger_offset = def.hunger_params.offset,

		-- primitive movement functions --

		set_speed = function( self, speed )
			self.speed = speed
			self.object:set_speed( speed )
		end,

		set_speed_lateral = function( self, speed_x, speed_y )
			self.speed = speed_y
			self.object:set_speed_lateral( speed_x, speed_y )
		end,

		set_velocity_vert = function ( self, vel_y )
			self.object:set_velocity_vert( vel_y )
			self.object:set_acceleration_vert( self.gravity )
		end,

		set_acceleration_vert = function ( self, acc_y )
			self.object:set_acceleration_vert( acc_y )
		end,

		set_yaw = function ( self, yaw )
			self.object:set_yaw( yaw )
		end,

		turn_to = function ( self, yaw, period )
			local yaw_delta = normalize_angle( yaw - self.yaw )
			self.object:turn_by( yaw_delta, period / 10 )
		end,

		turn_by = function ( self, yaw_delta, period )
			self.object:turn_by( yaw_delta, period / 10 )
		end,

		move_by = function ( self, pos_delta, period )
			self.object:move_by( pos_delta, period / 10 )
		end,

		get_random_yaw = function ( self, r_limit, r_ratio )
			return self.yaw + upper_random( r_limit, r_ratio or 1 )
		end,

		get_direct_yaw = function ( self, pos )
			-- convert to world coordinate system
			return get_vector_angle( self.pos, pos ) - rad_90 - self.yaw_origin
		end,

		get_target_yaw = function ( self, pos, r_limit, r_ratio )
			return self:get_direct_yaw( pos ) + upper_random( r_limit, r_ratio or 1 )
		end,

		get_target_yaw_delta = function ( self, pos )
			local yaw = self:get_direct_yaw( pos )
			return abs( normalize_angle( yaw - self.yaw ) )
		end,

		-- collision processing --

		get_pos_ahead = function ( self, outset, angle )
			-- convert from world coordinate system
			local rot = angle + self.yaw_origin
			return vector.round( {
				x = self.pos.x - sin( self.yaw + rot ) * ( self.collisionbox[ 4 ] + outset ),
				y = self.pos.y,
				z = self.pos.z + cos( self.yaw + rot ) * ( self.collisionbox[ 4 ] + outset )
			} )
		end,

		can_walk_ahead = function ( self, outset, angle )
			local fpos = self:get_pos_ahead( outset, angle )
			local unknown_ndef = { groups = { }, walkable = false }

			if self.height < 2 then
				local node = minetest.get_node( fpos )
				local ndef = core.registered_nodes[ node.name ] or unknown_ndef     -- account for unknown nodes
				local is_airlike = not ndef.walkable

				--node_locator( vector.offset_y( fpos ), 4.5, 1.0, is_airlike and "green" or angle == 0 and "white" or "red" )
				return is_airlike
			else
				local node_below = minetest.get_node( fpos )
				local node_above = minetest.get_node_above( fpos )
				local ndef_below = core.registered_nodes[ node_below.name ] or unknown_ndef     -- account for unknown nodes
				local ndef_above = core.registered_nodes[ node_above.name ] or unknown_ndef
				local is_airlike = not ndef_below.walkable and not ndef_above.walkable

				--node_locator( vector.offset_y( fpos ), 4.5, 1.0, is_airlike and "green" or angle == 0 and "white" or "red" )
				return is_airlike
			end
		end,			

		-- sensory processing --

		check_suspect = function ( self, target, elapsed )
			local entity = target:get_luaentity( )
			local suspect

			if not entity then
				local player_name = target:get_player_name( )
				local item_name = target:get_wielded_item( ):get_name( )
				suspect = self.watch_players[ player_name ] or self.watch_wielditems[ item_name ]
			elseif entity.name == "__builtin:item" then
				suspect = self.watch_spawnitems[ entity.item_name ]
			end

			if type( suspect ) == "function" then
				return suspect( self, target, elapsed or 0.0 )
			else
				return suspect
			end
		end,

		is_paranoid = function ( self, target_pos )
			local length = get_vector_length( self.pos, target_pos )
			local this = self.alertness

			if not this or length > 48 then
				return false
			else
				local view_range = this.view_radius + this.view_offset
				local view_pos = this.view_offset == 0.0 and self.pos or vector.new(
					self.pos.x - sin( self.yaw + self.yaw_origin ) * this.view_offset,
					self.pos.y,
					self.pos.z + cos( self.yaw + self.yaw_origin ) * this.view_offset
				)

				local radius = get_vector_length( view_pos, target_pos )
				local height = get_vector_height( view_pos, target_pos )
				local clarity = get_power_decrease( 1.0, this.view_acuity, length / view_range )

				-- certainty factor ranges from 0 (target never evident) to 1 (target always evident)
				-- sensitivity threshold ranges from 0 (full perception) to 1 (no perception)

				--node_locator( vector.offset_y( view_pos ), 4.5, 1.0, "yellow" )
				--printf( "is_paranoid(%s):\n[%s] radius <= view_radius\n[%s] height <= view_height\n%0.2f = clarity (%0.2f = sensitivity, %0.2f = certainty)", self.name, radius <= this.view_radius and "x" or " ", height <= this.view_height and "x" or " ", clarity, self.sensitivity, self.certainty )

				return radius <= this.view_radius and height <= this.view_height and
					clarity > self.sensitivity and clarity * self.certainty > random( )
			end
		end,

		-- utility functions --

		is_starving = function ( self )
			local hunger = self.hunger_noise:get2d( { x = self.timeout, y = 0 } )

			-- offset of -1 is never hungry, offset of 1 is always hungry
			return hunger > -self.hunger_offset
		end,

		iterate_registry = function ( self, radius, height, classes )
			local length = radius * radius
			local class_idx = 1
			local key

			local function is_inside_area( obj )
				-- perform fast length-squared distance check
				local target_pos = obj:get_pos( )
				local a = self.pos.x - target_pos.x
				local b = self.pos.z - target_pos.z

				return a * a + b * b < length
			end

			return function ( )
				while classes[ class_idx ] do
					local obj

					key, obj = next( classes[ class_idx ], key )
					if obj then
						if obj:get_hp( ) > 0 and is_inside_area( obj ) then
							return obj
						end
					else
						class_idx = class_idx + 1
						key = nil
					end
				end

				return nil
			end
		end,

		fire_weapon = function ( self, target_pos )
			local params = self.weapon_params

			if self.shoot_count <= params.rounds then
				local launch_pos = vector.offset_y( self.pos,
					( self.collisionbox[ 2 ] + self.collisionbox[ 5 ] ) / 2 )
				local obj = minetest.add_entity( launch_pos, params.bullet )
				obj:get_luaentity( ):launch(
					self.yaw, params.speed, get_vector_incline( launch_pos, target_pos ) )			

				self.shoot_count = self.shoot_count + 1
			end
		end,

		-- state-change handlers --

		reset_target = function ( self )
			if self.target then
				self:set_ignore_state( )
			end
		end,

		set_ignore_state = function ( self )
			if self.state == "ignore" then return end

			self.state = "ignore"
			self.target = nil
			self.alertness = self.alertness_states.ignore
			self.is_tamed = false

			if self.custom.after_state_change then
				self.custom.after_state_change( self )
			end

			self:start_ignore_action( )
		end,

		set_escape_state = function ( self, target )
			if self.state == "escape" then return end
			self.state = "escape"
			self.target = target
			self.alertness = self.alertness_states.escape
			self.is_tamed = false

			if random( 2 ) == 1 then
				-- this is a bad player, so keep watch
				self.watch_players[ target:get_player_name( ) ] = "escape"
			end

			if self.custom.after_state_change then
				self.custom.after_state_change( self )
			end

			self:start_escape_action( )
		end,

		set_follow_state = function ( self, target )
			if self.state == "follow" then return end
			self.state = "follow"
			self.target = target
			self.alertness = self.alertness_states.follow
			self.is_tamed = true

			if self.custom.after_state_change then
				self.custom.after_state_change( self )
			end

			self:start_follow_action( )
		end,

		set_attack_state = function ( self, target )
			if self.state == "attack" then return end
			self.state = "attack"
			self.target = target
			self.alertness = self.alertness_states.attack
			self.is_tamed = false

			if self.custom.after_state_change then
				self.custom.after_state_change( self )
			end

			self:start_attack_action( )
		end,

		-- action hooks --

		start_ignore_action = function ( self )
			if not self.move_result.is_standing then
				-- always stand when in mid-air
				self:set_speed( 0 )
				self:set_animation( self.can_fly and "swim" or "stand" )
			elseif self:is_starving( ) then
				self:set_speed( self.walk_velocity )
				self:set_animation( "walk" )
			else
				self:set_speed( 0 )
				self:set_animation( "stand" )
			end

			self.timekeeper.start( 1.0, "hunger", self.handle_hunger )
			self.timekeeper.start( 1.0, "action", self.on_ignore_action )
		end,

		on_ignore_action = function ( self, cycles )
			-- handle standing and walking motion
			if self.speed == 0 then
				if random( 3 ) == 1 then
					-- turn randomly, because we're bored
					self:turn_to( self:get_random_yaw( rad_180 ), random( 2 ) == 1 and 10 or 20 )
				end

				-- don't stand still when hungry
				if self:is_starving( ) then
					if self.can_fly and random( 2 ) == 1 then
						self:set_speed( self.run_velocity )
						self:set_velocity_vert( self.run_velocity )
						self:set_animation( "swim" )
					else
						self:set_speed( self.walk_velocity )
						self:set_animation( "walk" )
					end

				elseif self.can_walk and self.move_result.is_standing then
					self:set_animation( "stand" )

				elseif self.can_fly then
					local is_above = minetest.line_of_sight( self.pos,
						{ x = self.pos.x, y = self.pos.y - self.standoff, z = self.pos.z }, 1 )

					if self.can_walk then
						-- slowly descend until reaching ground
						self.object:set_velocity_vert( -self.walk_velocity )
					elseif is_above then
						self.object:set_velocity_vert( random_range( -self.sneak_velocity, 0 ) )
					else
						self.object:set_velocity_vert( random_range( 0, self.sneak_velocity ) )
					end
					self:set_animation( "swim" )
				end

			else
				if not self:can_walk_ahead( 1.0, 0 ) then
					if self:can_walk_ahead( 0.8, rad_90 ) then
						self:turn_by( rad_60, 5 )
					elseif self:can_walk_ahead( 0.8, -rad_90 ) then
						self:turn_by( -rad_60, 5 )
					else
						self:turn_by( rad_180, 20 )
					end

				elseif random( 3 ) == 1 then
					-- otherwise occasionally change direction
					self:turn_to( self:get_random_yaw( rad_60 ), 20 )
				end


				if self.move_result.is_standing then
					if self.can_jump and random( 10 ) == 1 then
						-- random jump
						self.object:set_velocity_vert( 5 )
					end

					if not self:is_starving( ) then
						self:set_speed( 0 )
						self:set_animation( "stand" )
					else
						self:set_animation( "walk" )
					end

				elseif self.can_fly then
					-- random vertical flight pattern, keeping clear of ground obstacles
					local is_above = minetest.line_of_sight( self.pos,
						{ x = self.pos.x, y = self.pos.y - self.standoff, z = self.pos.z }, 1 )

					if not self:is_starving( ) then
						self:set_speed( 0 )
						self.object:set_velocity_vert( is_above and -self.walk_velocity )
					elseif is_above then
						self.object:set_velocity_vert( random_range( -self.sneak_velocity, self.sneak_velocity ) )
					else
						self.object:set_velocity_vert( self.walk_velocity )
					end

					self:set_animation( "swim" )
				end
			end
		end,

		start_escape_action = function ( self )
			local target_pos = vector.offset_y( self.target:get_pos( ) )
			local dist = vector.distance( self.pos, target_pos )

			if self:get_target_yaw_delta( target_pos ) < rad_60 and dist <= self.escape_range then
				-- recoil if facing intruder
				self:set_speed( -self.recoil_velocity )
			else
				-- otherwise run in current direction
				self:set_speed( self.run_velocity )
			end
			if self.can_fly then
				self:set_velocity_vert( self.walk_velocity )
				self:set_animation( "swim" )
			else
				self:set_animation( "walk" )
			end

			if self.sounds and self.sounds.escape and random( 2 ) == 1  then
				minetest.sound_play( self.sounds.escape, { object = self.object } )
			end

			self.timekeeper.clear( "hunger" )
			self.timekeeper.start( 0.5, "action", self.on_escape_action )
		end,

		on_escape_action = function ( self, cycles )
			if not self.target:is_player( ) then  -- check for valid target
				self:set_ignore_state( )
				return
			end

			local target_pos = vector.offset_y( self.target:get_pos( ), 0.5 )
			local dist = vector.distance( self.pos, target_pos )

			if cycles % 2 == 0 then
				if not self:is_paranoid( target_pos ) or random( 10 ) > self.flee_factor then
					self:set_ignore_state( )
					return
				end
			end

			if dist <= self.escape_range then
				-- if close, keep backtracking
				if cycles % 2 == 0 then
					-- turn every 1.0 seconds (2 cycles)
					self:turn_to( self:get_target_yaw( target_pos, rad_20 ), 10 )
				end
				if self.speed > 0 then
					self:set_speed( -self.recoil_velocity )
					self:set_animation( self.can_fly and "swim" or "walk" )
				end
			else
				-- otherwise turn and run away
				if cycles % 4 == 0 and self:get_target_yaw_delta( target_pos ) < rad_60 then
					-- turn immediately if facing target
					self:turn_to( self:get_target_yaw( target_pos, rad_60 ) + rad_180, 20 )
				elseif cycles % 2 == 0 then
					-- otherwise turn every 1.0 seconds (2 cycles)
					self:turn_to( self:get_target_yaw( target_pos, rad_30 ) + rad_180, 10 )
				end
				if self.speed <= 0 then
					self:set_speed( self.run_velocity )
					self:set_animation( self.can_fly and "swim" or "run" )
				end
			end

			if self.can_fly then
				local is_above = minetest.line_of_sight( self.pos,
					{ x = self.pos.x, y = self.pos.y - self.standoff, z = self.pos.z }, 1 )

				if is_above then
					self.object:set_velocity_vert( random_range( -self.stray_velocity, self.stray_velocity ) )
				else
					self.object:set_velocity_vert( random_range( self.walk_velocity, self.run_velocity ) )
				end

			elseif self.can_jump and self.move_result.is_standing then
				if self.yield_level < 3 and self.move_result.collides_xz then
					self.yield_level = self.yield_level + 1
					self:set_velocity_vert( 5 )
				end
			end
		end,

		start_follow_action = function ( self )
			self:turn_to( self:get_target_yaw( self.target:get_pos( ), rad_20 ), 10 )
			self:set_speed( self.recoil_velocity )
			self:set_animation( "walk" )

			self.timekeeper.clear( "hunger" )
			self.timekeeper.start( 0.5, "action", self.on_follow_action )
		end,

		on_follow_action = function ( self, cycles, period, elapsed )
			local target_pos = self.target:get_pos( )
			local dist = get_vector_length( self.pos, target_pos )

			if cycles % 2 == 0 then
				if not self:is_paranoid( target_pos ) or self:check_suspect( self.target, elapsed ) ~= "follow" then
					self:set_ignore_state( )
					return
				end
			end

			if cycles % 2 == 0 then
				if self:get_target_yaw_delta( target_pos ) > rad_45 or random( 5 ) == 1 then
					self:turn_to( self:get_target_yaw( target_pos, rad_20 ), 10 )
				end
			end

			if dist <= self.follow_range then
				if self.speed > 0 then
					self:set_speed( 0 )
					self:set_animation( "stand" )
				end
			else
				if self.speed == 0 then
					self:set_speed( self.walk_velocity )
					self:set_animation( "walk" )

				else
					if self.can_fly then
						-- descend or ascend to slightly above player altitude, but prevent incessant bobbing
						local v = 0
						if target_pos.y + 2.5 > self.pos.y then
							v = self.walk_velocity
						elseif target_pos.y + 0.5 < self.pos.y then
							v = -self.walk_velocity
						end
						self:set_velocity_vert( v )

					elseif self.can_jump and self.move_result.is_standing then
						if self.yield_level < 3 and self.move_result.collides_xz then
							self.yield_level = self.yield_level + 1
							self.object:set_velocity_vert( 5 )
						elseif random( 2 ) == 1 then
							self.object:set_velocity_vert( 5 )
						end
					end
				end
			end
		end,

		start_attack_action = function ( self )
			self:set_speed( self.run_velocity )
			self:set_animation( "run" )
			self:turn_to( self:get_target_yaw( self.target:get_pos( ), rad_90 ), 10 )

			if self.sounds and self.sounds.attack and random( 2 ) == 1  then
				minetest.sound_play( self.sounds.attack, { object = self.object } )
			end

			self.timekeeper.clear( "hunger" )
			self.timekeeper.start( 0.2, "action", self.on_attack_action )
		end,

		on_attack_action = function ( self, cycles )
			if not self.target:is_player( ) or self.target:get_hp( ) == 0 or self.target:get_attach( ) then
				self:set_ignore_state( )
				return
			end
			local target_pos = vector.offset_y( self.target:getpos( ), 0.5 )
			local dist = vector.distance( self.pos, target_pos )

			if cycles % 5 == 0 then
				if not self:is_paranoid( target_pos ) then
					self:set_ignore_state( )
					return
				end
			end

			self:turn_to( self:get_direct_yaw( target_pos ), 5 )

			if dist <= self.attack_range then
				if self.attack_type == "shoot" then
					if cycles % ( self.shoot_period * 5 ) == 0 and random( self.shoot_chance ) == 1 then
						if self.sounds and self.sounds.attack and random( 2 ) == 1 then
							minetest.sound_play( self.sounds.attack, { object = self.object } )
						end
						self:fire_weapon( target_pos )
						self:set_animation( "punch" )
					else
						self:set_animation( self.can_fly and "swim" or "walk" )
					end

				elseif self.attack_type == "melee" then
					if cycles % 5 == 0 then
						if self.sounds and self.sounds.attack and random( 3 ) == 1  then
							minetest.sound_play( self.sounds.attack, { object = self.object } )
						end
					--	if minetest.line_of_sight( pos, target_pos, 0.5 ) then	-- do not hit player through walls!
							self.target:punch( self.object, 1.0,  {
								full_punch_interval = 1.0,
								damage_groups = { fleshy=self.damage }
							}, vector.direction( self.pos, target_pos ) )
					--	end
						self:set_animation( "punch" )
					else
						self:set_animation( self.can_fly and "swim" or "walk" )
					end
				end

				if self.can_fly and cycles % 2 == 0 then
					local v = self.new_vel.y
					if target_pos.y + 0.5 > self.pos.y then
						v = self.stray_velocity
					elseif target_pos.y + 2.5 < self.pos.y then
						v = -self.stray_velocity
					elseif dist < 1.0 then
						v = self.stray_velocity
					else
						v = random_range( -self.stray_velocity, self.stray_velocity )
					end
					self:set_velocity_vert( v )
				end

				if random( 5 ) == 1 then	-- dodge player by sidestepping at random intervals
					self:set_speed_lateral( random( -self.stray_velocity, self.stray_velocity ), 0 )
				end

			else
				if self.can_fly and cycles % 2 == 0 then
					local v = self.new_vel.y
					-- descend or ascend to slightly above player altitude, but prevent incessant bobbing
					if target_pos.y + 0.5 > self.pos.y then
						v = target_pos.y - self.pos.y > self.standoff and self.run_velocity or self.stray_velocity
					elseif target_pos.y + 2.5 < self.pos.y then
						v = target_pos.y - self.pos.y < -self.standoff and -self.run_velocity or -self.stray_velocity
					elseif dist > self.attack_range * 2 then
						v = self.stray_velocity
					elseif random( 10 ) == 1 then
						v = random_range( -self.stray_velocity, self.stray_velocity )
					end
					self:set_velocity_vert( v )

				elseif self.can_jump and self.move_result.is_standing and
						self.yield_level < 3 and self.move_result.collides_xz then
					self.yield_level = self.yield_level + 1
					self:set_velocity_vert( 5 )
				end
	
				if self:get_target_yaw_delta( target_pos ) > rad_30 then
					-- defend from turn-strafing
					if random( 15 ) == 1 then
						self:set_speed( 0 )
					end
					self:set_animation( "walk" )
				elseif self.speed <= 0 then
					self:set_speed( self.run_velocity )
					self:set_animation( "run" )
				end
			end
		end,

		-- animation handler --

		set_animation = function ( self, type )
			if not self.animation or self.cur_animation == type then
				return
			end

			if type == "stand" then
				if self.animation.stand_start and self.animation.stand_end and self.animation.speed_normal then
					self.object:set_animation(
						{ x = self.animation.stand_start, y = self.animation.stand_end },
						self.animation.speed_normal, 0
					)
				end
			elseif type == "walk" then
				if self.animation.walk_start and self.animation.walk_end and self.animation.speed_normal then
					self.object:set_animation(
						{ x = self.animation.walk_start, y = self.animation.walk_end },
						self.animation.speed_normal, 0
					)
				end
			elseif type == "run" then
				if self.animation.run_start and self.animation.run_end and self.animation.speed_run then
					self.object:set_animation(
						{ x = self.animation.run_start, y = self.animation.run_end },
						self.animation.speed_run, 0
					)
				end
			elseif type == "swim" then
				if self.animation.swim_start and self.animation.swim_end and self.animation.speed_swim then
					self.object:set_animation(
						{ x = self.animation.swim_start, y = self.animation.swim_end },
						self.animation.speed_swim, 0
					)
				end
			elseif type == "punch" then
				if self.animation.punch_start and self.animation.punch_end and self.animation.speed_normal then
					self.object:set_animation(
						{ x = self.animation.punch_start, y = self.animation.punch_end },
						self.animation.speed_normal, 0
					)
				end
			else
				return  -- not a valid animation type, so abort
			end

			self.cur_animation = type
		end,

		-- damage and hunger routines --

		handle_damage = function ( self )
			-- handle environmental damage (light, water, and lava)
			local hp = self.object:get_hp( )
			local node = minetest.get_node_above( self.pos, 0.5 )
			local time_of_day = minetest.get_timeofday( )

			if node.name == "ignore" then return end  -- mapblock is not loaded, so abort!
				
			if self.light_damage and self.light_damage > 0 and self.pos.y > 0 and
					minetest.get_node_light( self.pos ) > 4 and check_limits( time_of_day, 0.2, 0.8 ) then
				hp = hp - self.light_damage
				self.object:set_hp( hp )
				if hp <= 0 then
					smoke_effect( self.pos )
					self.object:remove( )
				end
			end
				
			if self.water_damage and self.water_damage > 0 and minetest.get_item_group( node.name, "water" ) ~= 0 then
				hp = hp - self.water_damage
				self.object:set_hp( hp )
				if hp <= 0 then
					smoke_effect( self.pos )
					self.object:remove( )
				end
			end
				
			if self.lava_damage and self.lava_damage > 0 and minetest.get_item_group( node.name, "lava" ) ~= 0 then
				hp = hp - self.lava_damage
				self.object:set_hp( hp )
					if hp <= 0 then
					smoke_effect( self.pos )
					self.object:remove( )
				end
			end
		end,

		handle_hunger = function ( self )
			if self.sounds and self.sounds.random and random( 35 ) == 1 then
				minetest.sound_play( self.sounds.random, { object = self.object } )
			end

			-- when not upset, seek out food or prey at random intervals
			for obj in self:iterate_registry( 30, 30, { registry.players, registry.spawnitems } ) do
				local target_pos = obj:get_pos( )

				if self:is_paranoid( target_pos ) then
					if random( 10 ) <= self.fear_factor and obj:is_player( ) and not obj:get_attach( ) then
						if self.type == "monster" then
							self:set_attack_state( obj )
							return
						else
							self:set_escape_state( obj )
							return
						end
					elseif self.type == "animal" then
						local state = self:check_suspect( obj )
						if state == "escape" then
							self:set_escape_state( obj )
							return
						elseif state == "follow" then
							self:set_follow_state( obj )
							return
						end
					end
				end
			end
		end,

		-- generic callbacks --
		
		on_step = function( self, dtime, pos, rot, new_vel, old_vel, move_result )
			self.pos = pos
			self.yaw = rot.y
			self.new_vel = new_vel
			self.move_result = move_result

			local hp = self.object:get_hp( )
		
			if hp == 0 then
				self.object:remove( )
				return
			end
			
			self.timeout = self.timeout - dtime
			if self.timeout <= 0 and not self.tamed then
				smoke_effect( pos )
				self.object:remove( )
				return
			end

			if self.enable_fall_damage and move_result.collides_y and old_vel.y < -5 then
				local damage = floor( -old_vel.y - 5 ) + 0.5
				self.object:set_hp( hp - damage )
				if hp - damage <= 0.0 then
					smoke_effect( pos )
					self.object:remove( )
					return
				end
			end

			if move_result.is_swimming then
				local drag = -new_vel.y * liquid_viscosity * 1.5
				local buoyancy = self.density - liquid_density
				self.object:set_acceleration_vert( world_gravity * buoyancy + drag )
				self.is_floating = true
			elseif self.is_swimming then
				self.object:set_acceleration_vert( ramp( world_gravity, new_vel.y, 2.0 ) )   -- hack to reduce oscilations
			end
			self.is_swimming = move_result.is_swimming

			if self.yield_level > 0 and not move_result.collides_xz then
				self.yield_level = 0
			end

			self.timekeeper.on_step( dtime )  -- run timer callbacks
		end,

		on_activate = function ( self, staticdata, dtime_s, id )
			registry.avatars[ id ] = self

			self.object:set_armor_groups( { fleshy = self.armor } )
			self:set_acceleration_vert( self.gravity )
			self:set_velocity_vert( 0 )
			self:set_yaw( random( ) * rad_360 )

			self.yield_level = 0
			self.move_result = { collides_xz = false, collides_y = true, is_standing = true }
			self.pos = self.object:get_pos( )

			if staticdata then
				local tmp = minetest.deserialize( staticdata )
				if tmp and tmp.lifetimer then
					self.timeout = tmp.lifetimer - dtime_s
				end
				if tmp and tmp.tamed then
					self.tamed = tmp.tamed
				end
			end

			self.timeout = self.timeout - dtime_s
			if self.timeout <= 0 and not self.is_tamed then
				self.object:remove( )
				return
			end

			self.timekeeper = Timekeeper( self )
			self.timekeeper.start( 1.5, "damage", self.handle_damage )

			if self.custom.after_activate then
				self.custom.after_activate( self, id )
			end

			self:set_ignore_state( )
		end,

		on_deactivate = function ( self, id )
			if self.custom.before_deactivate then
				self.custom.before_deactivate( self, id )
			end

			registry.avatars[ id ] = nil
		end,
		
		get_staticdata = function ( self )
			return minetest.serialize( {
				lifetimer = self.timeout,
				is_tamed = self.is_tamed,
			} )
		end,

		on_punch = function ( self, hitter, time_from_last_punch, tool_capabilities, direction, damage )
			local hp = self.object:get_hp( )
			local pos = self.pos
			local tool = hitter:get_wielded_item( )

			if self.custom.before_punch then
				if not self.custom.before_punch( self, hitter, tool, hp, damage ) then return end
			end

			if damage == 0 then return end

			if self.makes_bloodshed_effect and random( 2 ) == 2 then
				blood_effect( pos )
			end
			if self.sounds and self.sounds.damage_hand and self.sounds.damage_tool then
				minetest.sound_play( minetest.registered_tools[ tool:get_name( ) ] and
					self.sounds.damage_tool or self.sounds.damage_hand, { object = self.object } )
			else
				minetest.sound_play( "mobs_damage", { object = self.object } )
			end

			if hitter:is_player( ) then
				if tool then
					tool:add_wear( 100 )
					hitter:set_wielded_item( tool )
				end

				if hp - damage <= self.hp_low then
					self:set_escape_state( hitter )
				elseif self.type == "monster" then
					self:set_attack_state( hitter )
				end
			end			
		end,

		on_death = function( self, killer )
			for _, drop in ipairs( self.drops ) do
				if random( drop.chance ) == 1 then
					minetest.spawn_item( self.pos, drop.name .. " " .. random( drop.min, drop.max ), 1, 5 )
				end
			end
			if not self.makes_bloodshed_effect then
				smoke_effect( self.pos )
			end

			if killer:is_player( ) then
				if self.death_message then
					minetest.chat_send_all( string.format( self.death_message, killer:get_player_name( ), self.description ) )
				end
				minetest.log( "action", name .. " killed by " .. killer:get_player_name( ) )
			end
		end,		
	} )
end

mobs.register_spawn = function ( name, def )
	local max_object_count = def.max_object_count
	local min_height = def.min_height
	local max_height = def.max_height
	local min_light = def.min_light
	local max_light = def.max_light
	local can_spawn = def.can_spawn

	minetest.register_abm( {
		nodenames = def.nodenames,
		neighbors = { "air" },
		interval = 10,
		chance = def.chance,
		action = function( pos, node, active_object_count, active_object_count_wider )
			if active_object_count_wider > max_object_count then
				return
			end

			local pos2 = vector.offset_y( pos )
			if minetest.get_node( pos2 ).name ~= "air" or minetest.get_node_above( pos2 ).name ~= "air" then
				return
			elseif not check_limits( minetest.get_node_light( pos2 ), min_light, max_light ) then
				return
			elseif not check_limits( pos2.y, min_height, max_height ) then
				return
			elseif can_spawn and not can_spawn( pos2 ) then
				return
			end
			
			minetest.log( "action", "Adding mob " .. name .. " on ".. node.name .." at " .. minetest.pos_to_string( pos ) )
			minetest.add_entity( pos2, name )
		end
	} )
end

mobs.register_spawn_near = function ( name, def )
	local nodenames = def.nodenames
	local max_light = def.max_light
	local min_light = def.min_light
	local chance = def.chance
	local vert_shift = def.vert_shift
	local is_area_safe = def.is_area_safe
	local safe_area = VoxelArea:new( { MinEdge = def.safe_edge1, MaxEdge = def.safe_edge2 } )
	local can_spawn = def.can_spawn

	globaltimer.shift( 0.5 )
	globaltimer.start( 10, name, function ( )
		for player_name, player in pairs( registry.players ) do
			local player_pos = player:get_pos( )

			if random( chance ) == 1 and is_area_safe == safe_area:containsp( player_pos ) then
				local positions = minetest.find_nodes_in_area_under_air(
					vector.offset( player_pos, -10, vert_shift - 5, -10 ),
					vector.offset( player_pos, 10, vert_shift + 5, 10 ),
					nodenames )

				if #positions > 0 then
					local y_offset = minetest.registered_entities[ name ].y_offset
					local pos = positions[ random( #positions ) ]
					local pos2 = vector.offset_y( pos, 2 )

					if minetest.get_node( pos2 ).name == "air" and minetest.get_node_above( pos2 ).name == "air" and
							check_limits( minetest.get_node_light( pos2 ), min_light, max_light ) and
							( not can_spawn or can_spawn( pos2 ) ) then

						minetest.log( "action", "Adding mob " .. name .. " near player " ..
							player_name .. " at " .. minetest.pos_to_string( pos2 ) )
						minetest.add_entity( vector.offset_y( pos2, y_offset ), name )
					end
				end
			end
		end
	end )
end

mobs.register_spawner_node = function ( name, def )
	local chance = def.chance
	local min_light = def.min_light
	local max_light = def.max_light
	local mob_name = def.mob_name

	def.on_timer = function ( pos, elapsed )
		local y_offset = minetest.registered_entities[ mob_name ].y_offset
		local pos2 = vector.offset_y( pos )

		if random( chance ) == 1 and check_limits( minetest.get_node_light( pos2 ), min_light, max_light ) and
				minetest.get_node( pos2 ).name == "air" and minetest.get_node_above( pos2 ).name == "air" then

			minetest.add_entity( vector.offset_y( pos2, y_offset ), mob_name )
			minetest.log( "action", "Adding mob " .. mob_name .. " on " .. name .. " at " .. minetest.pos_to_string( pos ) )
		end

		return true
	end

	def.after_place_node = function ( pos, player, itemstack )
		minetest.get_node_timer( pos ):start( 10 )
	end

	minetest.register_node( name, def )
end

mobs.register_projectile = function ( name, def )
	minetest.register_entity( name, {
		physical = true,
		visual = def.visual,
		visual_size = def.visual_size,
		textures = def.textures,
		gravity = def.gravity,
		trail_effect = def.trail_effect,
		can_submerge = def.can_submerge,
		on_launch = def.on_launch,
		on_impact = def.on_impact,
		on_impact_nodes = def.on_impact_nodes,
		sounds = def.sounds,
		timeout = def.timeout,

		launch = function ( self, yaw, speed, incline, gravity )
			self.object:set_yaw( yaw )
			self.object:set_speed( speed )
			self.object:set_velocity_vert( incline * speed )
			self.object:set_acceleration_vert( gravity or self.gravity )

			self.trail_effect.vel_x = -sin( yaw + self.trail_effect.angle ) * self.trail_effect.speed
			self.trail_effect.vel_z = cos( yaw + self.trail_effect.angle ) * self.trail_effect.speed

			minetest.sound_play( self.sounds.launch, { object = self.object, gain = 1 } )
		end,

		on_activate = function( self, staticdata, dtime_s )
			self.timekeeper = Timekeeper( self )

			if self.trail_effect then
				self.timekeeper.start( self.trail_effect.period, "trail_effect" )
			end
			self.timekeeper.start( self.timeout, "timeout", function ( )
				self.object:remove( )  -- remove expired projectile after timeout
			end )
		end,
		
		on_step = function( self, dtime, pos, rot, new_vel, old_vel, move_result )
			local timers = self.timekeeper.on_step( dtime )

			if timers.trail_effect then
				local fx = self.trail_effect

				for i = 1, fx.amount do
					minetest.add_particle( {
						pos = vector.offset( pos,
							random_range( -0.5, 0.5 ),
							random_range( -0.5, 0.5 ),
							random_range( -0.5, 0.5 )
						),
						velocity = vector.new( fx.vel_x, fx.vel_y, fx.vel_z ),
						acceleration = vector.new( 0, fx.acc_y, 0 ),
						expirationtime = def.trail_effect.expiry,
						collisiondetection = false,
						texture = fx.texture,
						size = fx.size,
					} )
				end
			end

			if move_result.is_swimming and not self.is_swimming then
				minetest.sound_play( self.sounds.submerge, { object = self.object, gain = 1 } )
				if not self.can_submerge then
					self.object:remove( )
				end
			end
			self.is_swimming = move_result.is_swimming

			if move_result.collides_xz or move_result.collides_y then
				if #move_result.touched_objects > 0 and self.on_impact then
					for i, v in ipairs( move_result.touched_objects ) do
						self:on_impact( pos, old_vel, v )
					end
				end
				if #move_result.collisions > 0 and self.on_impact_nodes then
					self:on_impact_nodes( pos, old_vel, move_result.collisions )
				end

				minetest.sound_play( self.sounds.impact, { object = self.object, gain = 1 } )
				self.object:remove( )
			end
		end
	} )
end

--------------------

mobs.presets = {
	grab_handout = function ( def )
		local grab_chance = def.grab_chance
		local wait_chance = def.wait_chance
		local can_eat = def.can_eat

		return function ( self, target, elapsed )

			if random( grab_chance ) == 1 then
				local target_pos = vector.offset_y( target:get_pos( ) )
				local dist = vector.distance( self.pos, target_pos )

				if self:get_target_yaw_delta( target_pos ) < rad_30 and dist <= self.pickup_range then
					if target:is_player( ) then
						target:get_wielded_item( ):take_item( )
						target:set_wielded_item( "" )
					elseif target:get_entity_name( ) == "__builtin:item" then
						target:remove( )
					end
					if can_eat then
					--	minetest.sound_play( "hbhunger_eat_generic", {
					--		object = self.object,
					--		max_hear_distance = 10,
					--		gain = 1.0
					--	} )
						minetest.add_particle( {
							pos = vector.offset_y( self.pos, 0.5 ),
							velocity = { x = 0, y = 0.8, z = 0 },
							acceleration = { x = 0, y = 0, z = 0 },
							exptime = 4.0,
							size = 3,
							collisiondetection = false,
							vertical = true,
							texture = "heart.png",
						} )
					end
					return nil
				end
			end

			return random( wait_chance ) == 1 and "follow" or nil
		end
	end,
}

--------------------

dofile( minetest.get_modpath( "mobs" ) .. "/extras.lua" )
dofile( minetest.get_modpath( "mobs" ) .. "/monsters.lua" )
dofile( minetest.get_modpath( "mobs" ) .. "/animals.lua" )
dofile( minetest.get_modpath( "mobs" ) .. "/weapons.lua" )

-- compatibility for Minetest S3 engine

if not vector.origin then
	dofile( minetest.get_modpath( "mobs" ) .. "/compatibility.lua" )
end
