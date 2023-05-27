

-- ========================================================
-- @File    : uw_fight_cross.lua
-- @Brief   : 能量枪准星
-- @Author  :
-- @Date    :
-- ========================================================
local uw_fight_plm_frame = Class("UMG.Fight.Widgets.CrossHair.uw_fight_crosshair_base")

local EnergyGunCross = uw_fight_plm_frame


function EnergyGunCross:Construct()
    WidgetUtils.HitTestInvisible(self.Image_bg2)
    WidgetUtils.Collapsed(self.Image_bg1)
    -- WidgetUtils.HitTestInvisible(self.ProgressBar_Overheated_1)
    -- WidgetUtils.Collapsed(self.ProgressBar_Cooling)
    -- self:SetPercent(self.ProgressBar_Overheated_1,0)
    -- self:SetPercent(self.ProgressBar_Cooling,0)
end

function EnergyGunCross:Tick(MyGeometry, InDeltaTime)
    self.Super.Tick(self, MyGeometry, InDeltaTime)
    
    local A = self.Size
    local B = self.Size * -1
    -- self.LU:SetRenderTranslation(UE4.FVector2D(B, B))
    -- self.LD:SetRenderTranslation(UE4.FVector2D(B, A))
    -- self.RU:SetRenderTranslation(UE4.FVector2D(A, B))
    -- self.RD:SetRenderTranslation(UE4.FVector2D(A, A))
    self.Image_Collimation:SetRenderTranslation(self.Pos)

    local OwnPawn = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    local PawnState=OwnPawn:CheckCharacterActionState(UE4.ECharacterActionState.Rush)
    local CurCross=OwnPawn:GetWeapon()
    -- self:SetPercent(self.ProgressBar_Overheated_1,CurCross.m_fOverloadValue)
    -- self:SetPercent(self.ProgressBar_Cooling,CurCross.m_fOverloadValue)
   
    if CurCross.bActive then
        -- WidgetUtils.HitTestInvisible(self.ProgressBar_Overheated_1)
        -- WidgetUtils.Collapsed(self.ProgressBar_Cooling)
        if OwnPawn:IsInFire() then
            self:PlayAnim(self.Animation_Rotate)
        else
            if self:IsAnimationPlaying(self.Animation_Rotate) then
                self:StopAnimation(self.Animation_Rotate)
            end
        end
    else
        -- WidgetUtils.Collapsed(self.ProgressBar_Overheated_1)
        -- WidgetUtils.HitTestInvisible(self.ProgressBar_Cooling)
        if self:IsAnimationPlaying(self.Animation_Rotate) then
            self:StopAnimation(self.Animation_Rotate)
        end
        self:PlayAnim(self.Overheated)
    end

    local OwnerPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    local AimTargetPos = OwnerPlayer:GetAimTargetPosition()
    
    local bToAim=UE4.UKismetMathLibrary.Distance2D(AimTargetPos,UE4.FVector2D(0, 0))<0.5
    if OwnPawn:IsInAim() then
        if OwnerPlayer.bIsAimTarget then
            WidgetUtils.HitTestInvisible(self.Image_bg1)
            WidgetUtils.Collapsed(self.Image_bg2)
        else
            WidgetUtils.HitTestInvisible(self.Image_bg2)
            WidgetUtils.Collapsed(self.Image_bg1)
        end
    else
        if bToAim then
            WidgetUtils.HitTestInvisible(self.Image_bg2)
            WidgetUtils.Collapsed(self.Image_bg1)
            if PawnState then
                self:SetCurCrossState(PawnState,self.Image_bg2,self.transparency)
            end
        else
            WidgetUtils.HitTestInvisible(self.Image_bg1)
            WidgetUtils.Collapsed(self.Image_bg2)
        end
    end
end

function EnergyGunCross:SetPercent(InBar,InValue)
    InBar:SetPercent(InValue)
end

function EnergyGunCross:PlayAnim(InAnim)
    if not self:IsAnimationPlaying(InAnim) then
        self:PlayAnimation(InAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end
end

function EnergyGunCross:SetShow(bInShow,InImg)
    if bInShow then
        WidgetUtils.HitTestInvisible(InImg)
    else
        WidgetUtils.Collapsed(InImg)
    end
end
return EnergyGunCross