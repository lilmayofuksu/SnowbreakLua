-- ========================================================
-- @File    : uw_fight_crosshair_base.lua
-- @Brief   : 准心控制
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_crosshair_base = Class("UMG.SubWidget")

local Widget = uw_fight_crosshair_base
Widget.Size = 0
Widget.Pos = UE4.FVector2D(0, 0)
Widget.Scatter = UE4.FVector4()
Widget.AmmunitionWidget = nil
Widget.tbAmmunitionWidgets = nil

Widget.OurPawn = nil

function Widget:Tick(MyGeometry, InDeltaTime)
    local OwnerPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    if not OwnerPlayer then
        return
    end

    local Camera = UE4.UGameplayStatics.GetPlayerCameraManager(self, 0)
    if not Camera then
        return
    end

    local Angle = Camera:GetFOVAngle() / 2
    local ViewportSize = UE4.UWidgetLayoutLibrary.GetViewportSize(self) / UE4.UWidgetLayoutLibrary.GetViewportScale(self)
    --local MinSize = math.min(ViewportSize.X, ViewportSize.Y) / 2
    local MinSize = ViewportSize.X / 2
    self.Scatter = OwnerPlayer:GetWeaponScatter() / Angle * MinSize
    self.Size = UE4.UKismetMathLibrary.FInterpTo(self.Size, self.Scatter.Y, InDeltaTime, 20)
    self.Pos = UE4.FVector2D(self.Scatter.Z, self.Scatter.W)
end

function Widget:SetOpacityAnim(InNode, InAnim, InPlayMode)
    InNode:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:PlayAnimation(InAnim, 0, 1, InPlayMode, 1, false)
end

function Widget:SetCurCrossState(bInState, InNode, InAnim)
    if not bInState then
        self:SetOpacityAnim(InNode, InAnim, UE4.EUMGSequencePlayMode.Forward)
    else
        self:SetOpacityAnim(InNode, InAnim, UE4.EUMGSequencePlayMode.Reverse)
    end
end

function Widget:OnDestruct()
    if self.tbAmmunitionWidgets then
        for _, item in pairs(self.tbAmmunitionWidgets) do
            if item then
                item:RemoveFromParent()
            end
        end
    end
    self.tbAmmunitionWidgets = nil
    self.AmmunitionWidget = nil
end

function Widget:ChangeType()
    local Player = self:GetOwningPlayerPawn()
    if not Player then
        return
    end

    local OwnerPlayer = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    local OwnerWeapon = OwnerPlayer:GetWeapon()
    local CurSoftPath = OwnerWeapon.WeaponInfo.AmmunitionUIWidget    
    local strCurSoftPath = UE4.UKismetSystemLibrary.BreakSoftClassPath(CurSoftPath)
    if strCurSoftPath == nil or strCurSoftPath == "" then
        return
    end

    if self.AmmunitionWidget then
        WidgetUtils.Collapsed(self.AmmunitionWidget)
    end
    if self.tbAmmunitionWidgets == nil then self.tbAmmunitionWidgets = {} end
    self.AmmunitionWidget = self.tbAmmunitionWidgets[strCurSoftPath]
    
    if self.AmmunitionWidget then
        WidgetUtils.HitTestInvisible(self.AmmunitionWidget)
    else
        self.AmmunitionWidget = LoadUI(CurSoftPath)
        if not self.AmmunitionWidget then
            return
        end
        self.tbAmmunitionWidgets[strCurSoftPath] = self.AmmunitionWidget
        self.GroupAmmunition:AddChild(self.AmmunitionWidget)
        self.AmmunitionWidget:SetRenderTranslation(OwnerWeapon.WeaponInfo.AmmunitionOffset)
        -- local Slot = UE4.UWidgetLayoutLibrary.SlotAsOverlaySlot(self.AmmunitionWidget)
        -- Slot:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Center)
        -- Slot:SetVerticalAlignment(UE4.EHorizontalAlignment.HAlign_Center)
    end
end

return uw_fight_crosshair_base
