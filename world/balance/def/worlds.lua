local M = {}

M.WORLDS_BY_ID = {}

M.WORLDS_BY_ID.MINE_WORLD = {
	texture = "mine_world",
	title = "OLD MINE",
	stars = 0,
	random_colors = true,
	ya_leaderboard = "MINEWORLDscore"
}

M.WORLDS_BY_ID.GRASS_WORLD = {
	texture = "grass_world",
	title = "GRASSLAND",
	stars = 2,
	light_directional_intensity = 0.1,
	light_ambient_intensity = 0.9,
	random_colors = false,
	ya_leaderboard = "GRASSWORLDscore"
}



M.WORLDS_BY_ID.DARK_WORLD = {
	texture = "dark_world",
	title = "DARKNESS",
	stars = 10,
	random_colors = false,
	ya_leaderboard = "DARKWORLDscore"
}
M.WORLDS_BY_ID.TOON_WORLD = {
	texture = "toon_world",
	title = "TOON WORLD",
	stars = 6,
	light_directional_intensity = 0.25,
	light_ambient_intensity = 0.75,
	random_colors = false,
	ya_leaderboard = "TOONWORLDscore"
}
M.WORLDS_BY_ID.METAL_WORLD = {
	texture = "metal_world",
	title = "METAL CAVE",
	stars = 4,
	random_colors = true,
	ya_leaderboard = "METALWORLDscore"
}

for k, v in pairs(M.WORLDS_BY_ID) do
	v.id = k
end

M.WORLD_LIST = {
	M.WORLDS_BY_ID.MINE_WORLD,
	M.WORLDS_BY_ID.GRASS_WORLD,
	M.WORLDS_BY_ID.METAL_WORLD,
	M.WORLDS_BY_ID.TOON_WORLD,
	M.WORLDS_BY_ID.DARK_WORLD,
}

return M