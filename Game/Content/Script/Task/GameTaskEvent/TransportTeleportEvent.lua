-- ========================================================
-- @File    : TransportTeleportEvent.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================
---@class TransportTeleportEvent : GameTaskEvent
local TransportTeleportEvent = Class()

function TransportTeleportEvent:OnTrigger()
    self:FindTransporter()
    local point = UE4.ULevelLibrary.GetActorByName(self, UE4.ANPCSpawnPoint.StaticClass(), self.PointName)
    if point then
    	for i=1,self.Targets:Length() do
    		local one = self.Targets:Get(i)
	        one:K2_SetActorLocationAndRotation(point:K2_GetActorLocation(), point:K2_GetActorRotation())
	        one:ResetState()
	    end
    end
    self.Targets:Clear()
    return true
end

return TransportTeleportEvent
