local M = {}

M.SKINS_BY_ID = {}

M.SKINS_BY_ID.MINE = {
	factory = msg.url("game_scene:/factory#char_mine"),
	factory_skin = msg.url("shop_scene:/factory#char_mine"),
	icon = hash("icon_char_mine"),
	scale = vmath.vector3(0.3),
	name = "Steve",
	price = 0
}
M.SKINS_BY_ID.LERA_CRAFT = {
	factory = msg.url("game_scene:/factory#char_lera_craft"),
	factory_skin = msg.url("shop_scene:/factory#char_lera_craft"),
	scale = vmath.vector3(0.3),
	name = "Explorer",
	icon = hash("icon_char_lera_craft"),
	price = 1000
}
M.SKINS_BY_ID.ZOMBIE = {
	factory = msg.url("game_scene:/factory#char_zombie"),
	factory_skin = msg.url("shop_scene:/factory#char_zombie"),
	scale = vmath.vector3(0.3),
	name = "Zombie",
	icon = hash("icon_char_zombie"),
	price = 1000,
	unlock_by_ads = true
}

M.SKINS_BY_ID.GOLEM = {
	factory = msg.url("game_scene:/factory#char_golem"),
	factory_skin = msg.url("shop_scene:/factory#char_golem"),
	scale = vmath.vector3(0.3),
	name = "Golem",
	icon = hash("icon_char_golem"),
	price = 1000
}

M.SKINS_BY_ID.PROFESSOR = {
	factory = msg.url("game_scene:/factory#char_proffesor"),
	factory_skin = msg.url("shop_scene:/factory#char_proffesor"),
	scale = vmath.vector3(0.3),
	name = "Adventurer",
	icon = hash("icon_char_proffesor"),
	price = 1000,
}

M.SKINS_BY_ID.KING = {
	factory = msg.url("game_scene:/factory#char_king"),
	factory_skin = msg.url("shop_scene:/factory#char_king"),
	scale = vmath.vector3(0.3),
	name = "King",
	icon = hash("icon_char_king"),
	unlock_by_ads = true,
	price = 10000
}
M.SKINS_BY_ID.GIRL = {
	factory = msg.url("game_scene:/factory#char_girl"),
	factory_skin = msg.url("shop_scene:/factory#char_girl"),
	scale = vmath.vector3(0.3),
	name = "Alice",
	icon = hash("icon_char_girl"),
	price = 100
}
M.SKINS_BY_ID.VAMPIRE = {
	factory = msg.url("game_scene:/factory#char_vampire"),
	factory_skin = msg.url("shop_scene:/factory#char_vampire"),
	scale = vmath.vector3(0.3),
	name = "Vampire",
	icon = hash("icon_char_vampire"),
	price = 2500
}
M.SKINS_BY_ID.CAT_GIRL = {
	factory = msg.url("game_scene:/factory#char_cat_girl"),
	factory_skin = msg.url("shop_scene:/factory#char_cat_girl"),
	scale = vmath.vector3(0.3),
	name = "Cat",
	icon = hash("icon_char_cat_girl"),
	price = 500,
	unlock_by_ads = true
}
M.SKINS_BY_ID.SUPERHERO = {
	factory = msg.url("game_scene:/factory#char_superhero"),
	factory_skin = msg.url("shop_scene:/factory#char_superhero"),
	scale = vmath.vector3(0.3),
	name = "Superhero",
	icon = hash("icon_char_superhero"),
	price = 5000
}
M.SKINS_BY_ID.ROBOT = {
	factory = msg.url("game_scene:/factory#char_robot"),
	factory_skin = msg.url("shop_scene:/factory#char_robot"),
	scale = vmath.vector3(0.3),
	name = "Robot",
	icon = hash("icon_char_robot"),
	price = 5000
}
M.SKINS_BY_ID.CHAR_SKELET = {
	factory = msg.url("game_scene:/factory#char_skelet"),
	factory_skin = msg.url("shop_scene:/factory#char_skelet"),
	scale = vmath.vector3(0.3),
	name = "Skeleton",
	icon = hash("icon_char_skelet"),
	price = 250
}

for k, v in pairs(M.SKINS_BY_ID) do
	v.id = k
end

M.SKIN_LIST = {
	M.SKINS_BY_ID.MINE,
	M.SKINS_BY_ID.GIRL,
	M.SKINS_BY_ID.CHAR_SKELET,
	M.SKINS_BY_ID.ZOMBIE,

	M.SKINS_BY_ID.LERA_CRAFT,
	M.SKINS_BY_ID.PROFESSOR,
	M.SKINS_BY_ID.GOLEM,
	M.SKINS_BY_ID.CAT_GIRL,

	M.SKINS_BY_ID.VAMPIRE,
	M.SKINS_BY_ID.SUPERHERO,
	M.SKINS_BY_ID.ROBOT,
	M.SKINS_BY_ID.KING,
}

return M