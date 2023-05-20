local COMMON = require("libs.common")
--Мини-игра "Найди провод"

---@class WireBlock
local WireBlock = COMMON.class("WireBlock")

function WireBlock:initialize(x, y)
    self.x = assert(x)
    self.y = assert(y)
    self:resetBlock()
end

function WireBlock:setupBlock(number, wireId, idx)
    self.wireType = assert(number)
    self.stepCount = self.stepCount + 1
    self.wires[self.stepCount] = { idx = assert(idx), wireId = assert(wireId) }
end

function WireBlock:resetBlock()
    self.wireType = 9
    self.stepCount = 0
    self.wires = {}
end

function WireBlock:__tostring()
    return string.format("WireBlock<type:%d, x:%d y:%d wires:%s>", self.wireType, self.x, self.y, COMMON.LUME.serialize(self.wires))
end

local SignalEnd = COMMON.class("SignalEnd")
function SignalEnd:initialize()
    self.setup = -1
    self.setup_2 = -1
    self.setup_3 = -1
end

function SignalEnd:setupBlock(setup, setup_2, setup_3)
    self.setup = assert(setup)
    self.setup_2 = assert(setup_2)
    self.setup_2 = assert(setup_3)
end

local M = COMMON.class("Wires")

function M:initialize()
    ---@type WireBlock[][]
    self._wires = {}
    self._signalsEnd = {}
    self.wireLengthArray = {}
    self.wireLengthArray[0] = 0
    self.wireLengthArray[1] = 0
    self.wireLengthArray[2] = 0

    self.changeWireCount = 0;
    self.crossCount = 0;
    self.wireBlocks = 0;
    self._signalsStand = 0;
    self._panelsWires = {}
end

function M:setUpWires()
    --Генерация проводов
    local blockWire = WireBlock(0, 0)
    local xDelta = 1
    local yDelta = 1

    self._signalsEnd[0] = SignalEnd()
    self._signalsEnd[1] = SignalEnd()
    self._signalsEnd[2] = SignalEnd()

    self._signalsStand = 0;

    --local currentWireToCut = math.floor(math.random() * 3);

    self.changeWireCount = 0;
    self.crossCount = 0;
    self.wireBlocks = 0;

    self.wireLengthArray[0] = 0;
    self.wireLengthArray[1] = 0;
    self.wireLengthArray[2] = 0;

    for i = 0, 8 - 1 do
        self._panelsWires = {};
        for j = 0, 8 - 1 do
            blockWire = WireBlock(xDelta, yDelta)
            self._panelsWires[j] = blockWire
            xDelta = xDelta + 1
        end
        self._wires[i] = self._panelsWires
        xDelta = 1
        yDelta = yDelta + 1
    end

    self.wireCount = 1;
    self.currentWireCount = 1;
    self.circleCount = 1;
    self.curDirection = 2;
    self.curPosition = vmath.vector3(1, 7, 0);
    self.prevPosition = self.curPosition;

    self._wires[self.curPosition.y][self.curPosition.x]:setupBlock(8, 0, 1);
    self._wires[7][3]:setupBlock(8, 1, 1);
    self._wires[7][5]:setupBlock(8, 2, 1);

    self.curPosition.y = self.curPosition.y - 1;

    while (self.wireCount < 4 and self.changeWireCount < 30) do
        self:addWireBlock();
    end

    self:buildWireAgain();

end

function M:buildWireAgain()
    if (self.wireCount < 4 or self.crossCount < 4 or self.wireBlocks < 36) then
        self:constructWires();
    else
        local cMax = self.wireLengthArray[0];
        local cNumMax = 0;

        if (self.wireLengthArray[1] > cMax) then
            cMax = self.wireLengthArray[1];
            cNumMax = 1;
        end

        if (self.wireLengthArray[2] > cMax) then
            cMax = self.wireLengthArray[1];
            cNumMax = 2;
        end

        self.currentWireToCut = cNumMax + 1;
        self._signalsEnd[cNumMax]:setupBlock(2, 0, 0);
    end
end

function M:addWireBlock()

    local wireSegment = math.floor(math.random() * 8 + 1)
    self.changeWireCount = self.changeWireCount + 1
    --Добрались до верха
    if (self.curPosition.y == 0) then
        --print("on top")
        if (self.curDirection == 1) then
            wireSegment = 4;
        end

        if (self.curDirection == 2) then
            wireSegment = 8;
        end

        if (self.curDirection == 3) then
            wireSegment = 3;
        end

        self.currentWireCount = self.currentWireCount + 1
        self._wires[self.curPosition.y][self.curPosition.x]:setupBlock(wireSegment, self._signalsStand, self.currentWireCount);

        self._signalsEnd[self._signalsStand]:setupBlock(1, self._wires[self.curPosition.y][self.curPosition.x].x,
                self._wires[self.curPosition.y][self.curPosition.x].y);
        self._signalsStand = self._signalsStand + 1;
        self.wireCount = self.wireCount + 1;
        self.currentWireCount = 1
        --        print("add wire count:" .. self.wireCount)

        if (self.wireCount == 2) then
            self.circleCount = math.floor(math.random() * 2 + 1);

            if (self.circleCount < 1) then
                self.circleCount = 1;
            end

            self.curDirection = 2;
            self.curPosition = vmath.vector3(3, 7, 0);
            self.curPosition.y = self.curPosition.y - 1;
        end

        if (self.wireCount == 3) then
            self.circleCount = math.floor(math.random() * 2 + 1);
            if (self.circleCount < 1) then
                self.circleCount = 1;
            end

            self.curDirection = 2;
            self.curPosition = vmath.vector3(5, 7, 0);
            self.curPosition.y = self.curPosition.y - 1;
        end
    end

    if (self:isValidWireSegment(self.curPosition, self.prevPosition, self.curDirection, wireSegment)) then
        self.currentWireCount = self.currentWireCount + 1
        self._wires[self.curPosition.y][self.curPosition.x]:setupBlock(wireSegment, self._signalsStand, self.currentWireCount);
        self.changeWireCount = 0;
        self.wireBlocks = self.wireBlocks + 1;

        if (self.wireCount == 1) then
            self.wireLengthArray[0] = self.wireLengthArray[0] + 1;
        end

        if (self.wireCount == 2) then
            self.wireLengthArray[1] = self.wireLengthArray[1] + 1;
        end

        if (self.wireCount == 3) then
            self.wireLengthArray[2] = self.wireLengthArray[2] + 1;
        end

        if (wireSegment == 5 or wireSegment == 6) then
            self.crossCount = self.crossCount + 1;
        end
        --Вычисляем направление
        if (wireSegment == 1) then
            if (self.curDirection == 2) then
                self.curDirection = 3;
            end
            if (self.curDirection == 1) then
                self.curDirection = 4;
            end
        end

        if (wireSegment == 2) then
            if (self.curDirection == 2) then
                self.curDirection = 1;
            end
            if (self.curDirection == 3) then
                self.curDirection = 4;
            end
        end

        if (wireSegment == 3) then
            if (self.curDirection == 4) then
                self.curDirection = 1;
            end
            if (self.curDirection == 3) then
                self.curDirection = 2;
            end
        end

        if (wireSegment == 4) then
            if (self.curDirection == 4) then
                self.curDirection = 3;
            end
            if (self.curDirection == 1) then
                self.curDirection = 2;
            end
        end

        -- ----------------------------------------------------------------------------------------------------

        if (self.curDirection == 2) then
            self.curPosition.y = self.curPosition.y - 1;
        end

        if (self.curDirection == 4) then
            self.curPosition.y = self.curPosition.y + 1;
            self.circleCount = self.circleCount + 1
        end

        if (self.curDirection == 1) then
            self.curPosition.x = self.curPosition.x - 1;
        end
        if (self.curDirection == 3) then
            self.curPosition.x = self.curPosition.x + 1;
        end
    else

    end
end

function M:isValidWireSegment(curPos, prevPos, curDir, numSegment)
    if (numSegment == 1) then
        if (curDir == 3 or curDir == 4) then
            return false;
        end

        if (self._wires[self.curPosition.y][self.curPosition.x].stepCount > 0) then
            return false;
        end

        if (curDir == 2 and curPos.x == 6) then
            return false;
        end

        if (curDir == 1 and curPos.y == 6) then
            return false;
        end

        -- Не пойдем вниз если уже есть петля
        if (curDir == 1 and (self.circleCount > 1 or curPos.x == 3 or curPos.x == 5)) then
            return false;
        end

        if (curDir == 2 and self._wires[self.curPosition.y][self.curPosition.x + 1].wireType < 8) then
            return false;
        end

        if (curDir == 1 and self._wires[self.curPosition.y + 1][self.curPosition.x].wireType < 7) then
            return false;
        end
    end

    -- ---------------------------------------------------------------------------------------------------
    if (numSegment == 2) then
        if (curDir == 1 or curDir == 4) then
            return false;
        end

        if (self._wires[self.curPosition.y][self.curPosition.x].stepCount > 0) then
            return false;
        end

        if (curDir == 2 and curPos.x == 0) then
            return false;
        end

        if (curDir == 3 and curPos.y == 6) then
            return false;
        end

        -- Не пойдем вниз если уже есть петля
        if (curDir == 3 and (self.circleCount > 1 or curPos.x == 3 or curPos.x == 5)) then
            return false;
        end

        if (curDir == 2 and self._wires[self.curPosition.y][self.curPosition.x - 1].wireType < 8) then
            return false;
        end

        if (curDir == 3 and self._wires[self.curPosition.y + 1][self.curPosition.x].wireType < 7) then
            return false;
        end
    end

    -- ---------------------------------------------------------------------------------------------------
    if (numSegment == 3) then

        if (curDir == 1 or curDir == 2) then
            return false;
        end

        if (self._wires[self.curPosition.y][self.curPosition.x].stepCount > 0) then
            return false;
        end

        if (curDir == 4 and curPos.x == 0) then
            return false;
        end

        if (curDir == 3 and curPos.y == 0) then
            return false;
        end

        if (curDir == 4 and self._wires[self.curPosition.y][self.curPosition.x - 1].wireType < 8) then
            return false;
        end

        if (curDir == 3 and self._wires[self.curPosition.y - 1][self.curPosition.x].wireType < 7) then
            return false;
        end
    end

    -- ---------------------------------------------------------------------------------------------------
    if (numSegment == 4) then

        if (curDir == 3 or curDir == 2) then
            return false;
        end

        if (self._wires[self.curPosition.y][self.curPosition.x].stepCount > 0) then
            return false;
        end

        if (curDir == 4 and curPos.x == 6) then
            return false;
        end

        if (curDir == 1 and curPos.y == 0) then
            return false;
        end

        if (curDir == 4 and self._wires[self.curPosition.y][self.curPosition.x + 1].wireType < 8) then
            return false;
        end

        if (curDir == 1 and self._wires[self.curPosition.y - 1][self.curPosition.x].wireType < 7) then
            return false;
        end
    end

    -- ---------------------------------------------------------------------------------------------------
    if (numSegment == 5 or numSegment == 8) then
        if (curDir == 1 or curDir == 3) then
            return false;
        end

        if (self._wires[self.curPosition.y][self.curPosition.x].stepCount == 1 and numSegment == 8) then
            return false;
        end

        if (self._wires[self.curPosition.y][self.curPosition.x].stepCount == 0 and numSegment == 5) then
            return false; end

        if (curDir == 2 and curPos.y == 0) then
            return false;
        end

        if (curDir == 4 and curPos.y == 6) then
            return false;
        end

        if (curDir == 2 and self._wires[self.curPosition.y - 1][self.curPosition.x].wireType < 7) then
            return false;
        end

        if (curDir == 4 and self._wires[self.curPosition.y + 1][self.curPosition.x].wireType < 7) then
            return false;
        end
    end

    -- ---------------------------------------------------------------------------------------------------
    if (numSegment == 6 or numSegment == 7) then
        if (curDir == 2 or curDir == 4) then
            return false;
        end

        if (self._wires[self.curPosition.y][self.curPosition.x].stepCount == 1 and numSegment == 7) then
            return false; end

        if (self._wires[self.curPosition.y][self.curPosition.x].stepCount == 0 and numSegment == 6) then
            return false; end

        if (curDir == 1 and curPos.x == 0) then
            return false;
        end

        if (curDir == 3 and curPos.x == 6) then
            return false;
        end

        if (curDir == 1 and self._wires[self.curPosition.y][self.curPosition.x - 1].wireType < 8) then
            return false;
        end

        if (curDir == 3 and self._wires[self.curPosition.y][self.curPosition.x + 1].wireType < 8) then
            return false;
        end
    end

    return true

end

function M:constructWires()

    self._signalsStand = 0
    for i = 0, 8 - 1 do
        for j = 0, 8 - 1 do
            self._wires[j][i]:resetBlock();
        end
    end

    self.changeWireCount = 0;
    self.crossCount = 0;
    self.wireBlocks = 0;

    self.wireLengthArray[0] = 0;
    self.wireLengthArray[1] = 0;
    self.wireLengthArray[2] = 0;

    self.wireCount = 1;
    self.circleCount = 1;
    self.currentWireCount = 1;
    self.curDirection = 2;
    self.curPosition = vmath.vector3(1, 7, 0);
    self.prevPosition = self.curPosition;

    self._wires[self.curPosition.y][self.curPosition.x]:setupBlock(8, 0, 1);
    self._wires[7][3]:setupBlock(8, 1, 1);
    self._wires[7][5]:setupBlock(8, 2, 1);

    self.curPosition.y = self.curPosition.y - 1;

    while (self.wireCount < 4 and self.changeWireCount < 40) do
        self:addWireBlock();
    end

    self:buildWireAgain();

end

return M

