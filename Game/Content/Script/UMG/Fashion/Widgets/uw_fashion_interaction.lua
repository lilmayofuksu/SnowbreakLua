-- ========================================================
-- @File    : uw_fashion_interaction.lua
-- @Brief   : 交互
-- ========================================================
---@class tbClass : UUserWidget
---@field pViewTarget AActor
local tbClass = Class("UMG.SubWidget")

function tbClass:Init(pParent, InActor, MouseClickEvent)
    local pCameraManger = UE4.UGameplayStatics.GetPlayerCameraManager(self, 0)
    self.pViewTarget = pCameraManger.ViewTarget.Target
    self.Parent = pParent
    self.Actor  = InActor
    self.DefaultViewPos = self.pViewTarget:K2_GetActorLocation()
    self.DefaultActorRot = self.Actor:K2_GetActorRotation()
    self.MouseClickEvent = MouseClickEvent


    self.NewRot = self.DefaultActorRot.Pitch
end

function tbClass:OnMouseButtonDown(MyGeometry, MouseEvent)
    self.bPress = true
    self.StartPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function tbClass:OnMouseButtonUp(MyGeometry, MouseEvent)
    self.bPress = false
    if self.bMove then
        self.bMove = false
        return UE4.UWidgetBlueprintLibrary.UnHandled()
    end

    if self.MouseClickEvent then
        self.MouseClickEvent()
    end
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function tbClass:OnMouseMove(MyGeometry, MouseEvent)
    if not self.bPress then
        return UE4.UWidgetBlueprintLibrary.UnHandled()
    end
     
    self.EndPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
    if not self.bMove and self:GetSize(self.EndPos - self.StartPos) < 80 then
        return UE4.UWidgetBlueprintLibrary.UnHandled()
    end
    self.bMove = true
    
    local DeltaPos = UE4.UKismetInputLibrary.PointerEvent_GetCursorDelta(MouseEvent)
    if DeltaPos.X ~= 0 or DeltaPos.Y ~= 0 then
        self:OnMove(DeltaPos.Y)
    end
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function tbClass:OnMouseLeave(MouseEvent)
    self.bPress = false
end

function tbClass:OnZoomChange(Value)
    if self.Parent == nil then return end
    self.Parent.NowFov = math.max(self.Parent.MinFov, math.min(self.Parent.MaxFov, self.Parent.NowFov + Value * self.ZoomSpeed))
    self.Parent:SetFov()
end

function tbClass:OnMove(Value)
    if self.Actor then
        self.NewRot = self.NewRot or 0
        self.NewRot =  self.NewRot +  Value * -1 * 0.5
        self.Actor:K2_SetActorRotation(UE4.FRotator(self.NewRot, self.DefaultActorRot.Yaw, self.DefaultActorRot.Roll))
    end
end

function tbClass:GetSize(InVector2D)
    return math.sqrt(InVector2D.X * InVector2D.X + InVector2D.Y * InVector2D.Y)
end

function tbClass:OnClose()
    local SweepResult = UE4.FHitResult()
    if self.Actor then
        self.Actor:K2_SetActorRotation(self.DefaultActorRot)
    end

    if self.pViewTarget then
        self.pViewTarget:K2_SetActorLocation(self.DefaultViewPos, true, SweepResult, true)
    end
end

return tbClass
