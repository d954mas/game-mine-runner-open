local M = {}
local LOG = require "libs.log"

local COR_RESUME = coroutine.resume
local COR_STATUS = coroutine.status
local COR_YIELD = coroutine.yield

---@return coroutine|nil return coroutine if it can be resumed(no errors and not dead)
function M.coroutine_resume(cor,...)
	local ok, res = COR_RESUME(cor,...)
	if not ok then
		pprint("ERROR")
		LOG.w(res .. debug.traceback(cor,"",1),"Error in coroutine",1)
	else
		return not (COR_STATUS(cor) == "dead") and cor
	end
end

function M.coroutine_wait(time)
	assert(time)
	local dt = 0
	while dt<time do
		dt = dt + COR_YIELD()
	end
end

return M