-- ========================================================
-- @File    : uw_chess_tpl_region.lua
-- @Brief   : 棋盘区域模板
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.slotBackground = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Background)
    self.slotOptionsLeft = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Left);
    self.slotOptionsTop = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Top);
    self.slotOptionsRight = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Right);
    self.slotOptionsBottom = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Bottom);
    self.slotOptionsTitle = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Title);

    BtnAddEvent(self.BtnLeftAdd, function() self:Expand("left", -1) end);
    BtnAddEvent(self.BtnLeftSub, function() self:Expand("left", 1) end);
    BtnAddEvent(self.BtnTopAdd, function() self:Expand("top", -1) end);
    BtnAddEvent(self.BtnTopSub, function() self:Expand("top", 1) end);
    BtnAddEvent(self.BtnRightAdd, function() self:Expand("right", 1) end);
    BtnAddEvent(self.BtnRightSub, function() self:Expand("right", -1) end);
    BtnAddEvent(self.BtnBottomAdd, function() self:Expand("bottom", 1) end);
    BtnAddEvent(self.BtnBottomSub, function() self:Expand("bottom", -1) end);

    self:RegisterEvent(Event.NotifyChessEditorTypeChanged, function() self:NotifyChessEditorTypeChanged() end)
end

function view:EventOnSelect()
end

function view:SetData(tbData)
    self.Id = tbData.Id
    self.tbData = tbData;
    self:Refresh()
    self:NotifyChessEditorTypeChanged()
end

function view:Refresh()
    local tbRegion = ChessEditor:GetRegionDataById(self.Id)
    local SizeX = tbRegion.RangeX.max - tbRegion.RangeX.min + 1
    local SizeY = tbRegion.RangeY.max - tbRegion.RangeY.min + 1
    local size = UE.FVector2D(SizeX * 100, SizeY * 100)
    local minPos = UE.FVector2D(tbRegion.RangeX.min * 100 - 50, tbRegion.RangeY.min * 100 - 15)
    local maxPos = minPos + size
    local middle = minPos + size / 2
    self.slotBackground:SetSize(size);
    self.slotBackground:SetPosition(middle)
    self.TxtTitle:SetText(string.format("%d区域 [%d*%d]", self.Id, SizeX, SizeY));
    self.slotOptionsLeft:SetPosition(UE.FVector2D(minPos.X - 25, middle.Y))
    self.slotOptionsRight:SetPosition(UE.FVector2D(maxPos.X + 25, middle.Y))
    self.slotOptionsTop:SetPosition(UE.FVector2D(middle.X, minPos.Y - 25))
    self.slotOptionsBottom:SetPosition(UE.FVector2D(middle.X, maxPos.Y + 25))
    self.slotOptionsTitle:SetPosition(UE.FVector2D(minPos.X, minPos.Y - 25))
end

function view:Expand(type, value)
    if ChessEditor.IsCtrlDown then value = value * 5 end

    local tbRegion = ChessEditor:GetRegionDataById(self.Id)
    local xMin, xMax = tbRegion.RangeX.min, tbRegion.RangeX.max
    local yMin, yMax = tbRegion.RangeY.min, tbRegion.RangeY.max
    if type == "left" then 
        local newValue = tbRegion.RangeX.min + value
        if newValue > tbRegion.RangeX.max then return end
        tbRegion.RangeX.min = math.max(newValue, -128);
        
    elseif type == "top" then 
        local newValue = tbRegion.RangeY.min + value
        if newValue > tbRegion.RangeY.max then return end
        tbRegion.RangeY.min = math.max(newValue, -128);;

    elseif type == "bottom" then 
        local newValue = tbRegion.RangeY.max + value
        if newValue < tbRegion.RangeY.min then return end
        tbRegion.RangeY.max = math.min(newValue, 127);

    elseif type == "right" then 
        local newValue = tbRegion.RangeX.max + value
        if newValue < tbRegion.RangeX.min then return end
        tbRegion.RangeX.max = math.min(newValue, 127);;
    end

    local xMinNew, xMaxNew = tbRegion.RangeX.min, tbRegion.RangeX.max
    local yMinNew, yMaxNew = tbRegion.RangeY.min, tbRegion.RangeY.max
    self:FillDefaultGround(tbRegion, xMinNew, xMin - 1, yMin, yMax)
    self:FillDefaultGround(tbRegion, xMax + 1, xMaxNew, yMin, yMax)
    self:FillDefaultGround(tbRegion, xMin, xMax, yMinNew, yMin - 1)
    self:FillDefaultGround(tbRegion, xMin, xMax, yMax + 1, yMaxNew)

    self:Refresh()
    ChessEditor:RemoveAllInvalidGround()
    EventSystem.Trigger(Event.NotifyChessRegionDetailChanged, self.Id)
    EventSystem.Trigger(Event.NotifyChessRegionRefresh, self.Id)
    ChessEditor:Snapshoot()
end

function view:FillDefaultGround(tbRegion, xMin, xMax, yMin, yMax)
    if xMax < xMin or yMax < yMin then return end 
    local groundId = ChessEditor.tbMapData.tbData.DefaultGroundId
    if groundId <= 0 then return end

    for x = xMin, xMax do 
        for y = yMin, yMax do 
            local gridId = ChessTools:GridXYToId(x, y);
            ChessEditor:SetGroundObjectId(tbRegion, gridId, groundId);
        end
    end
end

function view:NotifyChessEditorTypeChanged()
    if ChessEditor.EditorType == ChessEditor.EditorTypeRegion then 
        WidgetUtils.SelfHitTestInvisible(self.PanelOptions)
        WidgetUtils.SelfHitTestInvisible(self.TxtCtrlTip)
        WidgetUtils.SelfHitTestInvisible(self.Background)
    else 
        WidgetUtils.Collapsed(self.PanelOptions)
        WidgetUtils.Collapsed(self.TxtCtrlTip)
        WidgetUtils.Collapsed(self.Background)
    end
end

return view