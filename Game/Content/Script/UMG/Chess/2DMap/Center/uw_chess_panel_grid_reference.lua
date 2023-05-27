-- ========================================================
-- @File    : uw_chess_panel_grid_reference.lua
-- @Brief   : 棋盘区域格子关联显示
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.tbGridPool = {}    -- grid pool
    self.tbMapData = {}     -- 当前使用的格子

    self:RegisterEvent(Event.NotifyChessEditorTypeChanged, function(type) self:OnChessEditorTypeChanged(type) end)
    self:RegisterEvent(Event.NotifyChessEntryGridHintMode, function(tbParam) 
        if ChessEditor.EditorTypeEvent == ChessEditor.EditorType then
            self:FreeAllGrid()
        end 
    end)
    self:RegisterEvent(Event.NotifyChessInspectorUpdate, function()
        if ChessEditor.EditorTypeEvent ~= ChessEditor.EditorType then return end
        self:OnSelect()
    end)
end

function view:OnChessEditorTypeChanged(type)
    if type ~= ChessEditor.EditorTypeEvent then
        self:FreeAllGrid()
    end
    if type == ChessEditor.EditorTypeEvent  then 
        self:OnSelect()
    end
end

function view:OnSelect()
    self:FreeAllGrid()
    self.tbReference = self:GetReferenceGrids()
    if not self.tbReference then
        return
    end
    self:NotifyChessRegionRefresh()
end

--- 获取到所有的关联格子
function view:GetReferenceGrids()
    local tbGrids = {}
    local tbData = ChessEditor.tbCurrentInspectorData
    if not tbData then
        return
    end
    local tbGroups = tbData.tbGroups
    if not tbGroups then
        return
    end
    for _, tbGroup in pairs(tbGroups) do
        local tbEvents = tbGroup.tbEvents
        if tbEvents then
            for _, tbEvent in pairs(tbEvents) do
                local tbAction = tbEvent.tbAction
                local tbCondition = tbEvent.tbCondition
                if tbCondition then
                    for _, Condition in pairs(tbCondition) do
                        self:GetReferenceGridsFromEvent(tbGrids, Condition, 1)
                    end
                end
                if tbAction then
                    for _, Action in pairs(tbAction) do
                        self:GetReferenceGridsFromEvent(tbGrids, Action, 2)
                    end
                end
            end
        end
    end

    return tbGrids
end

function view:GetReferenceGridsFromEvent(tbGrid, EventData, type)
    local tbParam = EventData.tbParam
    local gridIds = tbParam.gridId
    local objectIds = tbParam.objectId
    local objectTags = tbParam.objectTag
    if gridIds then
        if not tbGrid["IsGrid"] then
            tbGrid["IsGrid"] = {}
        end
        for _, gridId in pairs(gridIds) do
            table.insert(tbGrid["IsGrid"], gridId[2])
        end
    end
    if objectIds then
        if not tbGrid["IsObject"] then
            tbGrid["IsObject"] = {}
        end
        for _, objectId in pairs(objectIds) do
            local tbList = ChessEditor:GetObjectIdUsed(objectId)
            for _, cfg in pairs(tbList) do
                local gridId = self:GetGridDesc(cfg)
                if gridId then
                    table.insert(tbGrid["IsObject"], gridId)
                end
            end
        end
    end
    if objectTags then
        if not tbGrid["IsObject"] then
            tbGrid["IsObject"] = {}
        end
        for _, objectTag in pairs(objectTags) do
            local tbList = ChessEditor:GetTagUsed(objectTag)
            for _, cfg in pairs(tbList) do
                local gridId = self:GetGridDesc(cfg)
                if gridId then
                    table.insert(tbGrid["IsObject"], gridId)
                end
            end
        end
    end
end

function view:GetGridDesc(cfg)
    local tbRegion = ChessEditor:GetRegionDataById(cfg.regionId)
    if cfg.type == "grid" then 
        return cfg.id
    elseif cfg.type == "object" then 
        local tb = tbRegion.tbObjects[cfg.id]
        return ChessTools:GridXYToId(tb.pos[1], tb.pos[2])
    end
end

function view:NotifyChessRegionRefresh()
    --Dump(self.tbReference)
    for type, tbGrids  in pairs (self.tbReference) do
        for _, gridId in pairs(tbGrids) do
            local grid = self.tbMapData[gridId]
            if grid and grid.widget:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
                grid.widget:SetType(type)
            else
                local X, Y = ChessTools:GridIdToXY(gridId) 
                local tbGrid = self:AllocGrid(X, Y, gridId)
                local position = UE.FVector2D(X * 100, Y * 100)
                tbGrid.parent = self
                tbGrid.gridId = gridId
                tbGrid.type = type
                tbGrid.widget.wSlot:SetPosition(position)
                tbGrid.widget:SetData(tbGrid)
            end
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
        local widget = LoadWidget("/Game/UI/UMG/Chess/2DMap/Center/uw_chess_tpl_grid_reference.uw_chess_tpl_grid_reference_C")
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