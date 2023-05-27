-- ========================================================
-- @File    : uw_chess_task_arg.lua
-- @Brief   : 地图任务 - 任务参数
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    BtnAddEvent(self.BtnEventId, function() self:OnBtnClickSetting(2) end)
    BtnAddEvent(self.BtnTag, function() self:OnBtnClickSetting(1) end)
    BtnAddEvent(self.BtnGrid, function() self:OnBtnClickGrid() end)
    BtnAddEvent(self.BtnObjectId, function() self:OnBtnClickSetting(3) end)
    BtnAddEvent(self.BtnItemId, function() self:OnBtnClickItemId() end)
    BtnAddEvent(self.BtnRewardId, function() self:OnBtnClickRewardId() end)
    BtnAddEvent(self.BtnCheckBox, function() self:OnBtnClickCheckBox() end)
    BtnAddEvent(self.BtnTaskVar, function() self:OnBtnClickTaskVar() end)
    BtnAddEvent(self.BtnTaskId, function() self:OnBtnClickTaskId() end)

    self.InputValue.OnTextCommitted:Add(self, function(_, value) 
        if self.onSetParamValue then 
            self.onSetParamValue(value) 
        end
    end)

    self.ParamTypeSelect.OnSelectionChanged:Add(self, function(_, type, c) 
        if not self.onSetParamValue then return end 

        if self.tbCfg.type == ChessTask.InputTypeModifyVar then 
            self.onSetParamValue(ChessTask:FindModifyTypeIdByName(type)) 
        else 
            assert(false)
        end
    end)
end


function view:SetData(tbCfg)
    self.tbCfg = tbCfg;
    self.onSetParamValue = nil
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
    self.TxtHeader:SetText(tbCfg.name)
    self.InputValue:SetText(tbCfg.value or "")
    self.currentValue = tbCfg.value
    
    if tbCfg.type == ChessTask.InputTypeText then 
        WidgetUtils.SelfHitTestInvisible(self.ParamInput)
        self:SetTextValue(self.InputValue, self.currentValue or "")
    elseif tbCfg.type == ChessTask.InputTypeCombo then 
        WidgetUtils.Visible(self.ParamTypeSelect)
    elseif tbCfg.type == ChessTask.InputTypeGrids then 
        WidgetUtils.SelfHitTestInvisible(self.Grids)
        self:SetTextValue(self.TxtGrid, ChessEditor:GetGridDesc(self.currentValue))
    elseif tbCfg.type == ChessTask.InputTypeTag then 
        WidgetUtils.SelfHitTestInvisible(self.Tag)
        self:SetTextValue(self.TxtTag, ChessEditor:GetObjectTagDesc(self.currentValue))
    elseif tbCfg.type == ChessTask.InputTypeEvent then 
        WidgetUtils.SelfHitTestInvisible(self.EventId)
        self:SetTextValue(self.TxtEventId, ChessEditor:GetObjectEventIdName(self.currentValue))
    elseif tbCfg.type == ChessTask.InputTypeObjectId then 
        WidgetUtils.SelfHitTestInvisible(self.ObjectId)
        self:SetTextValue(self.TxtObjectId, ChessEditor:GetObjectIdDesc(self.currentValue))
    elseif tbCfg.type == ChessTask.InputTypeCheckBox then 
        WidgetUtils.SelfHitTestInvisible(self.CheckBox)
        self:SetTextValue(self.TxtCheckBox, self.currentValue and "是" or "否")
    elseif tbCfg.type == ChessTask.InputTypeItemId then 
        WidgetUtils.SelfHitTestInvisible(self.ItemId)
        self:SetTextValue(self.TxtItemId, ChessEditor:GetItemNameDesc(self.currentValue))
    elseif tbCfg.type == ChessTask.InputTypeRewardId then 
        WidgetUtils.SelfHitTestInvisible(self.RewardId)
        self:SetTextValue(self.TxtRewardId, ChessEditor:GetRewardNameDesc(self.currentValue))
    elseif tbCfg.type == ChessTask.InputTypeTaskId then 
        self:SetTextValue(self.TxtTaskId, ChessEditor:GetTaskDesc(self.currentValue))
        WidgetUtils.SelfHitTestInvisible(self.TaskId)
    elseif tbCfg.type == ChessTask.InputTypeTaskVarId then 
        self:SetTextValue(self.TxtTaskVarId, ChessEditor:GetTaskVarDesc(self.currentValue))
        WidgetUtils.SelfHitTestInvisible(self.TaskVarId)
    elseif tbCfg.type == ChessTask.InputTypeModifyVar then 
        WidgetUtils.SelfHitTestInvisible(self.ParamTypeSelect)
        self.ParamTypeSelect:ClearOptions()
        for _, tb in ipairs(ChessTask.TaskModifyType) do 
            self.ParamTypeSelect:AddOption(tb.name)
        end
        self.ParamTypeSelect:SetSelectedOption(ChessTask:FindModifyTypeNameById(tonumber(self.currentValue)))
    end

    self.onSetParamValue = function(value)
        if value ~= self.currentValue then 
            tbCfg.value = value;
            self.parent:Refresh()
        end
    end
end

function view:TrySave()
    if self.tbCfg.type == ChessTask.InputTypeText then 
        local value = self.InputValue:GetText()
        self.tbCfg.value = value;
    end
end

function view:SetTextValue(ui, value)
    self.contentValue = value
    ui:SetText(value)
end

function view:OnSelected()
end

------------------------------------------------------------
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

function view:OnBtnClickCheckBox()
    self.onSetParamValue(not self.currentValue)
end

function view:OnBtnClickGrid()
    local ui = UI.GetUI("ChessMap")
    local tbParam = {
        tbSelect = self.currentValue;
        onOK = function(tbRet)
            WidgetUtils.SelfHitTestInvisible(ui.uw_chess_task.Root)
            ChessEditor.IsTopUIMode = true
            self.onSetParamValue(tbRet)
        end,
        onCancel = function()
            WidgetUtils.SelfHitTestInvisible(ui.uw_chess_task.Root)
            ChessEditor.IsTopUIMode = true
        end
    }
    self:OnSelected()    
    WidgetUtils.Collapsed(ui.uw_chess_task.Root)
    ChessEditor.IsTopUIMode = false
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
    local tbParam = {
        title = "任务列表",
        type = "taskid",
        id = self.currentValue and self.currentValue[1] or nil,
        onSelect = function (tbRet)
            self.onSetParamValue(tbRet)
        end
    }
    EventSystem.Trigger(Event.NotifyOpenSelectorUI, tbParam)
end

------------------------------------------------------------
return view
------------------------------------------------------------