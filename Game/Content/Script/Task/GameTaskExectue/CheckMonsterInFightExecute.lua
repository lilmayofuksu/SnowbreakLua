-- ========================================================
-- @File    : CheckMonsterInFightExecute.lua
-- @Brief   :
-- @Author  : cms
-- @Date    :
-- ========================================================

---@class  CheckMonsterInFightExecute: GameTask_Execute

local CheckMonsterInFight = Class()

function CheckMonsterInFight:OnActive()
    self.Handle = EventSystem.On(
        Event.AIFirstInFight,
        function(AIPawn)
            -- print("CheckMonsterInFight:Enter!")
            if not IsValid(AIPawn) then
                return
            end
            -- print("CheckMonsterInFight:PawnValid!")
            if self.Tag ~= 'None' and not AIPawn.Tags:Contains(self.Tag) then
                return
            end
            --print("CheckMonsterInFight:Tag Valid!", self.bOneShotKill, AIPawn.bHadOneShotKill)
            if not self.bOneShotKill and AIPawn.bHadOneShotKill then --没有勾选一击即死检测，就不处理一击即死状态发来的战斗状态
                return
            elseif self.bOneShotKill and AIPawn.bHadOneShotKill then --此时不需要check target.已经没有target了
                --print("CheckMonsterInFight:OneShotKill!")
                self:Finish()
            else
                local TargetActor = AIPawn.AIControlData:GetTargetActor()
                if not TargetActor then
                    -- print("CheckMonsterInFight:Target InValid!")
                    return
                end
                -- print("CheckMonsterInFight:Target Valid!")
                if self.bTargetIsPlayer and IsPlayer(TargetActor) then
                    self:Finish()
                elseif not self.bTargetIsPlayer then
                    self:Finish()
                end
                print("CheckMonsterInFight:Target Error, No Finish!")
            end
        end,
        false
    )
    self:SetExecuteDescription()
    TaskCommon.AddHandle(self.Handle)
end

function CheckMonsterInFight:OnFail()
    EventSystem.Remove(self.Handle)
end

function CheckMonsterInFight:OnFinish()
    --check how many monster engage and select voice to play
    --[[local AICharacters = UE4.UGameplayStatics.GetAllActorsOfClass(self, UE4.AGameAICharacter);
    local num = 0;
    for i = 1, AICharacters:Length() do
        local AICharacter = AICharacters:Get(i);
        if AICharacter:IsValid() and AICharacter:IsAI() and AICharacter.bIsInFightState then
            num = num + 1;
        end
    end
    
    local chance = math.random(1, 100);
    if chance <= 50 then
        if num < 5 and num > 0 then
            self:PlayVoice("wavelittle");
        elseif num >= 5 then
            self:PlayVoice("wavemany");
        end
    end]]

    EventSystem.Remove(self.Handle)
end

return CheckMonsterInFight
