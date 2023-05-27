-- ========================================================
-- @File    : uw_chess_interaction.lua
-- @Brief   : 交互
-- ========================================================
---@class tbClass : UUserWidget
---@field pViewTarget AActor
local tbClass = Class("UMG.SubWidget")

function tbClass:OnMouseButtonDown(MyGeometry, MouseEvent)
    if ChessClient:GetLockControl() then return UE4.UWidgetBlueprintLibrary.UnHandled() end
    self.bPress = true
    self.StartPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function tbClass:OnMouseButtonUp(MyGeometry, MouseEvent)
    if ChessClient:GetLockControl() then
        self.bPress = false
        return UE4.UWidgetBlueprintLibrary.UnHandled()
    end
    self.bPress = false
    if self.bMove then
        self.bMove = false
        return UE4.UWidgetBlueprintLibrary.UnHandled()
    end
    if not self.playerController then
        self.playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
    end
    self.playerController:TrySetMoveDestination();
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function tbClass:OnMouseMove(MyGeometry, MouseEvent)
    if not self.bPress or ChessClient:GetLockControl() then
        return UE4.UWidgetBlueprintLibrary.UnHandled()
    end
    local CameraFollow = ChessClient.gameMode.CameraFollow
    self.EndPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
    -- print("============> try out put move test data", self.EndPos, self.StartPos)
    -- if self:CheckIsVector2DZero(self.EndPos) then
    --     return
    -- end
    if self:GetSize(self.EndPos - self.StartPos) < 80 and not self.bMove then
        return UE4.UWidgetBlueprintLibrary.UnHandled()
    end
    self.bMove = true
    
    local DeltaPos = UE4.UKismetInputLibrary.PointerEvent_GetCursorDelta(MouseEvent)
    if DeltaPos.X ~= 0 or DeltaPos.Y ~= 0 then
        if CameraFollow then
            CameraFollow:OnMouseMove(DeltaPos)
        end
    end
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function tbClass:BP_OnMouseLeave()
    self.bPress = false
end

function tbClass:GetSize(InVector2D)
    return math.sqrt(InVector2D.X * InVector2D.X + InVector2D.Y * InVector2D.Y)
end

function tbClass:CheckIsVector2DZero(InVector2D)
    if InVector2D.X == 0 and InVector2D.Y == 0 then
        return true
    end
    return false
end

return tbClass
