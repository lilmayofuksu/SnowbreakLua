-- ========================================================
-- @File    : uw_fight_cross3.lua
-- @Brief   : 准心
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_cross3 = Class("UMG.Fight.Widgets.CrossHair.uw_fight_crosshair_base")

uw_fight_cross3.RealHitPos = UE4.FVector2D(0, 0)
function uw_fight_cross3:Tick(MyGeometry, InDeltaTime)
    self.Super.Tick(self, MyGeometry, InDeltaTime)
    --
    local A = self.Size
    local B = self.Size * -1
    self.LD:SetRenderTranslation(UE4.FVector2D(B, A))    
    self.RD:SetRenderTranslation(UE4.FVector2D(A, A))

    self.LD_1:SetRenderTranslation(UE4.FVector2D(B, A))    
    self.RD_1:SetRenderTranslation(UE4.FVector2D(A, A))
    
    self.Center:SetRenderTranslation(self.Pos)

    local OwnerPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    if not OwnerPlayer then
        return
    end

    local bRealHit = OwnerPlayer:GetRealShootPoint2Screen(self.RealHitPos)
    if bRealHit then
        UE4.UUMGLibrary.ScreenToWidgetLocal(self, self.Group_zoom:GetCachedGeometry(), self.RealHitPos, self.RealHitPos)
        WidgetUtils.SelfHitTestInvisible(self.RealPos)
        self.RealPos:SetRenderTranslation(self.RealHitPos)
    
    else
        WidgetUtils.Hidden(self.RealPos)
    end

    if not self:GetOwningPlayerPawn() then return end
    local Pawn = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
  
    local PawnState=Pawn:CheckCharacterActionState(UE4.ECharacterActionState.Rush)
    local OwnerPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    local AimTargetPos = OwnerPlayer:GetAimTargetPosition()
    local bToAim=UE4.UKismetMathLibrary.Distance2D(AimTargetPos,UE4.FVector2D(0, 0))<0.5
    self:ShowAim(Pawn:IsInAim(),OwnerPlayer.bIsAimTarget,bToAim,PawnState)
end

function uw_fight_cross3:ShowAim(bInAim,InTarAct,bValue,bPawnState)
    if bInAim then
        if not InTarAct then
            WidgetUtils.SelfHitTestInvisible(self.Group_zoom)
            WidgetUtils.Hidden(self.Group_FireStarter_zoom)
        else
            WidgetUtils.SelfHitTestInvisible(self.Group_FireStarter_zoom)
            WidgetUtils.Hidden(self.Group_zoom)
        end 
    else
        if bValue then
            WidgetUtils.SelfHitTestInvisible(self.Group_zoom)
            WidgetUtils.Hidden(self.Group_FireStarter_zoom)
            if bPawnState then
                self:SetCurCrossState(bPawnState,self.Group_zoom,self.transparency)
            end
        else
            WidgetUtils.SelfHitTestInvisible(self.Group_FireStarter_zoom)
            WidgetUtils.Hidden(self.Group_zoom)
        end 
        
    end
end






return uw_fight_cross3
