local I18N = require "libs.i18n.init"
local LOG = require "libs.log"
local CONSTANTS = require "libs.constants"
local TAG = "LOCALIZATION"
local LUME = require "libs.lume"
local LOCALES = { "en", "ru" }
local DEFAULT = CONSTANTS.LOCALIZATION.DEFAULT
local FALLBACK = DEFAULT

---@class Localization
local M = {
	level = { en = "%{level}", ru = "%{level}" },
	MINE_WORLD_title = { en = "OLD MINE", ru = "ПОДЗЕМЕЛЬЕ" },
	GRASS_WORLD_title = { en = "GRASSLAND", ru = "ЛУГ" },
	DARK_WORLD_title = { en = "DARKNESS", ru = "ТЬМА" },
	TOON_WORLD_title = { en = "TOON WORLD", ru = "МУЛЬТЯШНЫЙ" },
	METAL_WORLD_title = { en = "METAL CAVE", ru = "ЖЕЛЕЗЯКА" },
	btn_play = { en = "PLAY", ru = "ИГРАТЬ" },
	highscore_title = { en = "HIGHSCORES", ru = "РЕКОРДЫ" },
	tasks_title = { en = "TASKS", ru = "ЗАДАЧИ" },
	daily_description_find_all = { en = "FIND ALL TO GET REWARD", ru = "СОБЕРИ ВСЕ ДЛЯ НАГРАДЫ" },
	daily_description_click_to_collect = { en = "CLICK TO COLLECT", ru = "НАЖМИ ЧТОБЫ СОБРАТЬ" },
	daily_wait = { en = "WAIT", ru = "ПОДОЖДИТЕ" },
	name_King = { en = "King", ru = "Король" },
	name_Robot = { en = "Robot", ru = "Робот" },
	name_Superhero = { en = "Superhero", ru = "Супергерой" },
	name_Vampire = { en = "Vampire", ru = "Вампир" },
	name_Adventurer = { en = "Adventurer", ru = "Археолог" },
	name_Explorer = { en = "Explorer", ru = "Авантюрист" },
	name_Zombie = { en = "Zombie", ru = "Зомби" },
	name_Skeleton = { en = "Skeleton", ru = "Скелет" },
	name_Alice = { en = "Alice", ru = "Алиса" },
	name_Steve = { en = "Steve", ru = "Стивен" },
	name_Cat = { en = "Cat", ru = "Кот" },
	name_Golem = { en = "Golem", ru = "Голем" },
	player_name = { en = "You", ru = "Вы" },

	task_COLLECT_COINS_RUN = { en = "Collect %{count} gems in one run.", ru = "Собери %{count} самоцветов за один забег." },
	task_COLLECT_COINS_TOTAL = { en = "Collect %{count} gems", ru = "Собери %{count} самоцветов." },
	task_RUN_POINTS_RUN = { en = "Collect %{count} points in one run.", ru = "Набери %{count} очков за один забег." },
	task_RUN_POINTS_TOTAL = { en = "Collect %{count} points.", ru = "Набери %{count} очков." },
	task_PLAY_RUN = { en = {
		other = "Start %{count} runs.",
	}, ru = {
		other = "Начни %{count} забегов.",
		many = "Начни %{count} забегов.",
		few = "Начни %{count} забега.",
	} },
	task_COLLECT_POWER_UPS_TOTAL = { en = "Collect %{count} powerups.", ru = {
		few = "Собери %{count} бонуса",
		many = "Собери %{count} бонусов",
		other = "Собери %{count} бонусов."
	} },
	task_COLLECT_POWER_UPS_MAGNET_TOTAL = { en = "Collect %{count} magnets.", ru = {
		few = "Собери %{count} магнита",
		many = "Собери %{count} магнитов",
		other = "Собери %{count} магнитов."
	} },
	task_COLLECT_POWER_UPS_SPEED_TOTAL = { en = "Collect %{count} lightnings.", ru = "Собери %{count} молний." },
	task_COLLECT_COLLECT_POWER_UPS_X2_TOTAL = { en = "Collect %{count} x2.", ru = "Собери %{count} x2." },
	task_CHANGE_SKIN = { en = "Change skin.", ru = "Смени скин." },
	task_COMPLETE_DAILY_GEMS = { en = {
		one = "Complete %{count} amulet.",
		other = "Complete %{count} amulets.",
	}, ru = {
		one = "Собери %{count} амулет.",
		few = "Собери %{count} амулета.",
		other = "Собери %{count} амулетов.",
	} },
	task_COMPLETE_TUTORIAL = { en = "Complete tutorial.", ru = "Заверши обучение." },

	task_skip = { en = "Skip this task", ru = "Пропустить задачу" },
	task_completed = { en = "Completed", ru = "Выполнено" },
	tasks_reward_title = { en = "REWARD", ru = "НАГРАДА" },
	tasks_reward_btn_collect = { en = "COLLECT", ru = "ЗАБРАТЬ" },
	skins_title = { en = "SKINS", ru = "CКИНЫ" },
	upgrades_title = { en = "UPGRADES", ru = "УЛУЧШЕНИЯ" },
	offer_title = { en = "MORE GEMS", ru = "ПОЛУЧИ" },
	offer_btn_text = { en = "Click Here!", ru = "Посмотреть" },
	btn_unlock_ads_lbl = { en = "UNLOCK", ru = "ОТКРЫТЬ" },
	btn_skin_use_lbl = { en = "SELECT", ru = "ВЫБРАТЬ" },

	upgrade_RUN_title = { en = "RUN", ru = "УСКОРЕНИЕ" },
	upgrade_RUN_description = { en = "Fast run, destroy obstacles", ru = "Больше скорость, неуязвимость" },

	upgrade_MAGNET_title = { en = "MAGNET", ru = "МАГНИТ" },
	upgrade_MAGNET_description = { en = "Collects all gems nearby", ru = "Притягивает предметы" },

	upgrade_STAR_title = { en = "X2", ru = "X2" },
	upgrade_STAR_description = { en = "Double the score", ru = "Удваивает очки" },

	upgrade_MORE_GEMS_title = { en = "MORE GEMS", ru = "ПРИБЫЛЬ" },
	upgrade_MORE_GEMS_description = { en = "More gems in run and rewards", ru = "Больше самоцветов" },

	upgrade_MORE_GEMS_description2 = { en = "Reward x%{count}", ru = "Награда x%{count}" },
	upgrade_DURATION_description2 = { en = "Duration %{count} sec.", ru = "Время %{count} сек." },

	pause_btn_continue = { en = "RESUME", ru = "ИГРАТЬ" },
	pause_btn_menu = { en = "MENU", ru = "МЕНЮ" },
	pause_title = { en = "PAUSE", ru = "ПАУЗА" },
	revive_title = { en = "SAVE ME", ru = "СПАСТИ" },
	revive_btn_title = { en = "Revive!", ru = "Возродить!" },
	lose_title = { en = "LOSE", ru = "ПРОИГРЫШ" },
	lose_score_title = { en = "SCORE", ru = "ОЧКИ" },
	lose_new_score_title = { en = "NEW HIGHSCORE!!!", ru = "НОВЫЙ РЕКОРД!!!" },
	lose_x2_gems_title = { en = "Double gems!", ru = "УДВОИТЬ!" },
	btn_restart_lbl = { en = "RESTART", ru = "ПОВТОРИТЬ" },
	notification_mission_title = { en = "Task completed", ru = "Задача выполнена" },
	notification_gem_title = { en = "Gem Found", ru = "Найден" },

	login_auth = { en = "LOGIN TO SAVE DATA", ru = "АВТОРИЗУЙТЕСЬ, ЧТОБЫ СОХРАНИТЬ ИГРУ" },
	login_name = { en = "LOGIN TO USE NAME", ru = "АВТОРИЗУЙТЕСЬ, ЧТОБЫ ИСПОЛЬЗОВАТЬ ИМЯ" },

	need_stars_title_1 = { en = "NEED", ru = "НУЖНО" },
	need_stars_title_2 = { en = "TO RUN", ru = "ДЛЯ ЗАБЕГА" },

}

function M:locale_exist(key)
	local locale = self[key]
	if not locale then
		LOG.w("key:" .. key .. " not found", TAG, 2)
	end
end

function M:set_locale(locale)
	LOG.w("set locale:" .. locale, TAG)
	I18N.setLocale(locale)
end

function M:locale_get()
	return I18N.getLocale()
end

I18N.setFallbackLocale(FALLBACK)
M:set_locale(DEFAULT)
if (CONSTANTS.LOCALIZATION.FORCE_LOCALE) then
	LOG.i("force locale:" .. CONSTANTS.LOCALIZATION.FORCE_LOCALE, TAG)
	M:set_locale(CONSTANTS.LOCALIZATION.FORCE_LOCALE)
elseif (CONSTANTS.LOCALIZATION.USE_SYSTEM) then
	local system_locale = sys.get_sys_info().language
	LOG.i("system locale:" .. system_locale, TAG)
	if (LUME.findi(LOCALES, system_locale)) then
		M:set_locale(system_locale)
	else
		LOG.i("unknown system locale:" .. system_locale, TAG)
		pprint(LOCALES)
	end

end

for _, locale in ipairs(LOCALES) do
	local table = {}
	for k, v in pairs(M) do
		if type(v) ~= "function" then
			table[k] = v[locale]
		end
	end
	I18N.load({ [locale] = table })
end

for k, v in pairs(M) do
	if type(v) ~= "function" then
		M[k] = function(data)
			return I18N(k, data)
		end
	end
end

--return key if value not founded
---@type Localization
local t = setmetatable({ __VALUE = M, }, {
	__index = function(_, k)
		local result = M[k]
		if not result then
			LOG.w("no key:" .. k, TAG, 2)
			result = function() return k end
			M[k] = result
		end
		return result
	end,
	__newindex = function() error("table is readonly", 2) end,
})

return t
