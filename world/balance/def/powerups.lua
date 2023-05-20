local M = {}

M.RUN = {
	id = "RUN",
	icon = hash("icon_powerup_run"),
	levels = {
		{ duration = 8, cost = 0 },
		{ duration = 8.5, cost = 75 },
		{ duration = 9, cost = 150 },
		{ duration = 9.5, cost = 250 },
		{ duration = 10, cost = 350 },
		{ duration = 10.5, cost = 500 },
		{ duration = 11, cost = 750 },
		{ duration = 11.5, cost = 1000 },
		{ duration = 12, cost = 1500 },
		{ duration = 12.5, cost = 1500 },
		{ duration = 13, cost = 2500 },
		{ duration = 13.5, cost = 2500 },
		{ duration = 14, cost = 3500 },
		{ duration = 14.5, cost = 3500 },
		{ duration = 15, cost = 5000 },
	}
}
M.MAGNET = {
	id = "MAGNET",
	icon = hash("icon_powerup_magnet"),
	levels = {
		{ duration = 8, cost = 0 },
		{ duration = 8.5, cost = 75 },
		{ duration = 9, cost = 150 },
		{ duration = 9.5, cost = 250 },
		{ duration = 10, cost = 350 },
		{ duration = 10.5, cost = 500 },
		{ duration = 11, cost = 750 },
		{ duration = 11.5, cost = 1000 },
		{ duration = 12, cost = 1500 },
		{ duration = 12.5, cost = 1500 },
		{ duration = 13, cost = 2500 },
		{ duration = 13.5, cost = 2500 },
		{ duration = 14, cost = 3500 },
		{ duration = 14.5, cost = 3500 },
		{ duration = 15, cost = 5000 },
	}
}
M.STAR = {
	id = "STAR",
	icon = hash("icon_powerup_x2"),
	levels = {
		{ duration = 11, cost = 0 },
		{ duration = 12, cost = 75 },
		{ duration = 13, cost = 150 },
		{ duration = 14, cost = 250 },
		{ duration = 15, cost = 350 },
		{ duration = 16, cost = 500 },
		{ duration = 17, cost = 750 },
		{ duration = 18, cost = 1000 },
		{ duration = 19, cost = 1500 },
		{ duration = 20, cost = 1500 },
		{ duration = 21, cost = 2500 },
		{ duration = 22, cost = 2500 },
		{ duration = 23, cost = 3500 },
		{ duration = 24, cost = 3500 },
		{ duration = 25, cost = 5000 },
	}
}

M.MORE_GEMS = {
	id = "MORE_GEMS",
	icon = hash("icon_gem"),
	levels = {
		{ gems = 1, shop_offer = 400, daily_gems = 300, cost = 0 },
		{ gems = 2, shop_offer = 650, daily_gems = 350, cost = 150 },
		{ gems = 3, shop_offer = 750, daily_gems = 400, cost = 500 },
		{ gems = 4, shop_offer = 1000, daily_gems = 450, cost = 1000 },
		{ gems = 5, shop_offer = 1500, daily_gems = 500, cost = 1500 },
		{ gems = 6, shop_offer = 1750, daily_gems = 600, cost = 2500 },
		{ gems = 7, shop_offer = 2000, daily_gems = 700, cost = 5000 },
		{ gems = 8, shop_offer = 2500, daily_gems = 800, cost = 7500 },
		{ gems = 9, shop_offer = 3000, daily_gems = 900, cost = 10000 },
		{ gems = 10, shop_offer = 3500, daily_gems = 1000, cost = 15000 },
	}
}

return M