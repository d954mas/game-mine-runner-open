local COMMON = require "libs.common"

---@class StoragePartBase
local Part = COMMON.class("StoragePartBase")

---@param storage Storage
function Part:initialize(storage)
    checks("?", "class:Storage")
    self.storage = storage
    self.world = assert(storage.world)
end

function Part:save(force)
    self.storage:save(force)
end

function Part:changed()
    self.storage:changed()
end

function Part:save_and_changed()
    self:save()
    self:changed()
end

return Part