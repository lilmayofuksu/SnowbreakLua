local StarTask_WeaponKillEnemyCount = Class()

function StarTask_WeaponKillEnemyCount:OnPrepare()
    self.EventHandle = EventSystem.On(Event.DamageReceive, function(DamageParameters)
        if self == nil then
            return;
        end
        if DamageParameters and DamageParameters.Launcher and DamageParameters.Target and DamageParameters.DamageResult then
            -- 击杀AI，且是射击
            if DamageParameters.DamageResult.bDamageCauseDead and DamageParameters.Target:IsAI() and DamageParameters.DamageResult.DamageOriginType == 0 then
                local Player = DamageParameters.Launcher:Cast(UE4.AGamePlayer);
                if Player then
                    self.NowNum = self.NowNum + 1;
                    self:StageTip()
                    -- print("StarTask_WeaponKillEnemyCount   ", self.NowNum);
                end
            end
        end
    end)
end

function StarTask_WeaponKillEnemyCount:K2_OnLevelFinish()
    EventSystem.Remove(self.EventHandle);
end

return StarTask_WeaponKillEnemyCount