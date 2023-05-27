local StarTask_WeaknessDamage = Class()

function StarTask_WeaknessDamage:OnPrepare()
    self.EventHandle = EventSystem.On(Event.DamageReceive, function(DamageParameters)
        if self == nil then
            return;
        end
        if DamageParameters and DamageParameters.Launcher and DamageParameters.Target and DamageParameters.DamageResult then
            if DamageParameters.Target:IsAI() and UE4.UAbilityComponentBase.CheckModifyResultFlag(DamageParameters.DamageResult.ModifyResult, UE4.EModifyHPResult.Weakness) then
                local Player = self:GetGamePlayer(DamageParameters.Launcher)
                if Player then
                    self.NowNum = self.NowNum + math.ceil(DamageParameters.DamageResult.RealHealthDamageValue);
                    self:StageTip()
                    -- print("StarTask_WeaknessDamage  RealHealthDamageValue  ", math.ceil(DamageParameters.DamageResult.RealHealthDamageValue));
                    -- print("StarTask_WeaknessDamage   ", self.NowNum);
                end
            end
        end
    end)
end

function StarTask_WeaknessDamage:K2_OnLevelFinish()
    EventSystem.Remove(self.EventHandle);
end

function StarTask_WeaknessDamage:GetGamePlayer(GameCharacter)
    if GameCharacter == nil then
        return;
    end
    GameCharacter = UE4.UAbilityFunctionLibrary.GetOriginPlayer(GameCharacter)
    local Player = GameCharacter:Cast(UE4.AGamePlayer);
    return Player;
end

return StarTask_WeaknessDamage