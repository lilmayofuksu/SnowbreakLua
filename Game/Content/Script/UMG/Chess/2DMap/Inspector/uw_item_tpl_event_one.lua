-- ========================================================
-- @File    : uw_item_tpl_event_one.lua
-- @Brief   : 事件条目
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorGreen = UE4.UUMGLibrary.GetSlateColor(0, 0.35, 0, 1) 

function view:Construct()
    self.__Index = 0
    BtnAddEvent(self.BtnAdd, function() self:OnBtnClickAddEvent() end)
    BtnAddEvent(self.BtnExpand, function() self:OnBtnClickExpand() end)
    BtnAddEvent(self.BtnId, function() self:OnBtnClickId() end)

    local _color = self.Background.ColorAndOpacity
    local defaultBGColor = UE4.UUMGLibrary.GetSlateColor(_color.R, _color.G, _color.B, _color.A) 
    self:RegisterEvent(Event.NotifyChessSelectEvent, function(tbParam)
        if tbParam and not tbParam.titleType and tbParam.eventIndex == self.index and tbParam.groupIndex == self.groupIndex then 
            self.Background:SetColorAndOpacity(ColorGreen)
        else 
            self.Background:SetColorAndOpacity(defaultBGColor)
        end
    end)
end

function view:SetData(parent, index, tbEventData)
    self.tbEventData = tbEventData
    self.index = index
    self.parent = parent
    self.groupIndex = self.parent.index

    if self.tbEventData.isAdd then 
        WidgetUtils.Collapsed(self.Childs)
        WidgetUtils.Collapsed(self.Title)
        WidgetUtils.Collapsed(self.Id)
        WidgetUtils.Visible(self.BtnAdd)
        return;
    end

    WidgetUtils.SelfHitTestInvisible(self.Title)
    WidgetUtils.Collapsed(self.BtnAdd)

    self:Refresh()
end

function view:OnBtnClickAddEvent()
    table.insert(self.parent.tbEvents, {})
    ChessEditor:Snapshoot()
    self.parent:Refresh()
    ChessEditor:UpdateSelectedObject()
end

function view:OnBtnClickExpand()
    if self.tbEventData.expand == nil then 
        self.tbEventData.expand = true
    end
    self.tbEventData.expand = not self.tbEventData.expand
    ChessEditor:Snapshoot()
    self:Refresh()
end

function view:Refresh()
    local expand = self.tbEventData.expand
    if expand == nil or expand == true then 
        WidgetUtils.SelfHitTestInvisible(self.Childs)
        WidgetUtils.SelfHitTestInvisible(self.Id)
        self.TxtExpand:SetText("-")
    else 
        WidgetUtils.Collapsed(self.Childs)
        WidgetUtils.Collapsed(self.Id)
        self.TxtExpand:SetText("+")
        return
    end
    self:FreeAll()

    self.TxtId:SetText(ChessEditor:GetObjectEventIdName(self.tbEventData.id))

    -- 执行条件
    local tbCondition = self.tbEventData.tbCondition or {}
    self.tbEventData.tbCondition = tbCondition
    if #tbCondition == 0 then 
        table.insert(tbCondition, {id = ChessEvent.DefaultCondition, tbParam = {}}) 
    end
    for i = 1, #tbCondition do 
        self:ShowItem(ChessEvent.TypeCondition, "条件" .. i, tbCondition[i], i)
    end

    -- 执行时机
    local tbTiming = self.tbEventData.tbTiming or {id = ChessEvent.DefaultTiming, tbParam = {}}
    self.tbEventData.tbTiming = tbTiming
    self:ShowItem(ChessEvent.TypeTiming, "时机", tbTiming, 1)

    -- 行为内容
    local tbAction = self.tbEventData.tbAction or {}
    self.tbEventData.tbAction = tbAction
    if #tbAction == 0 then 
        table.insert(tbAction, {id = "", tbParam = {}}) 
    end
    for i = 1, #tbAction do 
        self:ShowItem(ChessEvent.TypeAction, "行为" .. i, tbAction[i], i)
    end

    local hint = ""
    if #tbAction > 1 then hint = "等".. #tbAction end

    local tbCfg = ChessEvent:GetConfig(ChessEvent.TypeAction, tbAction[1].id);
    if tbCfg then 
        self.TxtName:SetText(string.format("事件%d %s %s", self.index, tbCfg.Name, hint))
    else 
        self.TxtName:SetText(string.format("事件%d", self.index))
    end
    EventSystem.Trigger(Event.NotifyChessInspectorUpdate)
end

function view:ShowItem(type, titile, tbData, titleIndex)
    local tbCfg = ChessEvent:GetConfig(type, tbData.id);
    self:Alloc():SetStyleTitle(self, type, titile, tbData, tbCfg, titleIndex)

    if tbCfg then 
        for index, tbCfg in ipairs(tbCfg.tbParam) do 
            self:Alloc():SetStyleParam(self, tbData, tbCfg, type, index, titleIndex)
        end
    end
end

function view:OnBtnClickId()
    local tbParam = {
        type = "select",
        typeId = 2,         -- 类型id
        multi = false,       -- 开启多选
        tbSelect = self.tbEventData.id and {self.tbEventData.id} or {},
        openType = 1,
        onSelect = function(tbRet)
            self.tbEventData.id = tbRet[1]
            self.TxtId:SetText(ChessEditor:GetObjectEventIdName(self.tbEventData.id))
            ChessEditor:Snapshoot()
        end
    }
    EventSystem.Trigger(Event.ApplyOpenChessSetting, tbParam)
end

---------------------------------------------------------------------
--- event
---------------------------------------------------------------------
function view:OnMouseButtonDown(MyGemetry, MouseEvent)
    local key = UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent)
    if key == ChessEditor.KeyRightMouseButton then 
        local tbParam = {
            {"向前插入事件", self.Menu_InsertBefor, self},
            {"向后插入事件", self.Menu_InsertAfter, self},
            {"删除当前事件", self.Menu_DeleteCurrent, self},
        }
        EventSystem.Trigger(Event.NotifyChessShowMenu, tbParam)
    end
    EventSystem.Trigger(Event.NotifyChessSelectEvent, {eventIndex = self.index, groupIndex = self.groupIndex})
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function view:Menu_InsertBefor()
    table.insert(self.parent.tbEvents, self.index, {})
    ChessEditor:Snapshoot()
    self.parent:Refresh()
    EventSystem.Trigger(Event.NotifyChessSelectEvent, {eventIndex = self.index, groupIndex = self.groupIndex})
    ChessEditor:UpdateSelectedObject()
end

function view:Menu_InsertAfter()
    table.insert(self.parent.tbEvents, self.index + 1, {})
    ChessEditor:Snapshoot()
    self.parent:Refresh()
    EventSystem.Trigger(Event.NotifyChessSelectEvent, {eventIndex = self.index + 1, groupIndex = self.groupIndex})
    ChessEditor:UpdateSelectedObject()
end

function view:Menu_DeleteCurrent()
    table.remove(self.parent.tbEvents, self.index)
    ChessEditor:Snapshoot()
    self.parent:Refresh()
    EventSystem.Trigger(Event.NotifyChessSelectEvent)
    ChessEditor:UpdateSelectedObject()
end

---------------------------------------------------------------------
--- pool
---------------------------------------------------------------------
function view:Alloc()
    local widget = self.VerticalChilds:GetChildAt(self.__Index)
    if not widget then 
        widget = LoadWidget("/Game/UI/UMG/Chess/2DMap/Inspector/uw_item_tpl_event_arg.uw_item_tpl_event_arg_C")
        self.VerticalChilds:AddChild(widget)
    end
    WidgetUtils.Visible(widget)
    self.__Index = self.__Index + 1
    return widget
end

function view:FreeAll()
    local childCount = self.VerticalChilds:GetChildrenCount()
    for i = 1, childCount do 
        WidgetUtils.Collapsed(self.VerticalChilds:GetChildAt(i - 1))
    end
    self.__Index = 0
end

return view