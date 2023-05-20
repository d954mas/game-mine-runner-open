local M = {}

M.BASE = {
	{ speed = 8, acceleration = 2, speed_x = 2, fov = math.rad(60), distance = 4.5 }, --20
	{ speed = 12, acceleration = 2, speed_x = 2, fov = math.rad(65), distance = 4}, --100
	{ speed = 15, acceleration = 1, speed_x = 3, fov = math.rad(70), distance = 3.5 }, --300
	{ speed = 18, acceleration = 1, speed_x = 4, fov = math.rad(75), distance = 3 }, --500
	{ speed = 24, acceleration = 1, speed_x = 5, fov = math.rad(80), distance = 2.5 }, --1000
	{ speed = 25, acceleration = 1, speed_x = 5, fov = math.rad(80), distance = 2.5 } -->1000
}

return M