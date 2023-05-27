-- ========================================================
-- @File    : TransportUpdateTrackEvent.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================
---@class TransportUpdateTrackEvent : GameTaskEvent
local TransportUpdateTrackEvent = Class()

function TransportUpdateTrackEvent:OnTrigger()
    self:FindTransporter()
	for i=1,self.Targets:Length() do
		local one = self.Targets:Get(i)
        one:UpdateRunTrack(self.TrackName)
    end
    self.Targets:Clear()
    return true
end

return TransportUpdateTrackEvent
