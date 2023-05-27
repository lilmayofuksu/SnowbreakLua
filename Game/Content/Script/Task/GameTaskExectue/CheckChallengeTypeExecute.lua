-- ========================================================
-- @File    : CheckChallengeTypeExecute.lua
-- @Brief   : 检查挑战类型
-- @Author  :
-- @Date    :
-- ========================================================

---@class CheckChallengeTypeExecute : TaskItem
local CheckChallengeTypeExecute = Class()

function CheckChallengeTypeExecute:OnActive()
	local TaskActor = self:GetGameTaskActor()
    self.challengeCfg = UE4.UTaskRandomSubsystem.GetBattleChallange(TaskActor, TaskActor.AreaId)

    if self.ChallengeType == self.challengeCfg.TaskType then
    	self:Finish()
    end
end

function CheckChallengeTypeExecute:OnActive_Client()
    
end

function CheckChallengeTypeExecute:OnFinish()
    
end

return CheckChallengeTypeExecute
