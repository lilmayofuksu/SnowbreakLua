-- ========================================================
-- @File    : ClearBuffEvent.lua
-- @Brief   : 添加buff
-- @Author  :
-- @Date    :
-- ========================================================
---@class ClearBuffEvent : GameTaskEvent
local ClearBuffEvent = Class()

function ClearBuffEvent:OnTrigger()
    if self.MultType then
        local TaskActor = self:GetGameTaskActor()
        self.challengeCfg = UE4.UTaskRandomSubsystem.GetBattleChallange(TaskActor, TaskActor.AreaId)
    end
    
    local buffId = self.challengeCfg and self.challengeCfg.BufferId or self.ModifierID
    UE4.ULevelLibrary.RemoveBuff(self, buffId, self.CastToPlayer)
    return true
end

return ClearBuffEvent
