-- ========================================================
-- @File    : uw_chess_panel_grid_hint.lua
-- @Brief   : 棋盘区域格子提示
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.tbGridPool = {}    -- grid pool
    self.tbMapData = {}     -- 当前使用的格子

    self:RegisterEvent(Event.NotifyChessRegionRefresh, function(Id) 
        if ChessEditor.IsGridHintMode then 
            self:NotifyChessRegionRefresh(Id)
            if self.tbParam.dirtyCB then self.tbParam.dirtyCB() end
        end
    end)

    self:RegisterEvent(Event.NotifyChessEntryGridHintMode, function(tbParam) self:OnEnter(tbParam) end)
    self:RegisterEvent(Event.NotifyChessExitGridHintMode, function() self:OnExit() end)
    self:OnExit()
end

--[[
tbParam = {
    tbSelect = {{1,1},{1,2},{1,3}},     -- 选中的格子列表{{区域id,格子id}}
    onOK = function(tbRet)              -- 选中成功

    end
}
--]]

function view:OnEnter(tbParam)
    ChessEditor.IsGridHintMode = true
    self.tbParam = tbParam
    self.tbSelected = {}
    self.tbSelectedOrder = {}
    tbParam.tbSelected = self.tbSelected
    tbParam.tbSelectedOrder = self.tbSelectedOrder
    tbParam.GetGridWidget = function(GridId)
        local tbData = self.tbMapData[GridId]
        return tbData and tbData.widget
    end
    if tbParam.tbSelect and type(tbParam.tbSelect) == "table" then 
        for _, tb in ipairs(tbParam.tbSelect) do 
            self:SetGridSelected(tb[1], tb[2], true)
        end
    end
    
    WidgetUtils.SelfHitTestInvisible(self.Panel)
    self:NotifyChessRegionRefresh()

    if tbParam.dirtyCB then tbParam.dirtyCB() end
end

function view:NotifyChessRegionRefresh()
    self:FreeAllGrid()

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
    ChessEditor.IsGridHintMode = false
    WidgetUtils.Collapsed(self.Panel)
end

-- 格子是否被选中
function view:IsGridSelected(regionId, gridId)
    local tb = self.tbSelected[regionId]
    return tb and tb[gridId]
end

function view:FindGridId(regionId, gridId)
    local tbGrid = self.tbSelectedOrder[regionId]
    if not tbGrid then return end
    for _, newGridId in pairs(tbGrid) do
        if gridId == newGridId then
            return _
        end
    end
end

-- 设置格子选中与否
function view:SetGridSelected(regionId, gridId, value)
    local tb = self.tbSelected[regionId] or {}
    local tbOrder = self.tbSelectedOrder[regionId] or {}
    self.tbSelected[regionId] = tb
    self.tbSelectedOrder[regionId] = tbOrder
    if value then 
        tb[gridId] = true
        table.insert(tbOrder, gridId)
    else
        local index = self:FindGridId(regionId, gridId)
        if tb[gridId] then
            table.remove(tbOrder, index)
        else
            table.insert(tbOrder, gridId)
        end
        tb[gridId] = not tb[gridId]
    end

    if self.tbParam.dirtyCB then 
        self.tbParam.dirtyCB()
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
        local widget = LoadWidget("/Game/UI/UMG/Chess/2DMap/Center/uw_chess_tpl_grid_hint.uw_chess_tpl_grid_hint_C")
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