local StarTask_SkillKillEnemyCount = Class()

function StarTask_SkillKillEnemyCount:OnPrepare()
    self.EventHandle = EventSystem.On(Event.DamageReceive, function(DamageParameters)
        if self == nil then
            return;
        end
        if DamageParameters and DamageParameters.Launcher and DamageParameters.Target and DamageParameters.DamageResult then
            -- 击杀AI，且是技能
            if DamageParameters.DamageResult.bDamageCauseDead and DamageParameters.Target:IsAI() and DamageParameters.DamageResult.DamageOriginType == 1 then
                local Player = self:GetGamePlayer(DamageParameters.Launcher)
                if Player then
                    self.NowNum = self.NowNum + 1;
                    self:StageTip()
                    -- print("StarTask_SkillKillEnemyCount   ", self.NowNum);
                end
            end
        end
    end)
end

function StarTask_SkillKillEnemyCount:K2_OnLevelFinish()
    EventSystem.Remove(self.EventHandle);
end

function StarTask_SkillKillEnemyCount:GetGamePlayer(GameCharacter)
    if GameCharacter == nil then
        return;
    end
    GameCharacter = UE4.UAbilityFunctionLibrary.GetOriginPlayer(GameCharacter)
    local Player = GameCharacter:Cast(UE4.AGamePlayer);
    return Player;
end

return StarTask_SkillKillEnemyCount