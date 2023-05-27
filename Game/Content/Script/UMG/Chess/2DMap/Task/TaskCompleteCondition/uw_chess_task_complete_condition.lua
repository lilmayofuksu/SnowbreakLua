-- ========================================================
-- @File    : uw_chess_task_complete_condition.lua
-- @Brief   : 地图任务 - 任务id
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    BtnAddEvent(self.BtnClose, function() self:OnClose() end)
    BtnAddEvent(self.BtnOK, function() self:OnOK() end)

    BtnAddEvent(self.BtnTaskVarA, function() self:OnBtnClickVarA() end)
    BtnAddEvent(self.BtnTaskVarB, function() self:OnBtnClickVarB() end)

    local all = ChessTaskCompleteCondition:GetAllConditionNames()
    for _, name in ipairs(all) do 
        self.ParamTypeSelect:AddOption(name)
    end

    self.ParamTypeSelect.OnSelectionChanged:Add(self, function(_, type, c) 
        local id = ChessTaskCompleteCondition:FindIdByName(type)
        if id then 
            self.tbParam.cfg.id = id
            self:OnConditionTypeChanged()
        end
    end)

    self.InputValue.OnTextCommitted:Add(self, function(_, value) self:OnEditorInputValue(value) end)
end

--[[
tbParam = 
{
    title = "标题",
    cfg = {      -- 参数列表
    },
    okHandler = function() end, -- 确认回调
}
--]]
function view:OnOpen(tbParam)
    WidgetUtils.SelfHitTestInvisible(self)
    self.tbParam = tbParam;
    self.tbData = {}
    self.TxtTitle:SetText(tbParam.title or "")

    local name = ChessTaskCompleteCondition:FindNameById(tbParam.cfg.id)
    if name then 
        self.ParamTypeSelect:SetSelectedOption(name)
    else 
        self.ParamTypeSelect:SetSelectedOption("")
    end
    self:OnConditionTypeChanged()
end

function view:OnConditionTypeChanged()
    local id = self.tbParam.cfg.id;
    WidgetUtils.SelfHitTestInvisible(self.VarA)

    if id >= 1 and id <= 3 then 
        self.TitleA:SetText("任务变量")
        self.TitleB:SetText("固定值");
        WidgetUtils.SelfHitTestInvisible(self.VarB)
        WidgetUtils.Collapsed(self.TaskVarId2)
        WidgetUtils.SelfHitTestInvisible(self.ParamInput)

    elseif id >= 11 and id <= 12 then 
        self.TitleA:SetText("任务变量")
        WidgetUtils.Collapsed(self.VarB)

    elseif id >= 21 and id <= 23 then 
        self.TitleA:SetText("任务变量A")
        self.TitleB:SetText("任务变量B");
        WidgetUtils.SelfHitTestInvisible(self.VarB)
        WidgetUtils.SelfHitTestInvisible(self.TaskVarId2)
        WidgetUtils.Collapsed(self.ParamInput)
    else 
        WidgetUtils.Collapsed(self.VarB)
        WidgetUtils.Collapsed(self.VarA)
    end
    self:Refresh()
end

function view:Refresh()
    local id = self.tbParam.cfg.id;
    local tbParam = self.tbParam.cfg.tbParam

    local def = ChessConfigHandler:GetTaskVarById(tbParam['a'])
    if def then 
        self.TxtTaskVarAId:SetText(string.format("%d - %s", def.id, def.name))
    else 
        self.TxtTaskVarAId:SetText("")
    end
    
    if id >= 1 and id <= 3 then 
        self.InputValue:SetText(tbParam['b'])
    else 
        local def = ChessConfigHandler:GetTaskVarById(tbParam['b'])
        if def then 
            self.TxtTaskVarBId:SetText(string.format("%d - %s", def.id, def.name))
        else 
            self.TxtTaskVarBId:SetText("")
        end
    end
end

function view:OnOK()
    for _, tb in ipairs(self.tbData) do 
        tb.widget:TrySave()
        self.tbParam.cfg.tbParam[tb.id] = tb.value
    end

    if self.tbParam.okHandler then 
        self.tbParam.okHandler(self.tbParam.cfg)
    end
    self:OnClose()
end

function view:OnClose()
    WidgetUtils.Collapsed(self)
end

------------------------------------------------------------
function view:OnBtnClickVarA()
    local v = self.tbParam.cfg.tbParam['a']
    local tbParam = {
        title = "任务变量列表",
        type = "taskvar",
        id = tonumber(v) or 0,
        onSelect = function (tbRet)
            self.tbParam.cfg.tbParam['a'] = tbRet[1]
            self:Refresh()
        end
    }
    EventSystem.Trigger(Event.NotifyOpenSelectorUI, tbParam)
end

function view:OnBtnClickVarB()
    local v = self.tbParam.cfg.tbParam['b']
    local tbParam = {
        title = "任务变量列表",
        type = "taskvar",
        id = tonumber(v) or 0,
        onSelect = function (tbRet)
            self.tbParam.cfg.tbParam['b'] = tbRet[1]
            self:Refresh()
        end
    }
    EventSystem.Trigger(Event.NotifyOpenSelectorUI, tbParam)
end

function view:OnEditorInputValue(value)
    self.tbParam.cfg.tbParam['b'] = tonumber(value) or 0
end

------------------------------------------------------------
return view
------------------------------------------------------------