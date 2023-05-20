local COMMON = require "libs.common"
local GUI = require "libs_project.gui.gui"
local WORLD = require "world.world"

---@class SoundMusicGuiScriptBase
local Script = COMMON.new_n28s()

function Script:bind_vh()
    self.vh = {}
    self.view = {
        btn_sound = GUI.ButtonScale("btn_sound"),
        btn_music = GUI.ButtonScale("btn_music"),
    }
    self.view.btn_sound.vh.icon = gui.get_node("btn_sound/icon")
    self.view.btn_music.vh.icon = gui.get_node("btn_music/icon")
    self.view.btn_sound.vh.cross = gui.get_node("btn_sound/cross")
    self.view.btn_music.vh.cross = gui.get_node("btn_music/cross")
end

function Script:init_gui()
    self.view.btn_music:set_input_listener(function()
        WORLD.storage.options:music_set(not WORLD.storage.options:music_get())
    end)
    self.view.btn_sound:set_input_listener(function()
        WORLD.storage.options:sound_set(not WORLD.storage.options:sound_get())
    end)
end

function Script:on_storage_changed()
    gui.set_enabled(self.view.btn_sound.vh.cross,not WORLD.storage.options:sound_get() )
    gui.set_enabled(self.view.btn_music.vh.cross,not WORLD.storage.options:music_get() )
end

function Script:init()
    self:bind_vh()
    self.subscription = COMMON.RX.SubscriptionsStorage()
    self.scheduler = COMMON.RX.CooperativeScheduler.create()
    self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.STORAGE_CHANGED):go_distinct(self.scheduler):subscribe(function()
        self:on_storage_changed()
    end))
    self:init_gui()
    self:on_storage_changed()
end

function Script:on_input(action_id, action)
    if (self.view.btn_music:on_input(action_id, action)) then return true end
    if (self.view.btn_sound:on_input(action_id, action)) then return true end
end

function Script:update(dt)
    self.scheduler:update(dt)
end

function Script:final()
    self.subscription:unsubscribe()
end


return Script