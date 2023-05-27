-- ========================================================
-- @File    : uw_fight_player_lockmonster.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

local LockCross = Class("UMG.Fight.Widgets.CrossHair.uw_fight_crosshair_base")

function LockCross:Construct()
    -- print('LockCross:Construct')
    self:OnLock(false)
end

function LockCross:Tick(MyGeometry, InDeltaTime)

    local Pawn = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    local PawnState=Pawn:CheckCharacterActionState(UE4.ECharacterActionState.Rush)
    local OwnerPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    local AimTargetPos = OwnerPlayer:GetAimTargetPosition()
    local bToAim=UE4.UKismetMathLibrary.Distance2D(AimTargetPos,UE4.FVector2D(0, 0))<0.1
    self:OnLock(not bToAim)
end

function LockCross:OnLock(InIs)
    if InIs then
       WidgetUtils.SelfHitTestInvisible(self.Lock)
    else
        WidgetUtils.Hidden(self.Lock)
    end
end



return LockCross