-- ========================================================
-- @File    : uw_fight_reviving.lua
-- @Brief   : 自动复活提示
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.ReviveTime = 0;
    self.CurrentReviveTime = 0;
    self.TotalReviveTime = 0;
    self.TextValue = -1;
    self:RegisterEvent(Event.ShowReviveTime, function(ReviveHelper) self:OnShowReviveTime(ReviveHelper) end)
    self:RegisterEvent(Event.HideReviveTime, function() self:OnHideReviveTime() end)
    BtnAddEvent(self.BtnRevive,function () self:OnBtnReviveImmediately() end)
    BtnAddEvent(self.BtnRevive1,function () self:OnBtnReviveImmediately() end)
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function tbClass:OnShowReviveTime(ReviveHelper)
    self.ReviveHelper = ReviveHelper
    self:UpdateReviveTime()
    local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    local count = PlayerController:GetReviveCount();
    local MaxCount = self.ReviveHelper:GetMaxReviveCount()
    self.Txt1:SetText(count)
    self.Txt3:SetText(MaxCount)
    self.Txt1_1:SetText(count)
    self.Txt3_1:SetText(MaxCount)
    if self.ReviveHelper:IsSinglePlayer() then
        self.TxtReviving:SetText(Text("ui.TxtReviveBtn"))
        self.TxtReviving:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.PanelOne:SetVisibility(UE4.ESlateVisibility.Visible)
        self.PanelReviveBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
        self:PlayAnimation(self.ReviveOne, 0, 50, UE4.EUMGSequencePlayMode.Forward, 1, true)
    else
        self.TxtReviving:SetText(Text("ui.TxtReviving"))
        self.TxtReviving:SetVisibility(UE4.ESlateVisibility.Visible)
        self.PanelOne:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.PanelReviveBtn:SetVisibility(UE4.ESlateVisibility.Visible)
        self:PlayAnimation(self.Loop, 0, 50, UE4.EUMGSequencePlayMode.Forward, 1, true)
    end
    self:SetVisibility(UE4.ESlateVisibility.Visible)
    RuntimeState.ChangeInputMode(true)
end

function tbClass:OnHideReviveTime()
    self.ReviveHelper = nil
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
    RuntimeState.ChangeInputMode(false)
end

function tbClass:UpdateReviveTime()
    if not self.ReviveHelper then return end 
    local nTime = self.ReviveHelper:GetNeedTime()
    self.TxtNum:SetText(math.ceil(nTime));
    self.ImgReviving:GetDynamicMaterial():SetScalarParameterValue("Percent", self.ReviveHelper:GetPercent());
    local bMousePreStatus = WidgetUtils.MouseCursorStatus(self)
    if not bMousePreStatus then
        RuntimeState.ChangeInputMode(true)
    end
end

function tbClass:Tick()
    self:UpdateReviveTime()
end

function tbClass:OnBtnReviveImmediately()
    local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    local Character = UE4.UGameplayStatics.GetPlayerCharacter(PlayerController, 0)
    if Character then
        local isAlive = Character:IsAlive()
        if isAlive then return end
        local count = PlayerController:GetReviveCount();
        if count <= 0 then
            print("uw_fight_reviving", "count < 0")
            return
        end
        if not Character:CanUseReviveCoin() then
            print("uw_fight_reviving", "CanUseReviveCoin")
            return
        end 
        if not isAlive then 
            PlayerController:Server_ApplyReviveImmediately(Character)
        end
    end
end

return tbClass
