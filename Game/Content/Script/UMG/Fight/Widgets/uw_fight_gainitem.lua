-- ========================================================
-- @File    : uw_fight_gainitem.lua
-- @Brief   : 战斗提示最小单元
-- ========================================================

local GainItem = Class("UMG.SubWidget")

function GainItem:Construct()
end

function GainItem:OnDestruct()
end

function GainItem:OnListItemObjectSet(InObj)
    -- self.tbData = InObj.Data.tbData
    InObj.Data.pRefresh = function (inObj)
        self:RemoveGainItem(inObj)
    end

    self.StartTimerHandle = nil
    self.AliveTimerHandle = nil
    self.RemoveTimerHandle = nil
    self.AliveTime = GlobalConfig.FightUI.AliveTime
    self.AnimTime = GlobalConfig.FightUI.AnimTime

    self:InitGainItem(InObj)
end

function GainItem:SetText(inData)
    if inData.TextType == UE4.EFightTipType.TacticalSkillCD then
        self.TxtGuardNum:SetText(Text("ui.TxtFightSkillCd"))
    elseif inData.TextType == UE4.EFightTipType.TacticalSkillEnergy then
        self.TxtGuardNum:SetText(Text("ui.TxtFightSkillEnergy1"))
    elseif inData.TextType == UE4.EFightTipType.UltimateSkillEnergy then
        self.TxtGuardNum:SetText(Text("ui.TxtFightSkillEnergy2"))
    elseif inData.TextType == UE4.EFightTipType.FightPowerExhaustion then
        self.TxtGuardNum:SetText(Text("ui.TxtFightNotPhysical"))
    elseif inData.TextType == UE4.EFightTipType.InvalidQuery then
        self.TxtGuardNum:SetText(Text("ui.SkillCastFail_InvalidQueryResult"))
    elseif inData.TextType == UE4.EFightTipType.SpecialItemResonanceRate then
        self.TxtGuardNum:SetText(Text("ui.TxtFightItemTips1"), inData.inItemName)
    elseif inData.TextType == UE4.EFightTipType.SpecialItemDataSample then
        self.TxtGuardNum:SetText(Text("ui.TxtFightItemTips2"), inData.inItemName)
    elseif inData.TextType == UE4.EFightTipType.SkillConditionFail then
        self.TxtGuardNum:SetText(Text("ui.TxtFightRoleNoMove"))
    elseif inData.TextType == UE4.EFightTipType.Bullet then
        self.TxtGuardNum:SetText(Text("ui.TxtAttributeLack", Text("ui.TxtBullet")))
    end
end

function GainItem:InitGainItem(inObj)
    inObj.Data.tbData.bIniting = true
    self:SetText(inObj.Data)
    self:PlayAnimation(self.Enter)
    self.StartTimerHandle =
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate({
            self,
            function()
                self:KeepGainItemAlive(inObj)
            end
        },
        self.AnimTime,
        false
    )
end

function GainItem:KeepGainItemAlive(inObj)
    if self.StartTimerHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.StartTimerHandle)
        self.StartTimerHandle = nil
    end
    inObj.Data.tbData.bIniting = false
    self.AliveTimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({
            self,
            function()
                self:RemoveGainItem(inObj)
            end
        },
        self.AliveTime,
        false
    )
end

function GainItem:RemoveGainItem(inObj)
    if self.StartTimerHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.StartTimerHandle)
        self.StartTimerHandle = nil
    end
    if self.AliveTimerHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.AliveTimerHandle)
        self.AliveTimerHandle = nil
    end
    self:PlayAnimation(self.Enter, 0, 1, UE4.EUMGSequencePlayMode.Reverse, 1, false)
    inObj.Data.tbData.bRemoveing = true
    self.RemoveTimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({
            self,
            function()
                self:RemoveItem(inObj)
            end
        },
        self.AnimTime,
        false
    )
end

function GainItem:RemoveItem(inObj)
    -- 清除之前的 Handle
    if self.StartTimerHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.StartTimerHandle)
        self.StartTimerHandle = nil
    end
    if self.AliveTimerHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.AliveTimerHandle)
        self.AliveTimerHandle = nil
    end
    if self.RemoveTimerHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.RemoveTimerHandle)
        self.RemoveTimerHandle = nil
    end
    inObj.Data.tbData.bRemoveing = false
    inObj.Data.ListGainItems:RemoveItem(inObj)
    inObj:Destroy()
end

return GainItem
