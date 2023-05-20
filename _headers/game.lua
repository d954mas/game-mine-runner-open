game = {}

---@class GameNativeTunnel
local GameNativeTunnel = {

}


function GameNativeTunnel:BufferInit() end
function GameNativeTunnel:BufferGetContentVersion() end
function GameNativeTunnel:BufferIsValid() end
function GameNativeTunnel:GetBuffer() end
function GameNativeTunnel:GetTunnelInfo() end
function GameNativeTunnel:SetAngles(angles) end
function GameNativeTunnel:SetPoints(points) end
function GameNativeTunnel:SetPlaneSize(size) end
function GameNativeTunnel:SetPlaneColor(segment_idx,plane_idx,r,g,b,a) end
function GameNativeTunnel:Destroy() end

---@return GameNativeTunnel
function game.create_tunnel() end