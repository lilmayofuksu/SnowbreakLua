-- ========================================================
-- @File    : uw_fashion_interaction1.lua
-- @Brief   : 交互(仅旋转)
-- ========================================================
---@class tbClass : UUserWidget
---@field pViewTarget AActor
local tbClass = Class("UMG.SubWidget")

function tbClass:Init(pParent, InActor)
    local pCameraManger = UE4.UGameplayStatics.GetPlayerCameraManager(self, 0)
    self.pViewTarget = pCameraManger.ViewTarget.Target
    self.Parent = pParent
    self.Actor  = InActor
    self.DefaultActorRot = self.Actor:K2_GetActorRotation()
end

function tbClass:BindActor(InActor)
    self.Actor  = InActor
end

function tbClass:OnRotate(Value)
    if self.Actor then
        local NowRot = self.Actor:K2_GetActorRotation()
        local NewRot = NowRot + UE4.FRotator(0, 1, 0) * Value * -1 * 0.5
        self.Actor:K2_SetActorRotation(NewRot, false)
    end
end

function tbClass:OnClose()
    if self.Actor then
        self.Actor:K2_SetActorRotation(self.DefaultActorRot, false)
    end
end

return tbClass
