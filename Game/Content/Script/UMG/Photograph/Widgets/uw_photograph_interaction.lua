-- ========================================================
-- @File    : uw_photograph_interaction.lua
-- @Brief   : 交互
-- ========================================================
---@class tbClass : UUserWidget
---@field pViewTarget AActor
local tbClass = Class("UMG.SubWidget")

function tbClass:Init(pParent)
    local pCameraManger = UE4.UGameplayStatics.GetPlayerCameraManager(self, 0)
    self.pViewTarget = pCameraManger.ViewTarget.Target
    self.Parent = pParent
end

function tbClass:SetActor(InActor)
    self.Actor  = InActor
end

function tbClass:OnZoomChange(Value)
    if self.pViewTarget == nil then return end
    local NowPos = self.pViewTarget:K2_GetActorLocation()
    local NewPos = NowPos +  self.pViewTarget:GetActorForwardVector() * Value * self.ZoomSpeed
    local SweepResult = UE4.FHitResult()
    self.pViewTarget:K2_SetActorLocation(NewPos, true, SweepResult, true)

    if self.Parent then
        self.Parent:UpdateLightArgs(NewPos.X)
    end
end

function tbClass:OnRotate(Value)
    if self.Actor then
        local NowRot = self.Actor:K2_GetActorRotation()
        local NewRot = NowRot + UE4.FRotator(0, 1, 0) * Value * -1 * 0.5
        self.Actor:K2_SetActorRotation(NewRot, false)
    end
end

function tbClass:OnMove(Value)
    if self.pViewTarget == nil then return end
    local NowPos = self.pViewTarget:K2_GetActorLocation()
    local NewPos = NowPos +  UE4.FVector(0, 0, 1) * Value * self.MoveSpeed
    if NewPos.Z > self.MaxZ then NewPos.Z = self.MaxZ end
    if NewPos.Z < self.MinZ then NewPos.Z = self.MinZ end
    
    local SweepResult = UE4.FHitResult()
    self.pViewTarget:K2_SetActorLocation(NewPos,true, SweepResult, true)
end

return tbClass
