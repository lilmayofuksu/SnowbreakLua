-- ========================================================
-- @File    : uw_item_tpl_event_group.lua
-- @Brief   : 事件组
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorGreen = UE4.UUMGLibrary.GetSlateColor(0, 0.35, 0, 1) 

function view:Construct()
    self.tbCurrent = self.tbCurrent or {}
    self.tbPool = self.tbPool or {}

    BtnAddEvent(self.BtnAdd, function() self:OnBtnClickAddEventGroup() end)
    BtnAddEvent(self.BtnExpand, function() self:OnBtnClickExpand() end)

    local _color = self.Background.ColorAndOpacity
    local defaultBGColor = UE4.UUMGLibrary.GetSlateColor(_color.R, _color.G, _color.B, _color.A) 
    self:RegisterEvent(Event.NotifyChessSelectEvent, function(tbParam)
        if not tbParam or tbParam.eventIndex or tbParam.groupIndex ~= self.index then 
            self.Background:SetColorAndOpacity(defaultBGColor)
        else 
            self.Background:SetColorAndOpacity(ColorGreen)
        end
    end)
end

function view:SetData(index, tbGroupData)
    self.index = index
    self.tbGroupData = tbGroupData;
    if self.tbGroupData.isAdd then 
        WidgetUtils.Collapsed(self.Title)
        WidgetUtils.Collapsed(self.Childs)
        WidgetUtils.Visible(self.BtnAdd)
        return
    end

    WidgetUtils.Collapsed(self.BtnAdd)
    WidgetUtils.SelfHitTestInvisible(self.Childs)
    WidgetUtils.SelfHitTestInvisible(self.Title)
    
    self:Refresh()
end

function view:OnBtnClickAddEventGroup()
    ChessEditor.tbCurrentInspectorData.tbGroups = ChessEditor.tbCurrentInspectorData.tbGroups or {}
    table.insert(ChessEditor.tbCurrentInspectorData.tbGroups, {})
    ChessEditor:Snapshoot()
    EventSystem.Trigger(Event.NotifyChessUpdateInspector)
    EventSystem.Trigger(Event.NotifyChessSelectEvent, {groupIndex = #ChessEditor.tbCurrentInspectorData.tbGroups})
end

function view:OnBtnClickExpand()
    if self.tbGroupData.expand == nil then 
        self.tbGroupData.expand = true
    end
    self.tbGroupData.expand = not self.tbGroupData.expand
    ChessEditor:Snapshoot()
    self:Refresh()
end

function view:Refresh()
    self:FreeAll()
    self.tbEvents = self.tbGroupData.tbEvents or {}
    self.tbGroupData.tbEvents = self.tbEvents
    self.TxtGroupName:SetText("Group" .. self.index)
    local expand = self.tbGroupData.expand
    if expand == nil or expand then
        self.TxtExpand:SetText("收拢")
        for i = 1, #self.tbEvents do 
            self:Alloc(i):SetData(self, i, self.tbEvents[i])
        end
        local index = #self.tbEvents + 1
        self:Alloc(index):SetData(self, index, {isAdd = true})
    else 
        self.TxtExpand:SetText("展开")
    end
end

---------------------------------------------------------------------
--- event
---------------------------------------------------------------------
function view:OnMouseButtonDown(MyGemetry, MouseEvent)
    local key = UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent)
    if key == ChessEditor.KeyRightMouseButton then 
        local tbParam = {
            {"向前插入Group", self.Menu_InsertBefor, self},
            {"向后插入Group", self.Menu_InsertAfter, self},
            {"删除当前Group", self.Menu_DeleteCurrent, self},
        }
        EventSystem.Trigger(Event.NotifyChessShowMenu, tbParam)
    end
    EventSystem.Trigger(Event.NotifyChessSelectEvent, {groupIndex = self.index})
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function view:Menu_InsertBefor()
    table.insert(ChessEditor.tbCurrentInspectorData.tbGroups, self.index, {})
    ChessEditor:Snapshoot()
    EventSystem.Trigger(Event.NotifyChessUpdateInspector)
    EventSystem.Trigger(Event.NotifyChessSelectEvent, {groupIndex = self.index})
    ChessEditor:UpdateSelectedObject()
end

function view:Menu_InsertAfter()
    table.insert(ChessEditor.tbCurrentInspectorData.tbGroups, self.index + 1, {})
    ChessEditor:Snapshoot()
    EventSystem.Trigger(Event.NotifyChessUpdateInspector)
    EventSystem.Trigger(Event.NotifyChessSelectEvent, {groupIndex = self.index + 1})
    ChessEditor:UpdateSelectedObject()
end

function view:Menu_DeleteCurrent()
    table.remove(ChessEditor.tbCurrentInspectorData.tbGroups, self.index)
    ChessEditor:Snapshoot()
    EventSystem.Trigger(Event.NotifyChessUpdateInspector)
    EventSystem.Trigger(Event.NotifyChessSelectEvent)
    ChessEditor:UpdateSelectedObject()
end

---------------------------------------------------------------------
--- pool
---------------------------------------------------------------------
function view:Alloc(Index)
    local widget = self.Events:GetChildAt(Index - 1)
    if not widget then 
        widget = LoadWidget("/Game/UI/UMG/Chess/2DMap/Inspector/uw_item_tpl_event_one.uw_item_tpl_event_one_C")
        self.Events:AddChild(widget)
    end
    WidgetUtils.Visible(widget)
    return widget
end

function view:FreeAll()
    local childCount = self.Events:GetChildrenCount()
    for i = 1, childCount do 
        WidgetUtils.Collapsed(self.Events:GetChildAt(i - 1))
    end
end
---------------------------------------------------------------------
return view
---------------------------------------------------------------------