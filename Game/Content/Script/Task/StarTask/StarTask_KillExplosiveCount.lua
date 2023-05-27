local StarTask_KillExplosiveCount = Class()

function StarTask_KillExplosiveCount:OnPrepare()
    self.EventHandle = EventSystem.On(Event.CharacterDeath, function(DeadCharacter, Killer)
        if self == nil then
            return;
        end
        if DeadCharacter and Killer and self:IsExplosive(DeadCharacter) then
            -- local Player = self:GetGamePlayer(Killer)
            -- if Player then
                self.NowNum = self.NowNum + 1;
                self:StageTip()
                -- print("StarTask_KillExplosiveCount   ", self.NowNum);
            -- end
        end
    end)
end

function StarTask_KillExplosiveCount:K2_OnLevelFinish()
    EventSystem.Remove(self.EventHandle);
end

-- function StarTask_KillExplosiveCount:GetGamePlayer(GameCharacter)
--     if GameCharacter == nil then
--         return;
--     end
--     GameCharacter = UE4.UAbilityFunctionLibrary.GetOriginPlayer(GameCharacter)
--     local Player = GameCharacter:Cast(UE4.AGamePlayer);
--     return Player;
-- end

return StarTask_KillExplosiveCount