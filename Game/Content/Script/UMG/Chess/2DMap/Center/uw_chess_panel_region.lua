-- ========================================================
-- @File    : uw_chess_panel_region.lua
-- @Brief   : 棋盘区域编辑
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.scale = 1
    self.canvasSlotRoot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Root)
    self:RegisterEvent(Event.NotifyChessSelectRegion, function(regionId) self:RefreshList(regionId) end)
    self:RegisterEvent(Event.NotifyChessPutRegion, function(regionId) self:OnPutNewRegion(regionId) end)
    self:RegisterEvent(Event.NotifyChessLayerFlagChanged, function(idx) self:NotifyChessLayerFlagChanged(idx) end)
    self:RegisterEvent(Event.NotifyChessMapChanged, function() 
        self:NotifyChessLayerFlagChanged()
    end)

    self:RegisterEvent(Event.NotifyChessLookAtPos, function(tbParam) self:OnLookAtPos(tbParam) end)
end

function view:RefreshList(regionId)
    WidgetUtils.Collapsed(self.uw_chess_tpl_region)
    if regionId and regionId > 0 then 
        WidgetUtils.SelfHitTestInvisible(self.uw_chess_tpl_region)
        self.uw_chess_tpl_region:SetData({Id = regionId})
    end
    EventSystem.Trigger(Event.NotifyChessRegionRefresh, regionId)
    self:ResetCanvasPosition(regionId)
end

function view:OnPutNewRegion(regionId)
    WidgetUtils.SelfHitTestInvisible(self.uw_chess_tpl_region)
    self.uw_chess_tpl_region:SetData({Id = regionId})
    EventSystem.Trigger(Event.NotifyChessRegionRefresh, regionId)
    self:ResetCanvasPosition(regionId)
end

function view:NotifyChessLayerFlagChanged(index)
    if not index or index > 1 then 
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.uw_chess_panel_object.PanelLayer1, ChessEditor.tbLayerFlag[2])
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.uw_chess_panel_object.PanelLayer2, ChessEditor.tbLayerFlag[3])
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.uw_chess_panel_object.PanelLayer3, ChessEditor.tbLayerFlag[4])
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.uw_chess_panel_object.PanelLayer4, ChessEditor.tbLayerFlag[5])
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.uw_chess_panel_object.PanelLayer5, ChessEditor.tbLayerFlag[6])
    end
end

function view:ResetCanvasPosition(regionId)
    local tbData = ChessEditor:GetRegionDataById(regionId)
    local x, y = 0, 0
    local scale = 1
    if tbData and tbData.CanvasPosition then 
        x = tbData.CanvasPosition[1] or 0
        y = tbData.CanvasPosition[2] or 0
        scale = tbData.CanvasScale or 1
    end
    local position = UE.FVector2D(x, y)
    self.canvasSlotRoot:SetPosition(position)
    ChessEditor.RegionOffset = position
    self.scale = scale
    self.Root:SetRenderScale(UE.FVector2D(self.scale, self.scale));
end

---------------------------------------------------------------------
--- event
---------------------------------------------------------------------
--- 移动
function view:Event_Move(delta)
    local position = self.canvasSlotRoot:GetPosition() + delta
    ChessEditor.RegionOffset = position
    self.canvasSlotRoot:SetPosition(position)
    local tbRegion = ChessEditor:GetCurrentRegionData()
    if tbRegion then 
        tbRegion.CanvasPosition = {position.X, position.Y}
    end
end

--- 缩放
function view:Event_OnMouseWheel(delta)
    local newSize = self.scale * (delta > 0 and 1.1 or 0.9)
    if newSize > 2 then newSize = 2
    elseif newSize < 0.5 then newSize = 0.5
    end
    
    if self.scale ~= newSize then 
        local ScaleDelta = newSize - self.scale
        local NewPosition = self:MousePosToWidgetPos(ScaleDelta)
        local tbRegion = ChessEditor:GetCurrentRegionData()
        self.canvasSlotRoot:SetPosition(NewPosition)
        if tbRegion then 
            tbRegion.CanvasPosition = {NewPosition.X, NewPosition.Y}
        end
        self.scale = newSize
        self.Root:SetRenderScale(UE.FVector2D(self.scale, self.scale)); 

        local tbRegion = ChessEditor:GetCurrentRegionData()
        if tbRegion then 
            tbRegion.CanvasScale = self.scale
        end
    end
end

--- 看向
function view:OnLookAtPos(tbParam)
    local position = UE.FVector2D(tbParam.x * -100, tbParam.y * -100)
    ChessEditor.RegionOffset = position
    self.canvasSlotRoot:SetPosition(position)

    local tbRegion = ChessEditor:GetCurrentRegionData()
    if tbRegion then 
        tbRegion.CanvasPosition = {position.X, position.Y}
    end
end

function view:MousePosToWidgetPos(ScaleDelta)
    local CanvasPos = self.canvasSlotRoot:GetPosition()
    local ScreenSize = UE.UWidgetLayoutLibrary.GetViewportSize(self)
    local MousePos = UE4.UWidgetLayoutLibrary.GetMousePositionOnViewport(self) - ScreenSize / 2
    local PosDelta = MousePos - CanvasPos
    PosDelta = PosDelta * ScaleDelta + PosDelta
    local NewCanvasPos = MousePos - PosDelta 
    return NewCanvasPos
end

return view