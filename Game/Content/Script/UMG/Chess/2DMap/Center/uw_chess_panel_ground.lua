-- ========================================================
-- @File    : uw_chess_panel_ground.lua
-- @Brief   : 棋盘地面编辑
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.tbGridPool = {}    -- grid pool
    self.tbMapData = {}     -- 当前使用的格子
    self.canvasSlotRoot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Root)
    self:RegisterEvent(Event.NotifyChessRegionRefresh, function(Id) 
        -- 加定时器是为了避免界面闪烁
        UE4.Timer.Cancel(self.timerId or 0)
        self.timerId = UE4.Timer.Add(0.01, function() self:NotifyChessRegionRefresh(Id) end)
    end)

    self:RegisterEvent(Event.NotifyChessSelectedObject, function(tbParam, isSelected) self:OnChessSelectedObject(tbParam, isSelected) end)
    self:RegisterEvent(Event.NotifyUpdateChessObject, function(tbParam) self:OnUpdateObject(tbParam) end)
end

function view:NotifyChessRegionRefresh(Id)
    self:FreeAllGrid()    
    if not Id or Id <= 0 then return end
    local tbRegion = ChessEditor:GetRegionDataById(Id)
    tbRegion.tbGround = tbRegion.tbGround or {}
    for x = tbRegion.RangeX.min, tbRegion.RangeX.max do 
        for y = tbRegion.RangeY.min, tbRegion.RangeY.max do 
            local gridId = ChessTools:GridXYToId(x, y) 
            local objectId = ChessEditor:GetGroundObjectId(tbRegion, gridId)
            local tbGrid = self:AllocGrid(x, y, gridId)
            local position = UE.FVector2D(x * 100, y * 100)
            tbGrid.objectId = objectId
            tbGrid.regionId = Id
            tbGrid.gridId = gridId
            tbGrid.widget.wSlot:SetPosition(position)
            tbGrid.widget:SetData(tbGrid)
        end 
    end
end

function view:OnChessSelectedObject(tbParam, isSelected)
    if tbParam.type ~= "grid" then return end
    local tbData = self.tbMapData[tbParam.id];
    if tbData then 
        tbData.widget:SetSelected(isSelected)
    end
end

function view:OnUpdateObject(tbParam)
    if tbParam.type ~= "grid" then return end
    local tbData = self.tbMapData[tbParam.id];
    if tbData then 
        tbData.widget:Refresh()
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
        local widget = LoadWidget("/Game/UI/UMG/Chess/2DMap/Center/uw_chess_tpl_grid.uw_chess_tpl_grid_C")
        self.Root:AddChild(widget)
        widget.wSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(widget)
        widget.wSlot:SetAlignment(UE.FVector2D(0.5, 0.5))
        widget.wSlot:SetMinimum(UE.FVector2D(0.5, 0.5))
        widget.wSlot:SetMaximum(UE.FVector2D(0.5, 0.5))
        tbData.widget = widget
    end
    tbData.X = X;
    tbData.Y = Y;
    tbData.Select = false;
    tbData.__isFree = false
    self.tbMapData[gridId] = tbData
    return tbData;
end

function view:FreeAllGrid()
    for key, tb in pairs(self.tbMapData) do 
        tb.__isFree = true
        WidgetUtils.Collapsed(tb.widget)
        table.insert(self.tbGridPool, tb)
    end
    self.tbMapData = {}
end

function view:FreeGridByKey(key)
    local tb = self.tbMapData[key]
    if tb then 
        tb.__isFree = true
        WidgetUtils.Collapsed(tb.widget)
        table.insert(self.tbGridPool, tb)
        self.tbMapData[key] = nil
    end
end

return view