local StarTask_KillEnemyCount = Class()

function StarTask_KillEnemyCount:OnPrepare()
    self.EventHandle = EventSystem.On(Event.CharacterDeath, function(DeadCharacter, Killer)
        if self == nil then
            return;
        end
        if DeadCharacter and Killer and DeadCharacter:IsAI() then
            local Player = self:GetGamePlayer(Killer)
            if Player then
                self.NowNum = self.NowNum + 1;
                self:StageTip()
                -- print("StarTask_KillEnemyCount   ", self.NowNum);
            end
        end
    end)
end

function StarTask_KillEnemyCount:K2_OnLevelFinish()
    EventSystem.Remove(self.EventHandle);
end

function StarTask_KillEnemyCount:GetGamePlayer(GameCharacter)
    if GameCharacter == nil then
        return;
    end
    GameCharacter = UE4.UAbilityFunctionLibrary.GetOriginPlayer(GameCharacter)
    local Player = GameCharacter:Cast(UE4.AGamePlayer);
    return Player;
end

return StarTask_KillEnemyCount