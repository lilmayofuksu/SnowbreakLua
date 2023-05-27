-- ========================================================
-- @File    : uw_chess_map_menu.lua
-- @Brief   : 
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
local ColorWhite = UE.FLinearColor(0.484, 0.484, 0.484, 1);
local PageCount = 3

function view:Construct()
    self.Factory = Model.Use(self)
    BtnAddEvent(self.BtnTypeGrid, function() self:OnBtnClickGrid() end)
    BtnAddEvent(self.BtnTypeMap, function() self:OnBtnClickMap() end)
    BtnAddEvent(self.BtnRunCurrent, function() 
        ChessEditor:TryAutoSave()
        ChessEditor:RunFromCurrentRegion() 
        EventSystem.Trigger(Event.NotifyHideChessMap)
    end)
    BtnAddEvent(self.BtnRunLast, function() 
        ChessEditor:TryAutoSave()
        ChessEditor:RunFromLastRegion() 
        EventSystem.Trigger(Event.NotifyHideChessMap)
    end)

    BtnAddEvent(self.BtnSave, function() ChessEditor:Save() end)
    BtnAddEvent(self.BtnHelp, function() EventSystem.Trigger(Event.NotifyChessOpenHelp) end)

    for i = 1, PageCount do 
        BtnAddEvent(self["BtnPage" .. i], function() self:OnBtnClickGridPage(i) end)
    end

    ChessEditor:RegisterBtnHoverTip(self.BtnSave, "保存地图数据")
    ChessEditor:RegisterBtnHoverTip(self.BtnHelp, "显示帮助信息")
    ChessEditor:RegisterBtnHoverTip(self.BtnRunCurrent, "从当前选中区域运行")
    ChessEditor:RegisterBtnHoverTip(self.BtnRunLast, "从上次区域区域运行")
    
    self:RegisterEvent(Event.NotifyChessMoudleChanged, function() 
        self:InitMapNames() 
        self:InitGridNames() 
    end)

    self:RegisterEvent(Event.NotifyChess2DMapOpened, function() 
        self.gridPageIdx = 1
        self:InitModuleNames()
        if ChessEditor:CheckHasData() then 
            self:OnBtnClickGrid()    
        else 
            self:OnBtnClickMap()    
        end
    end)

    self:RegisterEvent(Event.NotifyModifyMapCreateData, function(mapId, isCreate) 
        ChessEditor.CurrentMapId = mapId
        self.gridPageIdx = 1
        self:InitMapNames({dontUpdateMap = not isCreate}) 
        if isCreate then 
            self:OnBtnClickGrid() 
        end
    end)
end


function view:CollapsedAllList()
    WidgetUtils.Collapsed(self.PanelGrid)
    WidgetUtils.Collapsed(self.PanelMap)
    self.BtnTypeGrid:SetBackgroundColor(ColorWhite)
    self.BtnTypeMap:SetBackgroundColor(ColorWhite)
end

function view:OnBtnClickGridPage(idx)
    self.gridPageIdx = idx
    self:InitGridNames()
end

------------------------------------------------------------
-- 初始化各种列表
-- 初始化地图列表
function view:InitMapNames(tbParam)
    self:DoClearListItems(self.ListView_MapName)
    self.tbMapNameParams = {}
    local tbList = ChessEditor:GetMapList()
    local checkMapId;
    for i, v in ipairs(tbList) do 
        if v.Id == ChessEditor.CurrentMapId then 
            checkMapId = true;
            break;
        end
    end
    if not checkMapId then 
        ChessEditor.CurrentMapId = #tbList > 0 and tbList[1].Id or 0
    end
    for _, tb in ipairs(tbList) do 
        local tbParam = {Id = tb.Id, Name = tb.Name, Select = ChessEditor.CurrentMapId == tb.Id}
        tbParam.onSelect = function() 
            for _, tbParam in ipairs(self.tbMapNameParams) do 
                tbParam.Select = tb.Id == tbParam.Id
            end
            ChessEditor.CurrentMapId = tb.Id
            ChessEditor:ResetSnapshoot()
            ChessEditor:SetCurrentMap(ChessEditor.CurrentMapId)
            ChessEditor:Snapshoot()
        end
        self.ListView_MapName:AddItem(self.Factory:Create(tbParam))
        table.insert(self.tbMapNameParams, tbParam)
    end
    self.ListView_MapName:AddItem(self.Factory:Create({isAdd = true}))
    if not tbParam or not tbParam.dontUpdateMap then 
        ChessEditor:SetCurrentMap(ChessEditor.CurrentMapId)
    end
end

-- 初始化格子定义
function view:InitGridNames()
    self:DoClearListItems(self.ListView_GridName)
    self.tbGridNameParams = {}
    local tbDef = ChessEditor:GetGridDef()
    for _, tb in ipairs(tbDef.tbList) do 
        -- 3号表示资源丢失
        if tb.Id ~= 3 and (tb.PageIndex == self.gridPageIdx or tb.Id < 10) then 
            local tbParam = {Id = tb.Id, Cfg = tb}
            self.ListView_GridName:AddItem(self.Factory:Create(tbParam))
            table.insert(self.tbGridNameParams, tbParam)
        end
    end

    for i = 1, PageCount do 
        if i == self.gridPageIdx then 
            self["BtnPage" .. i]:SetBackgroundColor(ColorGreen)
        else
            self["BtnPage" .. i]:SetBackgroundColor(ColorWhite)
        end
    end

    ChessEditor:SetCurrentGridId(ChessEditor.CurrentGridId)
    self.ListView_GridName:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

-- 初始化模块列表
function view:InitModuleNames()
    self:DoClearListItems(self.ListView_ModuleName)
    self.tbModuleNameParams = {}
    local tbList = ChessConfig:GetModuleList();
    for id, name in ipairs(tbList) do
        local tbParam = {Id = id, Name = name}
        self.ListView_ModuleName:AddItem(self.Factory:Create(tbParam))
        table.insert(self.tbModuleNameParams, tbParam)
    end
    if ChessEditor.ModuleName and ChessEditor.ModuleName ~= "" then 
        ChessEditor:SetCurrentModule(ChessEditor.ModuleName)
    elseif tbList[1] then 
        ChessEditor:SetCurrentModule(tbList[1])
    end
end


------------------------------------------------------------
-- 各种事件  
function view:OnBtnClickGrid()
    self:CollapsedAllList()
    WidgetUtils.SelfHitTestInvisible(self.PanelGrid)
    self.BtnTypeGrid:SetBackgroundColor(ColorGreen)
end

function view:OnBtnClickMap()
    self:CollapsedAllList()
    WidgetUtils.SelfHitTestInvisible(self.PanelMap)
    self.BtnTypeMap:SetBackgroundColor(ColorGreen)
end

function view:OnMouseEnter()
    ChessEditor.EnterMenuOrInspector = true
end

return view