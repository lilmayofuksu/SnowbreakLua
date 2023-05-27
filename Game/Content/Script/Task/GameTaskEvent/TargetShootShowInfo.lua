local tbClass = Class()

function tbClass:OnTrigger()
    self:ShowLevelInfo()

    --关闭伤害数字上飘
    local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    if (not IsValid(PlayerController)) then
        return
    end
    PlayerController.bDisableDamageShow = true

end

function tbClass:ShowLevelInfo()
    local bCanShow = me:GetAttribute(TargetShootLogic.nGroupId, TargetShootLogic.ShownInfo)
    if bCanShow and not UI.IsOpen("TargetShootInfo") then
        UI.Open("TargetShootInfo")
    else
        local FightUMG = UI.GetUI("Fight")
        if FightUMG and FightUMG.uw_fight_target then
            print("RoundTimer:OnActive Fight UW",FightUMG.uw_fight_target)
            FightUMG.uw_fight_target:Active(self)
        end
    end
end

return tbClass;