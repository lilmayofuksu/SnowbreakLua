
-- ========================================================
-- @File    : uw_fight_cross.lua
-- @Brief   : 狙击枪准星
-- @Author  :
-- @Date    :
-- ========================================================
local uw_fight_mla_frame = Class("UMG.Fight.Widgets.CrossHair.uw_fight_crosshair_base")

local SniperRifleCross = uw_fight_mla_frame

local bchange=false


function SniperRifleCross:Construct()
    WidgetUtils.HitTestInvisible(self.Image_OrdinaryR)
    WidgetUtils.HitTestInvisible(self.Image_OrdinaryL)
    WidgetUtils.Collapsed(self.Image_AimL)
    WidgetUtils.Collapsed(self.Image_AimR)
end

function SniperRifleCross:Tick(MyGeometry, InDeltaTime)
    self.Super.Tick(self, MyGeometry, InDeltaTime)

    local A = self.Size
    local B = self.Size * -1
    self.LU:SetRenderTranslation(UE4.FVector2D(A, 0))
    self.RU:SetRenderTranslation(UE4.FVector2D(B, 0))
    self.LU_1:SetRenderTranslation(UE4.FVector2D(A, 0))
    self.RU_1:SetRenderTranslation(UE4.FVector2D(B, 0))
    self.Center:SetRenderTranslation(self.Pos)

    local Pawn = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    -- if Pawn then
    --     local Weapon = Pawn:GetWeapon()
    --     if Weapon and Weapon.AccessoryAbility then
    --         self.BulletTex:SetText(math.floor(Weapon.AccessoryAbility:GetRolePropertieValue(UE4.EAttributeType.Bullet)))
    --     end
    -- end
    local PawnState=Pawn:CheckCharacterActionState(UE4.ECharacterActionState.Rush)
    local OwnerPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    local AimTargetPos = OwnerPlayer:GetAimTargetPosition()
    local bToAim=UE4.UKismetMathLibrary.Distance2D(AimTargetPos,UE4.FVector2D(0, 0))<0.1
    self:SetShowFire(Pawn:IsInAim(),OwnerPlayer.bIsAimTarget, bToAim,PawnState)
end

function SniperRifleCross:SetShowFire(bInAim,InTarAct,bValue,bPawnState)
    if bInAim then
        if InTarAct then
            WidgetUtils.HitTestInvisible(self.Image_AimL)
            WidgetUtils.HitTestInvisible(self.Image_AimR)
            WidgetUtils.Collapsed(self.Image_OrdinaryR)
            WidgetUtils.Collapsed(self.Image_OrdinaryL)
        else
            WidgetUtils.HitTestInvisible(self.Image_OrdinaryR)
            WidgetUtils.HitTestInvisible(self.Image_OrdinaryL)
            WidgetUtils.Collapsed(self.Image_AimL)
            WidgetUtils.Collapsed(self.Image_AimR)
        end
    else
        if not bValue then
            WidgetUtils.HitTestInvisible(self.Image_AimL)
            WidgetUtils.HitTestInvisible(self.Image_AimR)
            WidgetUtils.Collapsed(self.Image_OrdinaryR)
            WidgetUtils.Collapsed(self.Image_OrdinaryL)
        else
            WidgetUtils.HitTestInvisible(self.Image_OrdinaryR)
            WidgetUtils.HitTestInvisible(self.Image_OrdinaryL)
            WidgetUtils.Collapsed(self.Image_AimL)
            WidgetUtils.Collapsed(self.Image_AimR)
            if bPawnState then
                self:SetCurCrossState(bPawnState,self.Image_OrdinaryR,self.transparency)
            end
        end

    end
    
end

return SniperRifleCross