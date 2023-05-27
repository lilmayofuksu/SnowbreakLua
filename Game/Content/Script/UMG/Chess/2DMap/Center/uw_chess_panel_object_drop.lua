-- ========================================================
-- @File    : uw_chess_panel_object_drop.lua
-- @Brief   : 棋盘物件编辑
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.tbGridPool = {}    -- grid pool
    self.tbMapData = {}     -- 当前使用的格子

    self:RegisterEvent(Event.NotifyChessBeginDrag, function(tbParam) self:OnEnter(tbParam) end)
    self:RegisterEvent(Event.NotifyChessEndDrag, function() self:OnExit() end)
    self:OnExit()
end


function view:OnEnter(tbParam)
    self.tbParam = tbParam

    WidgetUtils.SelfHitTestInvisible(self.Panel)
    self:NotifyChessRegionRefresh()
end

function view:NotifyChessRegionRefresh()
    self:FreeAllGrid()

    self.lastSelectedGrid = nil
    local tbRegion = ChessEditor:GetCurrentRegionData()
    for x = tbRegion.RangeX.min, tbRegion.RangeX.max do 
        for y = tbRegion.RangeY.min, tbRegion.RangeY.max do 
            local gridId = ChessTools:GridXYToId(x, y) 
            local tbGrid = self:AllocGrid(x, y, gridId)
            local position = UE.FVector2D(x * 100, y * 100)
            tbGrid.regionId = ChessEditor.CurrentRegionId
            tbGrid.parent = self
            tbGrid.gridId = gridId
            tbGrid.widget.wSlot:SetPosition(position)
            tbGrid.widget:SetData(tbGrid)
        end 
    end
end

function view:OnExit()
    WidgetUtils.Collapsed(self.Panel)
end

function view:OnSelected(gridId)
    if gridId == self.lastSelectedGrid then return end 

    local tbOld = self.tbMapData[self.lastSelectedGrid]
    if tbOld then 
        tbOld.widget:SetSelected(false)
    end

    if gridId then 
        self.lastSelectedGrid = gridId
        local tbNew = self.tbMapData[gridId]
        if tbNew then 
            tbNew.widget:SetSelected(true)
        end
    end
end

---------------------------------------------------------------------
--- pool
---------------------------------------------------------------------
function view:AllocGrid(X, Y, gridId)
    local tbData;
    if #self.tbGridPool > 0 then 
        tbData = self.tbGridPool[#self.tbGridPool]
        WidgetUtils.Visible(tbData.widget)
        table.remove(self.tbGridPool, #self.tbGridPool)
    else 
        tbData = {}
        local widget = LoadWidget("/Game/UI/UMG/Chess/2DMap/Center/uw_chess_tpl_object_drop.uw_chess_tpl_object_drop_C")
        self.Root:AddChild(widget)
        widget.wSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(widget)
        widget.wSlot:SetAlignment(UE.FVector2D(0.5, 0.5))
        widget.wSlot:SetMinimum(UE.FVector2D(0.5, 0.5))
        widget.wSlot:SetMaximum(UE.FVector2D(0.5, 0.5))
        tbData.widget = widget
    end
    tbData.X = X;
    tbData.Y = Y;
    self.tbMapData[gridId] = tbData
    return tbData;
end

function view:FreeAllGrid()
    for _, tb in pairs(self.tbMapData) do 
        WidgetUtils.Collapsed(tb.widget)
        table.insert(self.tbGridPool, tb)
    end
    self.tbMapData = {}
end

return view