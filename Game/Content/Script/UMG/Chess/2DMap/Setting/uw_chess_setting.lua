-- ========================================================
-- @File    : uw_chess_setting.lua
-- @Brief   : 地图配置界面
-- ========================================================

--[[
    注意，基于数据存储的考虑，配置条目只允许添加和修改，不允许删除。
    名字不允许重复，以名字进行排序
--]]

local view = Class("UMG.SubWidget")

local tbTypes = {
    [1] = "物件Tag",
    [2] = "事件Id",
    [3] = "物件Id",
}

function view:Construct()
    self.Factory = Model.Use(self)
    WidgetUtils.Collapsed(self.Root)
    
    BtnAddEvent(self.BtnClose, function() self:OnButtonClickClose() end)
    BtnAddEvent(self.BtnOK, function() self:OnButtonClickOK() end) 
    BtnAddEvent(self.BtnAdd, function() self:OnButtonClickAdd() end)

    self:RegisterEvent(Event.ApplyOpenChessSetting, function(tbParam)  
        self:OnOpen(tbParam)
    end)

    self:RegisterEvent(Event.NotifyChessSettingTypeChanged, function() self:UpdateContentPanelShow() end)
    self:RegisterEvent(Event.NotifySetChessMapDataComplete, function() 
        if ChessEditor.SettingUIIsOpen then 
            self:OnOpen()
        else 
            self:OnButtonClickClose()
        end
    end)
end

--[[
local tbParam = {
    type = "select",    -- 打开类型
    typeId = 1,         -- 类型id
    multi = true,       -- 开启多选
    tbSelect = {},      -- 默认选中
    openType = 1,       -- 打开类型 (1隐藏 已经被使用的；2正常)
    onSelect = function(tbRet)
        self.tbEvent.tag = tbRet
        ChessEditor:Snapshoot()
    end
}
--]]
function view:OnOpen(tbParam)
    self.tbParam = tbParam;
    self.isSelectMode = tbParam and tbParam.type == "select"  -- 是不是选择模式
    self.tbCurrentSelect = {}
    self.openType = (tbParam and tbParam.openType) or 2
    if tbParam and tbParam.tbSelect then
        for _, id in ipairs(tbParam.tbSelect) do 
            self.tbCurrentSelect[id] = true
        end
    end

    WidgetUtils.SetVisibleOrCollapsed(self.BtnOK, self.isSelectMode)
    WidgetUtils.Visible(self.Root)   
    ChessEditor:SetSettingUIIsOpen(true)
    self:UpdateTypeShow()

    if self.isSelectMode then 
        WidgetUtils.Collapsed(self.BtnAdd)
        WidgetUtils.Visible(self.TxtTip)
        self:UpdateSelectedShow()
    else 
        WidgetUtils.Visible(self.BtnAdd)
        WidgetUtils.Collapsed(self.TxtTip)
    end
end

--- 是不是选择模式
function view:IsSelectedMode()
    return self.isSelectMode
end

--- 得到当前的配置类型
function view:GetCurrentSettingType()
    if self.isSelectMode then return self.tbParam.typeId end
    return ChessEditor.CurrentSettingType
end

--- 选中
function view:DoSelect(id)
    if not self.isSelectMode then return end

    if self.tbParam.multi then 
        self.tbCurrentSelect[id] = not self.tbCurrentSelect[id]
    else
        local has = self.tbCurrentSelect[id] 
        self.tbCurrentSelect = {}
        self.tbCurrentSelect[id] = not has
    end
    self:UpdateSelectedShow()
end 

--- 更新选中状态
function view:UpdateSelectedShow()
    for _, tb in ipairs(self.tbContent) do 
        tb.select = self.tbCurrentSelect[tb.id] and true or false
        if tb.refresh then 
            tb.refresh(tb.id)
        end
    end
    local count = 0;
    for i, v in pairs(self.tbCurrentSelect) do 
        if v then count = count + 1 end
    end
    self.TxtTip:SetText(string.format("选择了 %d 项", count))
end

------------------------------------------------------------
function view:UpdateTypeShow()
    self:DoClearListItems(self.ListViewType)
    for id, name in ipairs(tbTypes) do
        if not self.isSelectMode or self.tbParam.typeId == id then 
            self.ListViewType:AddItem(self.Factory:Create({id = id, name = name, parent = self}))
        end
    end
    
    if not ChessEditor.CurrentSettingType or ChessEditor.CurrentSettingType <= 0 then 
        ChessEditor:SetCurrentSettingType(1)
    else 
        self:UpdateContentPanelShow()
    end
end

function view:UpdateContentPanelShow()
    WidgetUtils.Collapsed(self.PanelTag)
    WidgetUtils.Collapsed(self.PanelEvent)
    WidgetUtils.Collapsed(self.PanelObjectId)
    local type = self.isSelectMode and self.tbParam.typeId or ChessEditor.CurrentSettingType
    if type == 1 then 
        self:UpdatePanelTag()
        WidgetUtils.SelfHitTestInvisible(self.PanelTag)
    elseif type == 2 then 
        self:UpdatePanelEvent()
        WidgetUtils.SelfHitTestInvisible(self.PanelEvent)
    elseif type == 3 then 
        self:UpdatePanelObjectId()
        WidgetUtils.SelfHitTestInvisible(self.PanelObjectId)
    end
end

function view:UpdatePanelTag()
    local tbTags = ChessEditor:GetTagDef()
    local tbList = {}
    for id, tb in ipairs(tbTags) do 
        tb.id = id
        tbList[#tbList + 1] = tb
    end
    table.sort(tbList, function(a, b) 
        if a.name == b.name then 
            return a.id < b.id
        end
        return a.name < b.name
    end)
    self:DoClearListItems(self.ListViewTag)
    self.tbContent = {}
    for idx, cfg in ipairs(tbList) do 
        local tb = {index = idx, id = cfg.id, cfg = cfg, parent = self}
        self.ListViewTag:AddItem(self.Factory:Create(tb))
        table.insert(self.tbContent, tb)
    end
end

function view:UpdatePanelObjectId()
    local tbIds = ChessEditor:GetObjectIdDef()
    local tbList = {}
    for id, tb in ipairs(tbIds) do 
        tb.id = id
        tbList[#tbList + 1] = tb
    end
    table.sort(tbList, function(a, b) 
        if a.name == b.name then 
            return a.id < b.id
        end
        return a.name < b.name
    end)
    self:DoClearListItems(self.ListViewObjectId)
    self.tbContent = {}
    for idx, cfg in ipairs(tbList) do 
        local tb = {index = idx, id = cfg.id, cfg = cfg, openType = self.openType, parent = self}
        self.ListViewObjectId:AddItem(self.Factory:Create(tb))
        table.insert(self.tbContent, tb)
    end
end

function view:UpdatePanelEvent()
    local tbEvents = ChessEditor:GetEventDef()
    local tbList = {}
    for id, tb in ipairs(tbEvents) do 
        tb.id = id
        tbList[#tbList + 1] = tb
    end
    table.sort(tbList, function(a, b) 
        if a.name == b.name then 
            return a.id < b.id
        end
        return a.name < b.name
    end)
    self:DoClearListItems(self.ListViewEvent)
    self.tbContent = {}
    for idx, cfg in ipairs(tbList) do 
        local tb = {index = idx, id = cfg.id, cfg = cfg, openType = self.openType, parent = self}
        self.ListViewEvent:AddItem(self.Factory:Create(tb))
        table.insert(self.tbContent, tb)
    end
end

------------------------------------------------------------
function view:OnButtonClickOK()
    self:OnButtonClickClose()
    if self.isSelectMode then 
        local tbRet = {}
        for _, tb in ipairs(self.tbContent) do 
            if tb.select then 
                table.insert(tbRet, tb.id)
            end
        end
        self.tbParam.onSelect(tbRet)
    end
end

function view:OnButtonClickClose()
    ChessEditor:SetSettingUIIsOpen(false)
    WidgetUtils.Collapsed(self.Root)
end

function view:OnButtonClickAdd()
    if ChessEditor.CurrentSettingType == 1 then 
        local tb = ChessEditor:GetTagDef()
        table.insert(tb, {name = "_add", desc = ""})
    elseif ChessEditor.CurrentSettingType == 2 then 
        local tb = ChessEditor:GetEventDef()
        table.insert(tb, {name = "_add", desc = "", max = 1})
    elseif ChessEditor.CurrentSettingType == 3 then 
        local tb = ChessEditor:GetObjectIdDef()
        table.insert(tb, {name = "_add", desc = ""})
    end
    self:UpdateContentPanelShow()
    ChessEditor:Snapshoot()
end

------------------------------------------------------------
return view
------------------------------------------------------------