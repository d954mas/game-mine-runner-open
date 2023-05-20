local DEFS = require "world.balance.def.defs"
local COMMON = require "libs.common"

local M = COMMON.class("Highscores")

---@param world World
function M:initialize(world)
	self.world = assert(world)
	self.highscores_by_world = {}
	self:init_highscores()
end

function M:highscores_load(world_id)
	print("highscores load")
	local data = assert(self.highscores_by_world[world_id])
	if (self.world.sdk.is_yandex) then
		if (data.status == "load") then
			data.status = "loading"
			self.world.sdk.yagames_sdk:leaderboard_load_world_highscore(world_id, function(status, result)
				data.status = "load"

				if (not status) then
					print("highscores load failed")
					if (self.world.storage.game:world_id_get() == world_id
							and COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.MENU_GUI)) then
						local ctx = COMMON.CONTEXT:set_context_top_menu_gui()
						ctx.data:highscore_update()
						ctx:remove()
					end
					return
				end
				print("highscores load success")
				pprint(result)

				local player_data
				--remove all not player and not bot
				for i = #data.list, 1, -1 do
					local current_enrty = data.list[i]
					if (not current_enrty.bot or not current_enrty.player) then
						--remove prev ya score
						pprint(table.remove(data.list[i]))
					end
					if (current_enrty.player) then
						player_data = current_enrty
					end
				end
				player_data.userRank = result.userRank
				for _, entry in ipairs(result.entries) do
					local score = entry.score
					local url = entry.player.getAvatarSrc
					local name = entry.player.publicName
					local userRank = entry.player.userRank
					if (entry.rank == player_data.userRank) then
						player_data.name = name
						player_data.url = url
					else
						table.insert(data.list, {
							name = name, score = score,
							icon = "empty", url = url,
							userRank = userRank
						})
					end
				end

				if (self.world.storage.game:world_id_get() == world_id
						and COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.MENU_GUI)) then
					local ctx = COMMON.CONTEXT:set_context_top_menu_gui()
					ctx.data:highscore_update()
					ctx:remove()
				end
			end)
		end
	end
end

function M:init_highscores()
	local player_name = COMMON.LOCALIZATION.player_name()

	for _, world in ipairs(DEFS.WORLDS.WORLD_LIST) do
		local list = COMMON.LUME.clone_shallow(DEFS.HIGHSCORES.by_world[world.id])
		local player_score = {
			name = player_name, score = 0,
			icon = DEFS.SKINS.SKINS_BY_ID.MINE.icon, player = true
		}
		table.insert(list, player_score)
		self.highscores_by_world[world.id] = { list = list, status = "load" }
	end
end

function M:get_highscores_by_world(world_id)
	local data = self.highscores_by_world[world_id]
	local player_entry
	for _, entry in ipairs(data.list) do
		if (entry.player) then
			player_entry = entry
			entry.score = self.world.storage.game:highscore_get(world_id)
			entry.icon = DEFS.SKINS.SKINS_BY_ID[self.world.storage.game:skin_get()].icon
		end
	end
	table.sort(data.list, function(a, b)
		return a.score > b.score
	end)
	for idx, entry in ipairs(data.list) do
		entry.position = idx
	end

	local result = { status = data.status, list = {} }
	for i = 1, 10 do
		table.insert(result.list, data.list[i])
	end
	if (player_entry.position > 10) then
		if (player_entry.userRank) then
			if (player_entry.userRank ~= 0) then
				player_entry.position = math.max(player_entry.userRank, 10)
				result.list[10] = player_entry
			end
		else
			player_entry.position = 10
			result.list[10] = player_entry
		end

	end

	return result
end

return M