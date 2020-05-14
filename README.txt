Mobs Lite Mod v1.4
By Leslie E. Krause

Mobs Lite is a fully-working proof of concept for the Extended Motion Mechanics API for
LuaEntity SAO's, and it requires installing the following patch for Minetest 5.3-dev:

   https://github.com/minetest/minetest/pull/9717

While originally forked from PilzAdam's "Simple Mobs" mod several years ago, Mobs Lite has 
been effectively written from scratch. Most of the core architecture is derived from my 
Avatars mod, albeit a much leaner design.

Here are some of the other highlights of the Mobs Lite engine:

 * Extremely lightweight design thanks to the new API (no more continuous collision checks 
   and velocity resets).

 * Realistic fluid mechanics such as density and viscosity so that creatures have varying 
   buoyancy characteristics.

 * Sophisticated sensory analysis with a custom view-cone and acuity curve dependant on 
   current alertness state.

 * Sensitivity thresholds and certainty factors determine whether creatures "see" a player 
   within their view cone.

 * Discrete awareness stages permit mobs to slowly ramp up or cool down alertness based on
   the target's visibility.

 * Animals will attempt to flee to safety when a player that previously punched them 
   returns to the field of view.

 * Animals can be programmed to follow players that are wielding food and to eat directly
   from the player's hand.

 * Monsters burst into multiple gibs when killed by explosive charges such as fire arrows,
   landmines, and dynamite.

 * Seamless integration with Axon allows Mobs to react to various environmental stimulii
   like smells, sounds, etc.

 * Timekeeper helper class ensures efficient dispatching of mob-related callbacks at the
   appropriate server step.

 * Builtin lookup table allows for efficiently iterating over multiple classes of objects
   within a specific radius.

 * Mobs can be randomly spawned in the vicinity of players, thus relieving the overhead of 
   costly ABM-based spawners.

 * Mobs will avoid running into most obstacles by analyzing the surroundings and steadily
   adjusting their course.

 * And of course, much much more!

Since Mobs Lite is still in early beta, there is the likelihood of lingering bugs. The API
is also subject to change. I'm actively using this mod on my own server, however. So when 
new issues are discovered or reported, they will be promptly fixed :)


Repository
----------------------

Browse source code...
  https://bitbucket.org/sorcerykid/mobs

Download archive...
  https://bitbucket.org/sorcerykid/mobs/get/master.zip
  https://bitbucket.org/sorcerykid/mobs/get/master.tar.gz

Compatability
----------------------

Requires PR #9717 for Minetest 5.3-dev

Dependencies
----------------------

TNT Mod (required)
  https://github.com/minetest-game-mods/tnt

Default Mod (required)
  https://github.com/minetest-game-mods/default

Axon Mod (optional)
  https://bitbucket.org/sorcerykid/axon

Installation
----------------------

  1) Unzip the archive into the mods directory of your game
  2) Rename the mobs-master directory to "mobs"

License of source code
----------------------------------------------------------

GNU Lesser General Public License v3 (LGPL-3.0)

Copyright (c) 2016-2020, Leslie E. Krause

This program is free software; you can redistribute it and/or modify it under the terms of
the GNU Lesser General Public License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

http://www.gnu.org/licenses/lgpl-2.1.html


Multimedia License (textures, sounds, and models)
----------------------------------------------------------

Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)

  /sounds/mobs_damage_hand.ogg
  by shelbyshark
  modified by sorcerykid
  obtained from https://freesound.org/people/shelbyshark/sounds/444703/

  /sounds/mobs_damage_tool.ogg
  by satanicupsman
  modified by sorcerykid
  objained from https://freesound.org/people/satanicupsman/sounds/144015/

  /sounds/mobs_damage_tool.ogg
  by rcroller
  modified by sorcerykid
  objained from https://freesound.org/people/rcroller/sounds/424144/

  /sounds/mobs_gib_chunky.1.ogg
  by GreenFireSound
  modified by sorcerykid
  objained from https://freesound.org/people/GreenFireSound/sounds/481090/

  /sounds/mobs_gib_chunky.2.ogg
  by GreenFireSound
  modified by sorcerykid
  objained from https://freesound.org/people/GreenFireSound/sounds/481090/

  /textures/mobs_spider.png
  by AspireMint
  obtained from https://github.com/Darcidride/minetest-spidermob-v1

  /textures/mobs_rat2.ogg
  by Pavel_S (originally WTFPL)
  obtained from https://github.com/PilzAdam/mobs

  /textures/mobs_oerkki.ogg
  by Pavel_S (originally WTFPL)
  obtained from https://github.com/PilzAdam/mobs

  /textures/mobs_ghost.png
  by BlockMen
  obtained from https://github.com/BlockMen/cme/tree/master/ghost

  /textures/mobs_bunny.png
  by ExeterDad
  obtained from https://notabug.org/TenPlus1/mobs_animal

  /textures/mobs_chicken.png
  by JK Murray
  obtained from https://notabug.org/TenPlus1/mobs_animal

  /models/mobs_spider.x
  by AspireMint
  obtained from https://github.com/Darcidride/minetest-spidermob-v1

  /textures/mobs_kitten.png
  by Jordach
  obtained from https://notabug.org/TenPlus1/mobs_animal

  /models/mobs_rat.b3d
  by Pavel_S (originally WTFPL)
  modified by sirrobzeroone
  obtained from https://github.com/PilzAdam/mobs

  /models/mobs_oerkki.x
  by Pavel_S (originally WTWFPL)
  obtained from https://github.com/PilzAdam/mobs

  /models/mobs_ghost.b3d
  by BlockMen
  obtained from https://github.com/BlockMen/cme/tree/master/ghost

  /models/mobs_bunny.b3d
  by ExeterDad
  obtained from https://notabug.org/TenPlus1/mobs_animal

  /models/mobs_chicken.png
  by JK Murray
  obtained from https://notabug.org/TenPlus1/mobs_animal

  /textures/mobs_fireball.png
  by PilzAdam
  obtained from https://github.com/PilzAdam/mobs

  /textures/mobs_meat.png
  by Krupnov Pavel
  obtained from https://github.com/AntumMT/mod-kpgmobs

  /textures/mobs_meat_raw.png
  by Krupnov Pavel
  obtained from https://github.com/AntumMT/mod-kpgmobs

You are free to:
Share — copy and redistribute the material in any medium or format.
Adapt — remix, transform, and build upon the material for any purpose, even commercially.
The licensor cannot revoke these freedoms as long as you follow the license terms.

Under the following terms:

Attribution — You must give appropriate credit, provide a link to the license, and
indicate if changes were made. You may do so in any reasonable manner, but not in any way
that suggests the licensor endorses you or your use.

No additional restrictions — You may not apply legal terms or technological measures that
legally restrict others from doing anything the license permits.

Notices:

You do not have to comply with the license for elements of the material in the public
domain or where your use is permitted by an applicable exception or limitation.
No warranties are given. The license may not give you all of the permissions necessary
for your intended use. For example, other rights such as publicity, privacy, or moral
rights may limit how you use the material.

For more details:
http://creativecommons.org/licenses/by-sa/3.0/
