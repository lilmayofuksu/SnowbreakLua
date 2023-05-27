-- ========================================================
-- @File    : uw_storagebar.lua
-- @Brief   : hero special property
-- ========================================================

local uw_storagebar = Class("UMG.SubWidget")

local StorageBar = uw_storagebar

StorageBar.CurEnergyPercent = 0.0

StorageBar.bEnergyAnim = false
StorageBar.FocusAnimType = 0

StorageBar.Character = nil

local Character = nil

local AttributeType = 0

function StorageBar:OnInit()
    self:HiddleBar(self.EnergyPanel)
    self:HiddleBar(self.FocusPanel)
    self:HiddleBar(self.QinnuoPanel)
    self:HiddleBar(self.LidaPanel)
    self:SetBarPercent(self.EnergyProgressBar, 0.0)
    WidgetUtils.Collapsed(self.Img_electric)
    WidgetUtils.Collapsed(self.Img_absorbed1)
    WidgetUtils.Collapsed(self.Img_absorbed2)
    WidgetUtils.Collapsed(self.Img_absorbed3)
end

function StorageBar:Tick(MyGeometry, InDeltaTime)
    -- if self.Character and self.Character.Ability then
    --     if AttributeType == 1 then
    --         local CurrentVal = self.Character.Ability:GetRolePropertieValue(UE4.EAttributeType.Energy)
    --         local CurPercent = CurrentVal / self.Character.Ability:GetRolePropertieMaxValue(UE4.EAttributeType.Energy)
    --         self:SetBarPercent(self.EnergyProgressBar, CurPercent)
    --         if CurPercent < 1.0 then
    --             self:HiddleBar(self.Img_electric)
    --             StorageBar.bEnergyAnim = true
    --         end
    --         if CurPercent >= 1.0 and StorageBar.bEnergyAnim then
    --             self:PlayAnim(self.EnergyBarAnim, self.Img_electric)
    --         end
    --     elseif AttributeType == 2 then
    --         self:OnFocuse(self.Character.Ability:GetFocuseBuffOverlaid())
    --     elseif AttributeType == 3 then
    --         self:OnPressureLevel()
    --     elseif AttributeType == 4 then
    --         self:OnLidaPanel()
    --     end
    --             -- body
    -- end
end

function StorageBar:ShowBar(InValue)
    WidgetUtils.SelfHitTestInvisible(InValue)
end

function StorageBar:HiddleBar(InValue)
    WidgetUtils.Collapsed(InValue)
end

function StorageBar:SetBarPercent(InProgress, InPercent)
    InProgress:SetPercent(InPercent)
end

function StorageBar:PlayAnim(InValue, InObj)
    if StorageBar.bEnergyAnim then
        StorageBar.bEnergyAnim = false
        WidgetUtils.SelfHitTestInvisible(InObj)
        self:PlayAnimation(InValue, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end
end

function StorageBar:GetCurCharacter(InPawn)
    -- if not InPawn then
    --     return
    -- end

    -- self:OnInit()
    -- self.Character = InPawn
    -- if InPawn.Ability:GetExistUIExhibitionAttributes() then
    --     AttributeType = 0;
    --     if InPawn.Ability:IsEnergyAttributeExist() then   
    --         AttributeType = 1;
    --         self:ShowBar(self.EnergyPanel)
    --         StorageBar.bEnergyAnim = true
    --     else
    --         self:HiddleBar(self.EnergyPanel)
    --         StorageBar.bEnergyAnim = false
    --     end
    --     if InPawn.Ability:IsFocuseBuffExsit() then
    --         AttributeType = 2;
    --         self:ShowBar(self.FocusPanel)
    --     else
    --         self:HiddleBar(self.FocusPanel)
    --     end

    --     if InPawn.Ability:GetRolePropertieMaxValue(UE4.EAttributeType.PressurePoint) > 0 then
    --         AttributeType = 3
    --         self:ShowBar(self.QinnuoPanel)
    --         self:OnPressureLevel()
    --     else
    --         self:HiddleBar(self.QinnuoPanel)
    --     end

    --     if InPawn.Ability:GetRolePropertieMaxValue(UE4.EAttributeType.KnapsackEnergy) > 0 then
    --         self.LidaCharacter = self.Character:Cast(UE4.ABP_girl003_C)
    --         AttributeType = 4
    --         self:ShowBar(self.LidaPanel)
    --         self:OnPressureLevel()
    --     else
    --         self:HiddleBar(self.LidaPanel)
    --     end
    -- end
end
function StorageBar:OnFocuse(InValue)
    if self.FocusAnimType == InValue then
        return
    end
    if InValue == 1 then
        self:OnFocuseAnim(self.Img_absorbed1, self.FocusAnimFirst)
        WidgetUtils.Hidden(self.Img_absorbed2)
        WidgetUtils.Hidden(self.Img_absorbed3)
    end
    if InValue == 2 then
        WidgetUtils.SelfHitTestInvisible(self.Img_absorbed1)
        self:OnFocuseAnim(self.Img_absorbed2, self.FocusAnimSecond)
        WidgetUtils.Hidden(self.Img_absorbed3)
    end
    if InValue == 3 then
        WidgetUtils.SelfHitTestInvisible(self.Img_absorbed1)
        WidgetUtils.SelfHitTestInvisible(self.Img_absorbed2)
        self:OnFocuseAnim(self.Img_absorbed3, self.FocusAnimLast)
    end
    self.FocusAnimType = InValue
    return
end

function StorageBar:OnFocuseAnim(InImage, InAnim)
    WidgetUtils.SelfHitTestInvisible(InImage)
    self:PlayAnimation(InAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end


function StorageBar:OnPressureLevel()
    local Level = self.Character.Ability:GetRolePropertieValue(UE4.EAttributeType.PressureLevel) 
    if Level >= 1 then WidgetUtils.SelfHitTestInvisible(self.NumA) else WidgetUtils.Collapsed(self.NumA) end
    if Level >= 2 then WidgetUtils.SelfHitTestInvisible(self.NumB) else WidgetUtils.Collapsed(self.NumB) end
    if Level >= 3 then WidgetUtils.SelfHitTestInvisible(self.NumC) else WidgetUtils.Collapsed(self.NumC) end
    if Level >= 4 then WidgetUtils.SelfHitTestInvisible(self.NumD) else WidgetUtils.Collapsed(self.NumD) end
    if Level >= 5 then WidgetUtils.SelfHitTestInvisible(self.NumE) else WidgetUtils.Collapsed(self.NumE) end
    if Level >= 6 then WidgetUtils.SelfHitTestInvisible(self.NumF) else WidgetUtils.Collapsed(self.NumF) end
    if Level >= 3 and Level < 6 then 
        if not self:IsAnimationPlaying(self.AnimQinnuo)  then
            self:PlayAnimation(self.AnimQinnuo, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false) 
        end
    else
        self:StopAnimation(self.AnimQinnuo) 
        self:SetAnimationCurrentTime(self.AnimQinnuo, 0 ) 
    end
    if Level >= 6 then self:PlayAnimation(self.AnimQinnuoEnd, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false) end
    if self.Character.Ability:IsAttributeLocked(UE4.EAttributeType.PressurePoint, 0) then
        self.QinnuoPanel.RenderOpacity = 0.4
    else
        self.QinnuoPanel.RenderOpacity = 1
    end
end

function StorageBar:OnLidaPanel()
    local energy = self.Character.Ability:GetRolePropertieValue(UE4.EAttributeType.KnapsackEnergy)
    for i = 1, 5 do
        local item_red = self[string.format("Power%d_2", i)]
        local item_yellow = self[string.format("Power%d_3", i)]
        local bPalsy = self.LidaCharacter ~= nil and self.LidaCharacter.Palsy or false
        if energy >= i then 
            if bPalsy then
                WidgetUtils.SelfHitTestInvisible(item_red) 
                WidgetUtils.Collapsed(item_yellow) 
            else
                WidgetUtils.SelfHitTestInvisible(item_yellow) 
                WidgetUtils.Collapsed(item_red) 
            end
            
        else 
            WidgetUtils.Collapsed(item_yellow) 
            WidgetUtils.Collapsed(item_red) 
        end
    end
end

return StorageBar
