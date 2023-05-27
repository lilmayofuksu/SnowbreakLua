-- ========================================================
-- @File    : SpawnAreaStaticActorEvent.lua
-- @Brief   :
-- @Author  :
-- @Date    :
-- ========================================================

---@class SpawnAreaStaticActorEvent : SpawnMonsterBaseEvent
local SpawnAreaStaticActorEvent = Class()

---执行事件
function SpawnAreaStaticActorEvent:OnTrigger()
    local TaskActor = self:GetGameTaskActor()
    UE4.ULevelLibrary.SpawnAreaStaticActor(self, TaskActor.AreaId)
    return true
end

return SpawnAreaStaticActorEvent
