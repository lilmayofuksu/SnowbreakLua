-- ========================================================
-- @File    : PlayerTombstone.lua
-- @Brief   : 玩家角色死亡后生成墓碑
-- @Author  :
-- @Date    :
-- ========================================================

---@class ReviverActor : AActor
local PlayerTombstone = Class()

---开启
-- function PlayerTombstone:ReceiveActorBeginOverlap(OtherActor)
-- 	if self:CanRevive(OtherActor) then
-- 		EventSystem.Trigger(Event.OnInteractListAddItem, self.InteractWidgetClass ,1,self)
-- 	end
-- end

---放弃
-- function PlayerTombstone:ReceiveActorEndOverlap(OtherActor)
-- 	EventSystem.Trigger(Event.EndOverlapTombstone, self)
-- end

return PlayerTombstone
