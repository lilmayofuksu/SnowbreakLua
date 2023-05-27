-- ========================================================
-- @File    : RemoveBuffMakerEvent.lua
-- @Brief   : 移除buff maker
-- @Author  :
-- @Date    :
-- ========================================================
---@class RemoveBuffMakerEvent : GameTaskEvent
local RemoveBuffMakerEvent = Class()

function RemoveBuffMakerEvent:OnTrigger()
	local buffId = self.ModifierID
    local TaskActor = self:GetGameTaskActor()
    if self.MultType then
        if self.RandomMonster then
        	local RandomCfg = UE4.UTaskRandomSubsystem.GetBattleRandomMonster(TaskActor, TaskActor.AreaId)
        	if RandomCfg then
        		buffId = RandomCfg.BufferId
        	end
        else
        	self.challengeCfg = UE4.UTaskRandomSubsystem.GetBattleChallange(TaskActor, TaskActor.AreaId)
	        if self.challengeCfg then
	        	buffId = self.challengeCfg.BufferId
	       	end
        end
    end

    if buffId == 0 then return false end

    TaskActor:RemoveBufferMaker(buffId)
    return true
end

return RemoveBuffMakerEvent
