local WORLDS = require "world.balance.def.worlds"

local M = {

}

M.by_world = {
	[WORLDS.WORLDS_BY_ID.MINE_WORLD.id] = {
		{ name = "King", icon = hash("icon_char_king"), score = 7500, bot = true },
		{ name = "Robot", icon = hash("icon_char_robot"), score = 6500, bot = true },
		{ name = "Superhero", icon = hash("icon_char_superhero"), score = 6000, bot = true },
		{ name = "Vampire", icon = hash("icon_char_vampire"), score = 5000, bot = true },
		{ name = "Adventurer", icon = hash("icon_char_proffesor"), score = 3500, bot = true },
		{ name = "Explorer", icon = hash("icon_char_lera_craft"), score = 2500, bot = true },
		{ name = "Zombie", icon = hash("icon_char_zombie"), score = 1500, bot = true },
		{ name = "Skeleton", icon = hash("icon_char_skelet"), score = 1000, bot = true },
		{ name = "Alice", icon = hash("icon_char_girl"), score = 500, bot = true },
		{ name = "Steve", icon = hash("icon_char_mine"), score = 100, bot = true },
	},
	[WORLDS.WORLDS_BY_ID.GRASS_WORLD.id] = {
		{ name = "King", icon = hash("icon_char_king"), score = 9999, bot = true },
		{ name = "Robot", icon = hash("icon_char_robot"), score = 9000, bot = true },
		{ name = "Superhero", icon = hash("icon_char_superhero"), score = 8000, bot = true },
		{ name = "Vampire", icon = hash("icon_char_vampire"), score = 6500, bot = true },
		{ name = "Adventurer", icon = hash("icon_char_proffesor"), score = 5000, bot = true },
		{ name = "Explorer", icon = hash("icon_char_lera_craft"), score = 3500, bot = true },
		{ name = "Zombie", icon = hash("icon_char_zombie"), score = 2000, bot = true },
		{ name = "Skeleton", icon = hash("icon_char_skelet"), score = 1250, bot = true },
		{ name = "Alice", icon = hash("icon_char_girl"), score = 750, bot = true },
		{ name = "Steve", icon = hash("icon_char_mine"), score = 100, bot = true },
	},
	[WORLDS.WORLDS_BY_ID.METAL_WORLD.id] = {
		{ name = "King", icon = hash("icon_char_king"), score = 15000, bot = true },
		{ name = "Robot", icon = hash("icon_char_robot"), score = 13500, bot = true },
		{ name = "Superhero", icon = hash("icon_char_superhero"), score = 12500, bot = true },
		{ name = "Vampire", icon = hash("icon_char_vampire"), score = 11000, bot = true },
		{ name = "Adventurer", icon = hash("icon_char_proffesor"), score = 10000, bot = true },
		{ name = "Explorer", icon = hash("icon_char_lera_craft"), score = 8000, bot = true },
		{ name = "Zombie", icon = hash("icon_char_zombie"), score = 5000, bot = true },
		{ name = "Skeleton", icon = hash("icon_char_skelet"), score = 2500, bot = true },
		{ name = "Alice", icon = hash("icon_char_girl"), score = 1250, bot = true },
		{ name = "Steve", icon = hash("icon_char_mine"), score = 100, bot = true },
	},
	[WORLDS.WORLDS_BY_ID.TOON_WORLD.id] = {
		{ name = "King", icon = hash("icon_char_king"), score = 30000, bot = true },
		{ name = "Robot", icon = hash("icon_char_robot"), score = 27500, bot = true },
		{ name = "Superhero", icon = hash("icon_char_superhero"), score = 25000, bot = true },
		{ name = "Vampire", icon = hash("icon_char_vampire"), score = 22000, bot = true },
		{ name = "Adventurer", icon = hash("icon_char_proffesor"), score = 18000, bot = true },
		{ name = "Explorer", icon = hash("icon_char_lera_craft"), score = 14000, bot = true },
		{ name = "Zombie", icon = hash("icon_char_zombie"), score = 9000, bot = true },
		{ name = "Skeleton", icon = hash("icon_char_skelet"), score = 5000, bot = true },
		{ name = "Alice", icon = hash("icon_char_girl"), score = 3000, bot = true },
		{ name = "Steve", icon = hash("icon_char_mine"), score = 100, bot = true },
	},
	[WORLDS.WORLDS_BY_ID.DARK_WORLD.id] = {
		{ name = "King", icon = hash("icon_char_king"), score = 40000, bot = true },
		{ name = "Robot", icon = hash("icon_char_robot"), score = 37500, bot = true },
		{ name = "Superhero", icon = hash("icon_char_superhero"), score = 35000, bot = true },
		{ name = "Vampire", icon = hash("icon_char_vampire"), score = 30000, bot = true },
		{ name = "Adventurer", icon = hash("icon_char_proffesor"), score = 25000, bot = true },
		{ name = "Explorer", icon = hash("icon_char_lera_craft"), score = 20000, bot = true },
		{ name = "Zombie", icon = hash("icon_char_zombie"), score = 15000, bot = true },
		{ name = "Skeleton", icon = hash("icon_char_skelet"), score = 10000, bot = true },
		{ name = "Alice", icon = hash("icon_char_girl"), score = 5000, bot = true },
		{ name = "Steve", icon = hash("icon_char_mine"), score = 100, bot = true },
	}
}
return M