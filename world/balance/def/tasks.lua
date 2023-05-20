local M = {}

local TYPE = {
	COLLECT_COINS_RUN = "COLLECT_COINS_RUN", --check
	COLLECT_COINS_TOTAL = "COLLECT_COINS_TOTAL", --check

	RUN_POINTS_RUN = "RUN_POINTS_RUN", --check
	RUN_POINTS_TOTAL = "RUN_POINTS_TOTAL", --check

	PLAY_RUN = "PLAY_RUN", --check

	COLLECT_POWER_UPS_TOTAL = "COLLECT_POWER_UPS_TOTAL", --check

	COLLECT_POWER_UPS_MAGNET_TOTAL = "COLLECT_POWER_UPS_MAGNET_TOTAL", --check
	COLLECT_POWER_UPS_SPEED_TOTAL = "COLLECT_POWER_UPS_SPEED_TOTAL", --check
	COLLECT_POWER_UPS_X2_TOTAL = "COLLECT_POWER_UPS_X2_TOTAL", --check


	CHANGE_SKIN = "CHANGE_SKIN", --check

	COMPLETE_DAILY_GEMS = "COMPLETE_DAILY_GEMS",
	COMPLETE_TUTORIAL = "COMPLETE_TUTORIAL",
}



M.TYPE = TYPE

M.MISSION_LIST = {
	--x2
	{
		{ type = TYPE.COLLECT_COINS_TOTAL, value = 150 },
		{ type = TYPE.COMPLETE_TUTORIAL, value = 1 },
		{ type = TYPE.PLAY_RUN, value = 2 },
	},
	--x3
	{
		{ type = TYPE.RUN_POINTS_RUN, value = 600 },
		{ type = TYPE.COMPLETE_DAILY_GEMS, value = 1 },
		{ type = TYPE.CHANGE_SKIN, value = 1 },
	},
	--x4
	{
		{ type = TYPE.COLLECT_COINS_TOTAL, value = 2000 },
		{ type = TYPE.COLLECT_POWER_UPS_TOTAL, value = 3 },
		{ type = TYPE.PLAY_RUN, value = 5 },
	},
	--x5
	{
		{ type = TYPE.RUN_POINTS_RUN, value = 4500 },
		{ type = TYPE.COMPLETE_DAILY_GEMS, value = 2 },
		{ type = TYPE.COLLECT_COINS_RUN, value = 600 },
	},
	--x6
	{
		{ type = TYPE.RUN_POINTS_TOTAL, value = 15000 },
		{ type = TYPE.COLLECT_POWER_UPS_TOTAL, value = 5 },
		{ type = TYPE.COLLECT_COINS_TOTAL, value = 5000 },
	},
	--x7
	{
		{ type = TYPE.COLLECT_POWER_UPS_MAGNET_TOTAL, value = 3 },
		{ type = TYPE.COMPLETE_DAILY_GEMS, value = 2 },
		{ type = TYPE.RUN_POINTS_TOTAL, value = 20000 },
	},
	--x8
	{
		{ type = TYPE.COLLECT_COINS_RUN, value = 3000 },
		{ type = TYPE.COLLECT_POWER_UPS_TOTAL, value = 6 },
		{ type = TYPE.RUN_POINTS_RUN, value = 9000 },
	},
	--x9
	{
		{ type = TYPE.RUN_POINTS_TOTAL, value = 35000 },
		{ type = TYPE.COMPLETE_DAILY_GEMS, value = 2 },
		{ type = TYPE.RUN_POINTS_RUN, value = 10000 },
	},
	--x10
	{
		{ type = TYPE.PLAY_RUN, value = 10 },
		{ type = TYPE.RUN_POINTS_TOTAL, value = 50000 },
		{ type = TYPE.COLLECT_COINS_TOTAL, value = 10000 },
	},
	--x11
	{
		{ type = TYPE.PLAY_RUN, value = 10 },
		{ type = TYPE.RUN_POINTS_TOTAL, value = 50000 },
		{ type = TYPE.COMPLETE_DAILY_GEMS, value = 2 },
	},
	--x12
	{
		{ type = TYPE.PLAY_RUN, value = 10 },
		{ type = TYPE.RUN_POINTS_TOTAL, value = 50000 },
		{ type = TYPE.COMPLETE_DAILY_GEMS, value = 2 },
	},
	--x13
	{
		{ type = TYPE.PLAY_RUN, value = 10 },
		{ type = TYPE.RUN_POINTS_TOTAL, value = 50000 },
		{ type = TYPE.COMPLETE_DAILY_GEMS, value = 2 },
	},
	--x14
	{
		{ type = TYPE.PLAY_RUN, value = 10 },
		{ type = TYPE.RUN_POINTS_TOTAL, value = 50000 },
		{ type = TYPE.COMPLETE_DAILY_GEMS, value = 2 },
	},
	--x15
	{
		{ type = TYPE.PLAY_RUN, value = 10 },
		{ type = TYPE.RUN_POINTS_TOTAL, value = 50000 },
		{ type = TYPE.COMPLETE_DAILY_GEMS, value = 2 },
	},
	{
		{ type = TYPE.PLAY_RUN, value = 15 },
		{ type = TYPE.RUN_POINTS_TOTAL, value = 100000 },
		{ type = TYPE.COMPLETE_DAILY_GEMS, value = 3 },
	}
}



return M