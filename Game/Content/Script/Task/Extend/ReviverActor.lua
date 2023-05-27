-- ========================================================
-- @File    : ReviverActor.lua
-- @Brief   : 角色复活器
-- @Author  :
-- @Date    :
-- ========================================================

---@class ReviverActor : AActor
local ReviverActor = Class()

---开启
function ReviverActor:ReceiveActorBeginOverlap(OtherActor)
	if self:CanRevive(OtherActor) then
		EventSystem.Trigger(Event.OnInteractListAddItem, self.InteractWidgetClass ,1,self)
	end
end

---放弃
function ReviverActor:ReceiveActorEndOverlap(OtherActor)
	EventSystem.Trigger(Event.EndOverlapReviver, self)
end

return ReviverActor
