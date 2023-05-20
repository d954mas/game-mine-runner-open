local COMMON = require "libs.common"
local CONSTANTS = require "libs.constants"
local JSON = require "libs.json"
local DEFS = require "world.balance.def.defs"
local OptionsStoragePart = require "world.storage.options_storage_part"
local DebugStoragePart = require "world.storage.debug_storage_part"
local GameStoragePart = require "world.storage.game_storage_part"
local SkinsStoragePart = require "world.storage.skins_storage_part"
local UpgradesStoragePart = require "world.storage.upgrades_storage_part"
local TasksStoragePart = require "world.storage.tasks_storage_part"
local CRYPTO = require "libs.crypto"
local BASE64 = require "libs.base64"

local TAG = "Storage"

---@class Storage
local Storage = COMMON.class("Storage")

Storage.FILE_PATH = "d954mas_mine_runner"
Storage.VERSION = 27
Storage.AUTOSAVE = -1 --seconds
Storage.CLEAR = CONSTANTS.VERSION_IS_DEV and false --BE CAREFUL. Do not use in prod
Storage.LOCAL = CONSTANTS.VERSION_IS_DEV and CONSTANTS.PLATFORM_IS_PC
		and CONSTANTS.TARGET_IS_EDITOR and true --BE CAREFUL. Do not use in prod

---@param world World
function Storage:initialize(world)
	checks("?", "class:World")
	self.world = world
	local status, error = pcall(self._load_storage, self)
	if (not status) then
		COMMON.i("error load storage:" .. tostring(error), TAG)
		self:_init_storage()
		self:_migration()
		self:_on_load()
		self:save(true)
	end
	self.prev_save_time = socket.gettime()
	self.save_on_update = false

	self:update_data()
end

function Storage:update_data()
	self.options = OptionsStoragePart(self)
	self.debug = DebugStoragePart(self)
	self.game = GameStoragePart(self)
	self.skins = SkinsStoragePart(self)
	self.upgrades = UpgradesStoragePart(self)
	self.tasks = TasksStoragePart(self)
end

function Storage:changed()
	self.change_flag = true
end

function Storage:_get_path()
	if (Storage.LOCAL) then
		return "./" .. "storage.json"
	end
	local path = Storage.FILE_PATH
	if (CONSTANTS.VERSION_IS_DEV) then
		path = path .. "_dev"
	end
	if (html5) then
		return path
	end
	return sys.get_save_file(path, "storage.json")
end

function Storage:_load_storage()
	local path = self:_get_path()
	local data = nil
	if (Storage.CLEAR) then
		COMMON.i("clear storage", TAG)
	else
		if (html5) then
			local html_data = html5.run([[(function(){try{return window.localStorage.getItem(']] .. path .. [[')||'{}'}catch(e){return'{}'}})()]])
			if (not html_data or html_data == "{}" or html_data == "nil") then
				COMMON.i("html5 data. Empty or error:" .. tostring(html_data), TAG)
			else
				COMMON.i("html5 data:" .. tostring(html_data), TAG)
				local status_json, file_data = pcall(JSON.decode, html_data)
				if (not status_json) then
					COMMON.i("can't parse json:" .. tostring(file_data), TAG)
				else
					data = file_data
				end
			end


		else
			local status, file = pcall(io.open, path, "r")
			if (not status) then
				COMMON.i("can't open file:" .. tostring(file), TAG)
			else
				if (file) then
					COMMON.i("load", TAG)
					local contents, read_err = file:read("*a")
					if (not contents) then
						COMMON.i("can't read file:\n" .. read_err, TAG)
					else
						COMMON.i("from file:\n" .. contents, TAG)
						local status_json, file_data = pcall(JSON.decode, contents)
						if (not status_json) then
							COMMON.i("can't parse json:" .. tostring(file_data), TAG)
						else
							data = file_data
						end
					end
					file:close()
				else
					COMMON.i("no file", TAG)
				end
			end
		end
	end

	if (data) then
		if (data.encrypted) then
			data.data = BASE64.decode(data.data)
			data = CRYPTO.crypt(data.data, CONSTANTS.CRYPTO_KEY)
		else
			data = data.data
		end

		local result, storage = pcall(JSON.decode, data)
		if (result) then
			self.data = assert(storage)
		else
			COMMON.i("can't parse json:" .. tostring(storage), TAG)
			self:_init_storage()
		end
		COMMON.i("data:\n" .. tostring(data), TAG)
	else
		COMMON.i("no data.Init storage", TAG)
		self:_init_storage()
	end

	self:_migration()
	self:_on_load()
	self:save(true)
	COMMON.i("loaded", TAG)
end

function Storage:update(dt)
	self.game.game.last_time = socket.gettime()

	if (self.change_flag) then
		self.world:on_storage_changed()
		COMMON.EVENT_BUS:event(COMMON.EVENTS.STORAGE_CHANGED)
		self.change_flag = false
	end
	if (self.save_on_update) then
		self:save(true)
	end
	if (Storage.AUTOSAVE and Storage.AUTOSAVE ~= -1) then
		if (socket.gettime() - self.prev_save_time > Storage.AUTOSAVE) then
			COMMON.i("autosave", TAG)
			self:save(true)
		end
	end

end

function Storage:_init_storage()
	COMMON.i("init new", TAG)
	---@class StorageData
	local data = {
		debug = {
			developer = false,
			draw_debug_info = false,
		},
		options = {
			sound = true,
			music = true
		},
		game = {
			tutorial_completed = false,
			world_id = DEFS.WORLDS.WORLDS_BY_ID.MINE_WORLD.id,
			stars = 1,
			gems = 0,
			gems_game = 0, --save gems in lose scene
			highscore = { },
			gems_daily = {
				['1'] = { have = false },
				['2'] = { have = false },
				['3'] = { have = false },
				last_time = 0
			},
			skin = DEFS.SKINS.SKINS_BY_ID.MINE.id
		},
		skins = {

		},
		upgrades = {

		},
		tasks = {
			tasks_idx = 1,
			tasks = {
				{ completed = false, value = 0 },
				{ completed = false, value = 0 },
				{ completed = false, value = 0 },
			}

		},
		time = socket.gettime(),
		version = Storage.VERSION
	}
	for _, skin in pairs(DEFS.SKINS.SKINS_BY_ID) do
		data.skins[skin.id] = { have = skin.price == 0 }
	end

	for _, upgrade in pairs(DEFS.POWERUPS) do
		data.upgrades[upgrade.id] = { level = 1 }
	end

	for _, world in pairs(DEFS.WORLDS.WORLDS_BY_ID) do
		data.game.highscore[world.id] = 0
	end

	self.data = data
end

function Storage:reset()
	self:_init_storage()
	self:update_data()
	self:__save()
	self:changed()
end

function Storage:_migration()
	if (self.data.version < Storage.VERSION) then
		COMMON.i(string.format("migrate from:%s to %s", self.data.version, Storage.VERSION), TAG)

		if (self.data.version < 23) then
			self:_init_storage()
		end

		if (self.data.version < 24) then
			self.data.game.world_id = DEFS.WORLDS.WORLDS_BY_ID.MINE_WORLD.id
		end

		if (self.data.version < 25) then
			local highscore = self.data.game.highscore
			self.data.game.highscore = {}
			for _, world in pairs(DEFS.WORLDS.WORLDS_BY_ID) do
				self.data.game.highscore[world.id] = 0
			end
			self.data.game.highscore[DEFS.WORLDS.WORLDS_BY_ID.MINE_WORLD.id] = highscore
		end
		if (self.data.version < 26) then
			self.data.game.highscore[DEFS.WORLDS.WORLDS_BY_ID.GRASS_WORLD.id] = 0
			if (self.data.game.tutorial_completed and self.data.tasks.tasks_idx == 1) then
				self.data.tasks.tasks[1].completed = true
			end
		end
		if (self.data.version < 27) then
			self.data.time = socket.gettime()
		end

		self.data.version = Storage.VERSION
	end
end

function Storage:_on_load()
	if (self.data.game.gems_game ~= 0) then
		self.data.game.gems = self.data.game.gems + self.data.game.gems_game
		self.data.game.gems_game = 0
	end
end

function Storage:__save()
	if (self.data.time) then
		self.data.time = socket.gettime()
	end
	local data = {
		data = JSON.encode(self.data),
	}
	data.encrypted = not Storage.LOCAL

	if (data.encrypted) then
		data.data = BASE64.encode(CRYPTO.crypt(data.data, CONSTANTS.CRYPTO_KEY))
	end

	local encoded_data = JSON.encode(data, false)
	encoded_data:gsub("'", "\'") -- escape ' character
	if (html5) then
		html5.run("try{window.localStorage.setItem('" .. self:_get_path() .. "', '" .. encoded_data .. "')}catch(e){}")
	else
		local file = io.open(self:_get_path(), "w+")
		-- encoded_data = BASE64.encode(encoded_data)
		file:write(encoded_data)
		file:close()
	end
end

function Storage:save(force)
	if (force) then
		COMMON.i("save", TAG)
		self.prev_save_time = socket.gettime()
		local status, error = pcall(self.__save, self)
		if (not status) then
			COMMON.i("error save storage:" .. tostring(error), TAG)
		end
		self.save_on_update = false
		COMMON.EVENT_BUS:event(COMMON.EVENTS.STORAGE_SAVED)
	else
		self.save_on_update = true
	end
end

return Storage

