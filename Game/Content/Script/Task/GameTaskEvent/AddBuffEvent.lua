-- ========================================================
-- @File    : AddBuffEvent.lua
-- @Brief   : 添加buff
-- @Author  :
-- @Date    :
-- ========================================================
---@class AddBuffEvent : GameTaskEvent
local AddBuffEvent = Class()

function AddBuffEvent:OnTrigger()
	local buffId = self.ModifierID
	local toPlayer = self.CastToPlayer

    if self.MultType then
        local TaskActor = self:GetGameTaskActor()
        if self.RandomMonster then
        	local RandomCfg = UE4.UTaskRandomSubsystem.GetBattleRandomMonster(TaskActor, TaskActor.AreaId)
        	if RandomCfg then
        		buffId = RandomCfg.BufferId
	        	toPlayer = RandomCfg.BufferType == UE4.EChallengeBuffType.Player
        	end
        else
        	self.challengeCfg = UE4.UTaskRandomSubsystem.GetBattleChallange(TaskActor, TaskActor.AreaId)
	        if self.challengeCfg then
	        	buffId = self.challengeCfg.BufferId
	        	toPlayer = self.challengeCfg.BufferType == UE4.EChallengeBuffType.Player
	       	end
        end
    end

    if buffId == 0 then return false end

    UE4.ULevelLibrary.AddBuff(self, buffId, toPlayer)

    if toPlayer then self:UpdateDataToClient(buffId) end

    return true
end

function AddBuffEvent:OnUpdate_Client(buffId)
    local FightUI = UI.GetUI('Fight')
    if FightUI then FightUI.Tips:AddBuff(buffId) end
end

return AddBuffEvent
