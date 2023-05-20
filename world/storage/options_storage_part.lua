local COMMON = require "libs.common"
local StoragePart = require "world.storage.storage_part_base"

---@class StoragePartOptions:StoragePartBase
local Options = COMMON.class("StorageOptions",StoragePart)

function Options:initialize(...)
    StoragePart.initialize(self,...)
    self.options = self.storage.data.options
end


function Options:sound_set(enable)
    checks("?","boolean")
    self.options.sound = enable
    self:save_and_changed()
end

function Options:sound_get() return self.options.sound end

function Options:music_set(enable)
    checks("?","boolean")
    self.options.music = enable
    self:save_and_changed()
end
function Options:music_get() return self.options.music end

return Options