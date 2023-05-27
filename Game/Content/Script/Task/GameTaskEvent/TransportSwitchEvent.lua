-- ========================================================
-- @File    : TransportSwitchEvent.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================
---@class TransportSwitchEvent : GameTaskEvent
local TransportSwitchEvent = Class()

function TransportSwitchEvent:OnTrigger()
    self:FindTransporter()
    for i=1,self.Targets:Length() do
        self.Targets:Get(i):SetPause(self.Pause, self.OpenRight, self.OpenLeft, self.PointIndex)
    end
    self.Targets:Clear()
    return true
end

return TransportSwitchEvent
