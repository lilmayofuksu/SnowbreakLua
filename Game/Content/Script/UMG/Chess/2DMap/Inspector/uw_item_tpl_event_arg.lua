-- ========================================================
-- @File    : uw_item_tpl_event_arg.lua
-- @Brief   : 事件参数
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.TitleTypeSelect.OnSelectionChanged:Add(self, function(_, newSelect, c)  
        if self.onTitleTypeSelect then self.onTitleTypeSelect(newSelect) end
    end)

    self.InputValue.OnTextCommitted:Add(self, function(_, value) 
        if self.onSetParamValue then self.onSetParamValue(value) end
    end)

    self:RegisterEvent(Event.NotifyChessSelectEvent, function(tbParam)
        if tbParam and tbParam.eventIndex == self.parent.index and tbParam.groupIndex == self.parent.groupIndex 
            and tbParam.titleType and tbParam.titleType == self.titleType and tbParam.titleIndex == self.titleIndex 
            and tbParam.isTitle == self.isTitle and tbParam.paramIndex == self.paramIndex then 
            WidgetUtils.Visible(self.Background)
        else 
            WidgetUtils.Collapsed(self.Background)
        end
    end)

    self.ParamTypeSelect.OnSelectionChanged:Add(self, function(_, type, c) 
        if not self.onSetParamValue then return end 

        if self.tbCfg.type == ChessEvent.InputTypeModifyVar then 
            self.onSetParamValue(ChessTask:FindModifyTypeIdByName(type)) 
        else 
            assert(false)
        end
    end)

    BtnAddEvent(self.BtnEventId, function() self:OnBtnClickSetting(2) end)
    BtnAddEvent(self.BtnTag, function() self:OnBtnClickSetting(1) end)
    BtnAddEvent(self.BtnGrid, function() self:OnBtnClickGrid() end)
    BtnAddEvent(self.BtnObjectId, function() self:OnBtnClickSetting(3) end)
    BtnAddEvent(self.BtnItemId, function() self:OnBtnClickItemId() end)
    BtnAddEvent(self.BtnTaskVar, function() self:OnBtnClickTaskVar() end)
    BtnAddEvent(self.BtnTaskId, function() self:OnBtnClickTaskId() end)
    BtnAddEvent(self.BtnRewardId, function() self:OnBtnClickRewardId() end)
    BtnAddEvent(self.BtnCheckBox, function() self:OnBtnClickCheckBox() end)

    WidgetUtils.Collapsed(self.Background)
end

--- 显示条目（条件/事件/行为）
function view:SetStyleTitle(parent, type, titile, tbData, tbCfg, titleIndex)
    self.parent = parent
    self.isTitle = true
    self.titleType = type
    self.titleIndex = titleIndex
    self.paramIndex = nil
    self.tbCfg = tbCfg
    WidgetUtils.SelfHitTestInvisible(self.PanelTitle)
    WidgetUtils.Collapsed(self.PanelParam)
    self.TxtTitleHead:SetText(titile)

    self.onTitleTypeSelect = nil
    self.TitleTypeSelect:ClearOptions()
    local tbList = ChessEvent:GetList(type)
    for _, tb in ipairs(tbList) do 
        self.TitleTypeSelect:AddOption(tb.Name)
    end
    self.TitleTypeSelect:SetSelectedOption(tbCfg and tbCfg.Name or "")

    self.onTitleTypeSelect = function(newSelect)
        if not tbCfg or newSelect ~= tbCfg.Name then 
            for i, tb in ipairs(tbList) do 
                if tb.Name == newSelect then 
                    tbData.id = tb.Id
                    self.parent:Refresh()
                    ChessEditor:Snapshoot()
                    return
                end
            end
        end
    end
end

-- 显示条目参数
function view:SetStyleParam(parent, tbData, tbCfg, titleType, paramIndex, titleIndex)
    self.parent = parent
    self.isTitle = false
    self.paramIndex = paramIndex
    self.titleType = titleType
    self.titleIndex = titleIndex
    self.tbCfg = tbCfg
    WidgetUtils.Collapsed(self.PanelTitle)
    WidgetUtils.SelfHitTestInvisible(self.PanelParam)

    WidgetUtils.Collapsed(self.ParamTypeSelect)
    WidgetUtils.Collapsed(self.ParamInput)
    WidgetUtils.Collapsed(self.Grids)
    WidgetUtils.Collapsed(self.Tag)
    WidgetUtils.Collapsed(self.EventId)
    WidgetUtils.Collapsed(self.ObjectId)
    WidgetUtils.Collapsed(self.CheckBox)
    WidgetUtils.Collapsed(self.ItemId)
    WidgetUtils.Collapsed(self.RewardId)
    WidgetUtils.Collapsed(self.TaskId)
    WidgetUtils.Collapsed(self.TaskVarId)
    self.TxtParamHead:SetText(tbCfg.desc)
    self.currentValue = tbData.tbParam[tbCfg.id]
    self.onSetParamValue = nil

    if tbCfg.type == ChessEvent.InputTypeText then 
        WidgetUtils.SelfHitTestInvisible(self.ParamInput)
        self:SetTextValue(self.InputValue, self.currentValue or "")
    elseif tbCfg.type == ChessEvent.InputTypeCombo then 
        WidgetUtils.Visible(self.ParamTypeSelect)
    elseif tbCfg.type == ChessEvent.InputTypeGrids then 
        WidgetUtils.SelfHitTestInvisible(self.Grids)
        self:SetTextValue(self.TxtGrid, ChessEditor:GetGridDesc(self.currentValue))
    elseif tbCfg.type == ChessEvent.InputTypeTag then 
        WidgetUtils.SelfHitTestInvisible(self.Tag)
        self:SetTextValue(self.TxtTag, ChessEditor:GetObjectTagDesc(self.currentValue))
    elseif tbCfg.type == ChessEvent.InputTypeEvent then 
        WidgetUtils.SelfHitTestInvisible(self.EventId)
        self:SetTextValue(self.TxtEventId, ChessEditor:GetObjectEventIdName(self.currentValue))
    elseif tbCfg.type == ChessEvent.InputTypeObjectId then 
        WidgetUtils.SelfHitTestInvisible(self.ObjectId)
        self:SetTextValue(self.TxtObjectId, ChessEditor:GetObjectIdDesc(self.currentValue))
    elseif tbCfg.type == ChessEvent.InputTypeCheckBox then 
        WidgetUtils.SelfHitTestInvisible(self.CheckBox)
        self:SetTextValue(self.TxtCheckBox, (self.currentValue == true) and "√" or "")
    elseif tbCfg.type == ChessEvent.InputTypeItemId then 
        WidgetUtils.SelfHitTestInvisible(self.ItemId)
        self:SetTextValue(self.TxtItemId, ChessEditor:GetItemNameDesc(self.currentValue))
    elseif tbCfg.type == ChessEvent.InputTypeRewardId then 
        WidgetUtils.SelfHitTestInvisible(self.RewardId)
        self:SetTextValue(self.TxtRewardId, ChessEditor:GetRewardNameDesc(self.currentValue))
    elseif tbCfg.type == ChessEvent.InputTypeTaskId then 
        self:SetTextValue(self.TxtTaskId, ChessEditor:GetTaskDesc(self.currentValue))
        WidgetUtils.SelfHitTestInvisible(self.TaskId)
    elseif tbCfg.type == ChessEvent.InputTypeTaskVarId then 
        self:SetTextValue(self.TxtTaskVarId, ChessEditor:GetTaskVarDesc(self.currentValue))
        WidgetUtils.SelfHitTestInvisible(self.TaskVarId)
    elseif tbCfg.type == ChessEvent.InputTypeModifyVar then 
        WidgetUtils.SelfHitTestInvisible(self.ParamTypeSelect)
        self.ParamTypeSelect:ClearOptions()
        for _, tb in ipairs(ChessTask.TaskModifyType) do 
            self.ParamTypeSelect:AddOption(tb.name)
        end
        self.ParamTypeSelect:SetSelectedOption(ChessTask:FindModifyTypeNameById(tonumber(self.currentValue)))
    elseif tbCfg.type == ChessEvent.InputTypeFightId then 
        self:SetTextValue(self.TxtTaskId, ChessEditor:GetFightIdDesc(self.currentValue))
        WidgetUtils.SelfHitTestInvisible(self.TaskId)
    elseif tbCfg.type == ChessEvent.InputTypePlotId then 
        self:SetTextValue(self.TxtTaskId, ChessEditor:GetPlotIdDesc(self.currentValue))
        WidgetUtils.SelfHitTestInvisible(self.TaskId)
    elseif tbCfg.type == ChessEvent.InputTypeParticleId then 
        self:SetTextValue(self.TxtTaskId, ChessEditor:GetParticleIdDesc(self.currentValue))
        WidgetUtils.SelfHitTestInvisible(self.TaskId)
    elseif tbCfg.type == ChessEvent.InputTypeSequenceId then 
        self:SetTextValue(self.TxtTaskId, ChessEditor:GetSequenceIdDesc(self.currentValue))
        WidgetUtils.SelfHitTestInvisible(self.TaskId)
    elseif tbCfg.type == ChessEvent.InputTypeNpcId then
        self:SetTextValue(self.TxtTaskId, ChessEditor:GetNpcIdDesc(self.currentValue))
        WidgetUtils.SelfHitTestInvisible(self.TaskId)
    end

    self.onSetParamValue = function(value)
        if value ~= self.currentValue then 
            tbData.tbParam[tbCfg.id] = value;
            self.parent:Refresh()
            ChessEditor:Snapshoot()
        end
    end
end

function view:SetTextValue(ui, value)
    self.contentValue = value
    ui:SetText(value)
end

---------------------------------------------------------------------
--- event
---------------------------------------------------------------------
function view:OnMouseButtonDown(MyGemetry, MouseEvent)
    local key = UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent)
    if self.isTitle and key == ChessEditor.KeyRightMouseButton then 
        if self.titleType == ChessEvent.TypeAction then 
            local tbParam = {
                {"向前插入行为", self.Menu_InsertActionBefor, self},
                {"向后插入行为", self.Menu_InsertActionAfter, self},
                {"删除当前行为", self.Menu_DeleteCurrentAction, self},
            }
            EventSystem.Trigger(Event.NotifyChessShowMenu, tbParam)
        elseif self.titleType == ChessEvent.TypeCondition then 
            local tbParam = {
                {"向前插入条件", self.Menu_InsertConditionBefor, self},
                {"向后插入条件", self.Menu_InsertConditionAfter, self},
                {"删除当前条件", self.Menu_DeleteCurrentCondition, self},
            }
            EventSystem.Trigger(Event.NotifyChessShowMenu, tbParam)
        end
    end
    self:OnSelected()    
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function view:OnSelected(titleType, titleIndex, isTitle)
    EventSystem.Trigger(Event.NotifyChessSelectEvent, { 
        eventIndex = self.parent.index, 
        groupIndex = self.parent.groupIndex,
        titleType = titleType or self.titleType,
        titleIndex = titleIndex or self.titleIndex,
        isTitle = isTitle or self.isTitle,
        paramIndex = self.paramIndex
    })
end

function view:Menu_InsertActionBefor()
    table.insert(self.parent.tbEventData.tbAction, self.titleIndex, {id = "", tbParam = {}})
    self.parent:Refresh()
    ChessEditor:Snapshoot();
end

function view:Menu_InsertActionAfter()
    local tbArgs = {self.titleType, self.titleIndex + 1, self.isTitle}
    table.insert(self.parent.tbEventData.tbAction, self.titleIndex + 1, {id = "", tbParam = {}})
    self.parent:Refresh()
    ChessEditor:Snapshoot();
    self:OnSelected(table.unpack(tbArgs))
end

function view:Menu_DeleteCurrentAction()
    table.remove(self.parent.tbEventData.tbAction, self.titleIndex)
    self.parent:Refresh()
    ChessEditor:Snapshoot();
    EventSystem.Trigger(Event.NotifyChessSelectEvent)
end

function view:Menu_InsertConditionBefor()
    table.insert(self.parent.tbEventData.tbCondition, self.titleIndex, {id = "", tbParam = {}})
    self.parent:Refresh()
    ChessEditor:Snapshoot();
end

function view:Menu_InsertConditionAfter()
    local tbArgs = {self.titleType, self.titleIndex + 1, self.isTitle}
    table.insert(self.parent.tbEventData.tbCondition, self.titleIndex + 1, {id = "", tbParam = {}})
    self.parent:Refresh()
    ChessEditor:Snapshoot();
    self:OnSelected(table.unpack(tbArgs))
end

function view:Menu_DeleteCurrentCondition()
    table.remove(self.parent.tbEventData.tbCondition, self.titleIndex)
    self.parent:Refresh()
    ChessEditor:Snapshoot();
    EventSystem.Trigger(Event.NotifyChessSelectEvent)
end


function view:OnMouseEnter()
    if self.tbCfg and self.tbCfg.hint then 
        EventSystem.Trigger(Event.NotifyChessTipMsg, string.format("内容:%s  提示:%s", self.contentValue or "", self.tbCfg.hint) ) 
    end
end

function view:OnMouseLeave()
    EventSystem.Trigger(Event.NotifyChessTipMsg, "") 
end

---------------------------------------------------------------------
function view:OnBtnClickSetting(id)
    local tbParam = {
        type = "select",
        typeId = id,         -- 类型id
        multi = true,       -- 开启多选
        tbSelect = self.currentValue and self.currentValue or {},
        openType = 2,
        onSelect = function(tbRet)
            self.onSetParamValue(tbRet)
        end
    }
    self:OnSelected()    
    EventSystem.Trigger(Event.ApplyOpenChessSetting, tbParam)
end


function view:OnBtnClickGrid()
    local tbParam = {
        tbSelect = self.currentValue;
        onOK = function(tbRet)
            self.onSetParamValue(tbRet)
        end
    }
    self:OnSelected()    
    EventSystem.Trigger(Event.NotifyChessEntryGridHintMode, tbParam)
end

function view:OnBtnClickItemId()
    local tbParam = {
        id = self.currentValue and self.currentValue[1] or nil,
        onSelect = function(tbRet)
            self.onSetParamValue(tbRet)
        end
    }
    EventSystem.Trigger(Event.NotifyOpenSelectItemUI, tbParam)
end


function view:OnBtnClickRewardId()
    local tbParam = {
        id = self.currentValue and self.currentValue[1] or nil,
        onSelect = function(tbRet)
            self.onSetParamValue(tbRet)
        end
    }
    EventSystem.Trigger(Event.NotifyOpenSelectRewardUI, tbParam)
end

function view:OnBtnClickCheckBox()
    self.onSetParamValue(not self.currentValue)
end

function view:OnBtnClickTaskVar()
    local tbParam = {
        title = "任务变量列表",
        type = "taskvar",
        id = self.currentValue and self.currentValue[1] or nil,
        onSelect = function (tbRet)
            self.onSetParamValue(tbRet)
        end
    }
    EventSystem.Trigger(Event.NotifyOpenSelectorUI, tbParam)
end

function view:OnBtnClickTaskId()
    if self.tbCfg.type == ChessEvent.InputTypeTaskId then 
        local tbParam = {
            title = "任务列表",
            type = "taskid",
            id = self.currentValue and self.currentValue[1] or nil,
            onSelect = function (tbRet)
                self.onSetParamValue(tbRet)
            end
        }
        EventSystem.Trigger(Event.NotifyOpenSelectorUI, tbParam)
    elseif self.tbCfg.type == ChessEvent.InputTypeFightId then 
        local tbParam = {
            title = "战斗列表",
            type = "fight",
            id = self.currentValue and self.currentValue[1] or nil,
            onSelect = function (tbRet)
                self.onSetParamValue(tbRet)
            end
        }
        EventSystem.Trigger(Event.NotifyOpenSelectorUI, tbParam)
    elseif self.tbCfg.type == ChessEvent.InputTypePlotId then 
        local tbParam = {
            title = "剧情列表",
            type = "plot",
            id = self.currentValue and self.currentValue[1] or nil,
            onSelect = function (tbRet)
                self.onSetParamValue(tbRet)
            end
        }
        EventSystem.Trigger(Event.NotifyOpenSelectorUI, tbParam)
    elseif self.tbCfg.type == ChessEvent.InputTypeParticleId then 
        local tbParam = {
            title = "特效列表",
            type = "particle",
            id = self.currentValue and self.currentValue[1] or nil,
            onSelect = function (tbRet)
                self.onSetParamValue(tbRet)
            end
        }
        EventSystem.Trigger(Event.NotifyOpenSelectorUI, tbParam)
    elseif self.tbCfg.type == ChessEvent.InputTypeSequenceId then 
        local tbParam = {
            title = "Sequence列表",
            type = "sequence",
            id = self.currentValue and self.currentValue[1] or nil,
            onSelect = function (tbRet)
                self.onSetParamValue(tbRet)
            end
        }
        EventSystem.Trigger(Event.NotifyOpenSelectorUI, tbParam)
    elseif self.tbCfg.type == ChessEvent.InputTypeNpcId then 
        local tbParam = {
            title = "Npc列表",
            type = "npc",
            id = self.currentValue and self.currentValue[1] or nil,
            onSelect = function (tbRet)
                self.onSetParamValue(tbRet)
            end
        }
        EventSystem.Trigger(Event.NotifyOpenSelectorUI, tbParam)
    end
end
---------------------------------------------------------------------
return view
---------------------------------------------------------------------