local COMMON = require "libs.common"

local STATES = {
	UNLOADED = "UNLOADED",
	LOADING = "LOADING",
	HIDE = "HIDE", --scene is loaded.But not showing on screen
	PAUSED = "PAUSED", --scene is showing.But update not called.
	RUNNING = "RUNNING", --scene is running
}

local TRANSITIONS = {
	ON_HIDE = "ON_HIDE",
	ON_SHOW = "ON_SHOW",
	ON_BACK_SHOW = "ON_BACK_SHOW",
	ON_BACK_HIDE = "ON_BACK_HIDE",
}

return {
	STATES = STATES,
	TRANSITIONS = TRANSITIONS
}

