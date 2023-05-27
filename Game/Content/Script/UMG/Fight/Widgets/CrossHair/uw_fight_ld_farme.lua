
-- ========================================================
-- @File    : uw_fight_cross.lua
-- @Brief   : 霰弹枪准星
-- @Author  :
-- @Date    :
-- ========================================================
local uw_fight_ld_farme = Class("UMG.Fight.Widgets.CrossHair.uw_fight_crosshair_base")

local ShotGunCross = uw_fight_ld_farme


function ShotGunCross:Construct()
    WidgetUtils.HitTestInvisible(self.Group_zoom)
    WidgetUtils.Collapsed(self.Group_FireStarter_zoom)
end

function ShotGunCross:Tick(MyGeometry, InDeltaTime)
    self.Super.Tick(self, MyGeometry, InDeltaTime)

    local A = self.Size
    local B = self.Size * -1
    self.LU:SetRenderTranslation(UE4.FVector2D(B, B))
    self.LD:SetRenderTranslation(UE4.FVector2D(B, A))
    self.RU:SetRenderTranslation(UE4.FVector2D(A, B))
    self.RD:SetRenderTranslation(UE4.FVector2D(A, A))

    self.LU_1:SetRenderTranslation(UE4.FVector2D(B, B))
    self.LD_1:SetRenderTranslation(UE4.FVector2D(B, A))
    self.RU_1:SetRenderTranslation(UE4.FVector2D(A, B))   
    self.RD_1:SetRenderTranslation(UE4.FVector2D(A, A))

    -- self.ProgressBarReLoad:SetRenderTranslation(UE4.FVector2D(0, A))

    self.Center:SetRenderTranslation(self.Pos)

    local Pawn = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    -- if Pawn then
    --     local Weapon = Pawn:GetWeapon()
    --     if Weapon and Weapon.AccessoryAbility then
    --         local BulletPercent =
    --         Weapon.AccessoryAbility:GetRolePropertieValue(UE4.EAttributeType.Bullet) / Weapon.AccessoryAbility:GetRolePropertieMaxValue(UE4.EAttributeType.Bullet)
    --         self.ProgressBarReLoad:SetPercent(BulletPercent)
    --     end
    -- end
   
    self.OurPawn = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    local AimTargetPos = self.OurPawn:GetAimTargetPosition()
    local PawnState=Pawn:CheckCharacterActionState(UE4.ECharacterActionState.Rush)
    local bToAim=UE4.UKismetMathLibrary.Distance2D(AimTargetPos,UE4.FVector2D(0, 0))<0.1
    self:SetShowFire(Pawn:IsInAim(),self.OurPawn.bIsAimTarget,bToAim,PawnState)
    
end


function ShotGunCross:SetReload(InValue)
    self.ProgressBarReLoad:SetPercent(InValue)
end

function ShotGunCross:SetFrame(InValue)
   local CrossState = nil
    if InValue== UE4.EModifyHPResult.Hit then
        -- body
    end
    -- body
end

function ShotGunCross:SetShowFire(bInAim,InTarAct,bValue,bPawnState)
    if bInAim then
        
        if InTarAct then
            WidgetUtils.HitTestInvisible(self.Group_FireStarter_zoom)
            WidgetUtils.Collapsed(self.Group_zoom)
        else
            WidgetUtils.HitTestInvisible(self.Group_zoom)
            WidgetUtils.Collapsed(self.Group_FireStarter_zoom)
        end
    else
        if not bValue then
            WidgetUtils.HitTestInvisible(self.Group_FireStarter_zoom)
            WidgetUtils.Collapsed(self.Group_zoom)
        else
            WidgetUtils.HitTestInvisible(self.Group_zoom)
            WidgetUtils.Collapsed(self.Group_FireStarter_zoom)
            self:SetCurCrossState(bPawnState,self.Group_zoom,self.transparency)
        end
    end
    
end

return ShotGunCross