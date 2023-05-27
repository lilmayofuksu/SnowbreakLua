local StarTask_PlayerReceiveDamage = Class()

function StarTask_PlayerReceiveDamage:OnPrepare()
    self.EventHandle = EventSystem.On(Event.DamageReceive, function(DamageParameters)
        if self == nil then
            return;
        end
        if DamageParameters and DamageParameters.Target then
            local Player = DamageParameters.Target:Cast(UE4.AGamePlayer)
            if Player then
                self.NowNum = self.NowNum + 1;
                self:StageTip()
            end
        end
    end)
end

function StarTask_PlayerReceiveDamage:K2_OnLevelFinish()
    EventSystem.Remove(self.EventHandle);
end

return StarTask_PlayerReceiveDamage