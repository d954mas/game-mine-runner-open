local lume = require "libs.lume"

local M = {}

M.GAME_SIZE = {
	width = 960,
	height = 540
}

M.SYSTEM_INFO = sys.get_sys_info({ignore_secure = true})
M.PLATFORM = M.SYSTEM_INFO.system_name
M.PLATFORM_IS_WEB = M.PLATFORM == "HTML5"
M.PLATFORM_IS_WINDOWS = M.PLATFORM == "Windows"
M.PLATFORM_IS_LINUX = M.PLATFORM == "Linux"
M.PLATFORM_IS_MACOS = M.PLATFORM == "Darwin"
M.PLATFORM_IS_ANDROID = M.PLATFORM == "Android"
M.PLATFORM_IS_IPHONE = M.PLATFORM == "iPhone OS"

M.PLATFORM_IS_PC = M.PLATFORM_IS_WINDOWS or M.PLATFORM_IS_LINUX or M.PLATFORM_IS_MACOS
M.PLATFORM_IS_MOBILE = M.PLATFORM_IS_ANDROID or M.PLATFORM_IS_IPHONE

M.PROJECT_VERSION = sys.get_config("project.version")

M.GAME_VERSION = sys.get_config("game.version")

M.VERSION_IS_DEV = M.GAME_VERSION == "dev"
M.VERSION_IS_RELEASE = M.GAME_VERSION == "release"

M.GAME_TARGET = sys.get_config("game.target")

M.TARGETS = {
	EDITOR = "editor",
	PLAY_MARKET = "play_market",
	GAME_DISTRIBUTION = "game_distribution",
	POKI = "poki",
	ITCH_IO = "itch_io",
	YANDEX_GAMES = "yandex_games",
	VK_GAMES = "vk_games",
	FB_INSTANT = "fb_instant",
	CRAZY_GAMES = "crazy_games"
}

assert(lume.find(M.TARGETS, M.GAME_TARGET), "unknown target:" .. M.GAME_TARGET)

M.TARGET_IS_EDITOR = M.GAME_TARGET == M.TARGETS.EDITOR
M.TARGET_IS_PLAY_MARKET = M.GAME_TARGET == M.TARGETS.PLAY_MARKET
M.TARGET_IS_GAME_DISTRIBUTION = M.GAME_TARGET == M.TARGETS.GAME_DISTRIBUTION
M.TARGET_IS_POKI = M.GAME_TARGET == M.TARGETS.POKI
M.TARGET_IS_ITCH_IO = M.GAME_TARGET == M.TARGETS.ITCH_IO
M.TARGET_IS_YANDEX_GAMES = M.GAME_TARGET == M.TARGETS.YANDEX_GAMES
M.TARGET_IS_VK_GAMES = M.GAME_TARGET == M.TARGETS.VK_GAMES
M.TARGET_IS_FB_INSTANT = M.GAME_TARGET == M.TARGETS.FB_INSTANT
M.TARGET_IS_CRAZY_GAMES = M.GAME_TARGET == M.TARGETS.CRAZY_GAMES

M.CRYPTO_KEY = "CRYPTO KEY TO ENCRYPT STORAGE"

M.IS_TESTS = sys.get_config("tests.tests_run")

M.LOCALIZATION = {
	DEFAULT = sys.get_config("localization.default") or "en",
	USE_SYSTEM = (sys.get_config("localization.use_system") or "false") == "true",
	FORCE_LOCALE = sys.get_config("localization.force_locale")
}



M.GUI_ORDER = {
	FADER = 3,
	GAME = 2,
	MAIN_MENU = 4,
	MODAL = 5,
	TOP_PANEL = 6,
	FLY_OBJECTS = 10,
	DEBUG = 15,
}

M.Z_ORDER = {

}

M.TUNNEL_POINTS = 50

M.POWERUP_COLOR = lume.color_parse_hex("#2D93AD")
M.POWERUP_COLOR.w = 0.95

M.POWERUP_COLOR_PLAYER_GLOW = lume.color_parse_hex("#2D93AD")
M.POWERUP_COLOR_PLAYER_GLOW.w = 0.3

M.POWERUP_SPEED_COLOR_PLAYER_GLOW = lume.color_parse_hex("#FFF540")
M.POWERUP_SPEED_COLOR_PLAYER_GLOW.w = 0.3

M.SHINE_PLAYER_COLOR = lume.color_parse_hex("#FFEC51")
M.SHINE_PLAYER_COLOR.w = 0.7

M.START_RUN_CAMERA = 2


M.ADMOB = {
	TEST = {
		interstitial = "ca-app-pub-3940256099942544/1033173712",
		rewarded = "ca-app-pub-3940256099942544/5224354917"
	},
	BASE = {
		interstitial = "ca-app-pub-8047641499945529/6189114228",
		rewarded = "ca-app-pub-8047641499945529/6943545277"
	}
}


return M
