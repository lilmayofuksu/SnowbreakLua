-- ========================================================
-- @File    : ChallengeFinishExecute.lua
-- @Brief   : 挑战节点
-- @Author  :
-- @Date    :
-- ========================================================

---@class ChallengeFinishExecute : TaskItem
local ChallengeFinishExecute = Class()

function ChallengeFinishExecute:OnActive()
	local TaskActor = self:GetGameTaskActor()
    self.challengeCfg = UE4.UTaskRandomSubsystem.GetBattleChallange(TaskActor, TaskActor.AreaId)
   	if self.challengeCfg.ChallangeId ~= -1 then
   		self:TipToClient('challenge.'..self.challengeCfg.ChallangeId..'_Name', 1)
   	end

	if self:IsServer() then
		self:GetReward()
	end
    self:Finish()
end

function ChallengeFinishExecute:GetReward()
	local gameState = UE4.ULevelLibrary.GetGameState(self);
	if gameState then
		local playerArray = gameState.PlayerArray
		for i=1,3 do
	        if i <= playerArray:Length() then 
	            local pState = playerArray:Get(i)
	            print(string.format('===================>挑战成功玩家%d发放奖励%d代币', i, self.challengeCfg.Reward))
	            pState:UpdateMultiLevelChallengeMoney(self.challengeCfg.Reward)
	        end
	    end
	end
end

function ChallengeFinishExecute:OnEnd()
	ChallengeMgr.RemoveChallenge(self.challengeCfg.ChallangeId)
end

function ChallengeFinishExecute:OnEnd_Client()
	EventSystem.Trigger(Event.OnChallengeFinish)
end

return ChallengeFinishExecute
