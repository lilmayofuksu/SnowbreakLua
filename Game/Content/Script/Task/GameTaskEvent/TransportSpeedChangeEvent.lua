-- ========================================================
-- @File    : TransportSpeedChangeEvent.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================
---@class TransportSpeedChangeEvent : GameTaskEvent
local TransportSpeedChangeEvent = Class()

function TransportSpeedChangeEvent:OnTrigger()
    self:FindTransporter()
    for i=1,self.Targets:Length() do
        if self.Speed > 0 then
            self.Targets:Get(i):UpdateSpeed(self.Speed)
        end
    end
    self.Targets:Clear()
    return true
end

return TransportSpeedChangeEvent
