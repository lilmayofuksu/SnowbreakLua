-- ========================================================
-- @File    : uw_chess_task.lua
-- @Brief   : 地图任务界面
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
local ColorNormal = UE.FLinearColor(0.45, 0.45, 0.45, 1);

function view:Construct()
    self.Factory = Model.Use(self)
    self.tbPool = {}
    WidgetUtils.Collapsed(self.Root)
    WidgetUtils.Collapsed(self.uw_chess_task_setting)
    WidgetUtils.Collapsed(self.uw_chess_task_condition)
    WidgetUtils.Collapsed(self.uw_chess_task_action)
    WidgetUtils.Collapsed(self.uw_chess_task_complete_condition)

    BtnAddEvent(self.BtnClose, function() self:OnClose() end)
    BtnAddEvent(self.BtnOK, function() self:OnButtonClickOK() end) 
    BtnAddEvent(self.BtnAdd, function() self:OnButtonClickAdd() end)
    BtnAddEvent(self.BtnConditionAdd, function() self:OnBtnClickConditionAdd() end)
    BtnAddEvent(self.BtnTaskComplete, function() self:OnBtnClickTaskCompleteCondition() end)
    BtnAddEvent(self.BtnEventBeginAdd, function() self:OnBtnClickAddEventBegin() end)
    BtnAddEvent(self.BtnEventEndAdd, function() self:OnBtnClickAddEventEnd() end)
    BtnAddEvent(self.BtnEventFailAdd, function() self:OnBtnClickAddEventFail() end)
    BtnAddEvent(self.BtnTaskArgEditor, function() self:OnBtnClickEditorTaskArg() end)
    BtnAddEvent(self.BtnTaskContentEditor, function() self:OnBtnClickEditorTaskContent() end)
    BtnAddEvent(self.BtnTaskList, function() self:ShowPanelByType("list") end)
    BtnAddEvent(self.BtnTaskVar, function() self:ShowPanelByType("var") end)

    self:RegisterEvent(Event.ApplyOpenChessTask, function()  
        self:OnOpen()
    end)

    self:RegisterEvent(Event.NotifySetChessMapDataComplete, function() 
        WidgetUtils.Collapsed(self.uw_chess_task_setting)
        WidgetUtils.Collapsed(self.uw_chess_task_condition)
        WidgetUtils.Collapsed(self.uw_chess_task_action)
        WidgetUtils.Collapsed(self.uw_chess_task_complete_condition)
        
        if not ChessConfigHandler:GetTempUICfg().isOpenTaskUI and WidgetUtils.IsVisible(self.Root) then 
             self:OnClose()
        elseif ChessConfigHandler:GetTempUICfg().isOpenTaskUI and not WidgetUtils.IsVisible(self.Root) then 
            self:OnOpen()
        else 
            if WidgetUtils.IsVisible(self.Root) then 
                self:UpdateTaskList()
                self:ShowPanelByType(ChessConfigHandler:GetTempUICfg().taskPanelType)
            end
        end
    end)
end

function view:OnOpen()
    self.currentCfg = nil
    ChessConfigHandler:GetTempUICfg().isOpenTaskUI = true
    self:ShowPanelByType("list")
    ChessEditor.IsTopUIMode = true
    WidgetUtils.Visible(self.Root)   
    self:UpdateTaskList()
end

function view:OnClose()
    WidgetUtils.Collapsed(self.Root)
    ChessEditor.IsTopUIMode = false
    ChessConfigHandler:GetTempUICfg().taskPanelType = nil
    self.currentCfg = nil

    if ChessConfigHandler:GetTempUICfg().isOpenTaskUI then 
        ChessConfigHandler:GetTempUICfg().isOpenTaskUI = nil
        ChessEditor:Snapshoot()
    end
end

function view:UpdateTaskList()
    local tbDef = ChessConfigHandler:GetTaskDef()
    local tbList = {}
    for id, tb in ipairs(tbDef) do 
        tbList[#tbList + 1] = tb
    end
    table.insert(tbList, {isAdd = true, tbArg = {id = -1}})
    self:DoClearListItems(self.ListViewType)
    WidgetUtils.Collapsed(self.Scroll)
    self.tbTasks = {}
    for _, cfg in ipairs(tbList) do 
        local tb = {id = cfg.tbArg.id, cfg = cfg, parent = self}
        self.ListViewType:AddItem(self.Factory:Create(tb))
        table.insert(self.tbTasks, tb)

        if cfg.tbArg.select then 
            self:UpdateTaskContent(cfg)
        end
    end
end

function view:IsSelectedMode()
    return false
end

function view:AddNewTask()
    local tbDef = ChessConfigHandler:GetTaskDef()
    local id = #tbDef + 1
    table.insert(tbDef, ChessConfigHandler:CreateTask(id))
    self:SetSelectedTaskId(id)
    self:UpdateTaskList()
end

function view:GetSelectedTaskCfg()
    local tbDef = ChessConfigHandler:GetTaskDef()
    for _, tb in ipairs(tbDef) do 
        if tb.tbArg.select then 
            return tb
        end
    end
    return 
end

------------------------------------------------------------
function view:SetSelectedTaskId(id, refreshUI)
    local curId = self.currentCfg and self.currentCfg.tbArg.id or 0
    local isNew = curId ~= id
    local tbDef = ChessConfigHandler:GetTaskDef()
    for _, tb in ipairs(tbDef) do 
        local value = tb.tbArg.id == id
        tb.tbArg.select = value
        if value then 
            self:UpdateTaskContent(tb)
        end
    end

    if refreshUI then 
        for _, tb in ipairs(self.tbTasks) do 
            if tb.ui then 
                tb.ui:UpdateSelected()
            end
        end
    end

    if isNew then 
        ChessEditor:Snapshoot()
    end
end

function view:SetSelectedItem(widget)
    for _, pool in pairs(self.tbPool) do 
        for _, tbData in ipairs(pool) do 
            if tbData.widget == widget then 
                tbData.widget:OnSelected(true)
            else 
                tbData.widget:OnSelected(false)
            end
        end
    end
end

function view:RefreshTaskContent()
    self:UpdateTaskContent(self.currentCfg)
end

function view:UpdateTaskContent(tbCfg)
    WidgetUtils.Visible(self.Scroll)
    self.currentCfg = tbCfg
    self:FreeAll()

    self:UpdateTaskArgDesc()
    self:UpdateTaskContentDesc()
    for _, tb in ipairs(tbCfg.tbCondition) do 
        local data = self:AllocItem(self.GroupCondition)
        data.widget:UpdateCondition(tbCfg.tbCondition, tb)
    end

    for _, tb in ipairs(tbCfg.tbTaskComplete) do 
        local data = self:AllocItem(self.GroupTaskComplete)
        data.widget:UpdateTaskCompleteCondition(tbCfg.tbTaskComplete, tb)
    end

    for _, tb in ipairs(tbCfg.tbTaskBegin) do 
        local data = self:AllocItem(self.GroupEventBegin)
        data.widget:UpdateEvent(tbCfg.tbTaskBegin, tb)
    end

    for _, tb in ipairs(tbCfg.tbTaskEnd) do 
        local data = self:AllocItem(self.GroupEventEnd)
        data.widget:UpdateEvent(tbCfg.tbTaskEnd, tb)
    end

    for _, tb in ipairs(tbCfg.tbTaskFail) do 
        local data = self:AllocItem(self.GroupEventFail)
        data.widget:UpdateEvent(tbCfg.tbTaskFail, tb)
    end
end


------------------------------------------------------------
-- 添加条件
function view:OnBtnClickConditionAdd()
    table.insert(self.currentCfg.tbCondition, {id = "None", tbParam = {}})

    self:FreeAll(self.GroupCondition)
    for _, tb in ipairs(self.currentCfg.tbCondition) do 
        local data = self:AllocItem(self.GroupCondition)
        data.widget:UpdateCondition(self.currentCfg.tbCondition, tb)
    end
    ChessEditor:Snapshoot()
end

-- 任务完成条件
function view:OnBtnClickTaskCompleteCondition()
    table.insert(self.currentCfg.tbTaskComplete, {id = 0, tbParam = {}})

    self:FreeAll(self.GroupTaskComplete)
    for _, tb in ipairs(self.currentCfg.tbTaskComplete) do 
        local data = self:AllocItem(self.GroupTaskComplete)
        data.widget:UpdateTaskCompleteCondition(self.currentCfg.tbTaskComplete, tb)
    end
    ChessEditor:Snapshoot()
end

-- 添加开始事件
function view:OnBtnClickAddEventBegin()
    table.insert(self.currentCfg.tbTaskBegin, {id = "None", tbParam = {}})

    self:FreeAll(self.GroupEventBegin)
    for _, tb in ipairs(self.currentCfg.tbTaskBegin) do 
        local data = self:AllocItem(self.GroupEventBegin)
        data.widget:UpdateEvent(self.currentCfg.tbTaskBegin, tb)
    end
    ChessEditor:Snapshoot()
end

-- 添加成功事件
function view:OnBtnClickAddEventEnd()
    table.insert(self.currentCfg.tbTaskEnd, {id = "None", tbParam = {}})

    self:FreeAll(self.GroupEventEnd)
    for _, tb in ipairs(self.currentCfg.tbTaskEnd) do 
        local data = self:AllocItem(self.GroupEventEnd)
        data.widget:UpdateEvent(self.currentCfg.tbTaskEnd, tb)
    end
    ChessEditor:Snapshoot()
end

-- 添加失败事件
function view:OnBtnClickAddEventFail()
    table.insert(self.currentCfg.tbTaskFail, {id = "None", tbParam = {}})

    self:FreeAll(self.GroupEventFail)
    for _, tb in ipairs(self.currentCfg.tbTaskFail) do 
        local data = self:AllocItem(self.GroupEventFail)
        data.widget:UpdateEvent(self.currentCfg.tbTaskFail, tb)
    end
    ChessEditor:Snapshoot()
end

function view:OnBtnClickEditorTaskArg()
    local cfg = self.currentCfg
    local tbParam = {
        title = "任务参数配置",
        tbArg = {
            {id = "name", name = "任务名", type = ChessTask.InputTypeText, value = cfg.tbArg.name},
            {id = "main", name = "是否主线", type = ChessTask.InputTypeCheckBox, value = cfg.tbArg.main},
            {id = "trace", name = "是否追踪", type = ChessTask.InputTypeCheckBox, value = cfg.tbArg.trace},
            {id = "time", name = "时间限制", type = ChessTask.InputTypeText, value = cfg.tbArg.time},
            {id = "rewardId", name = "奖励id", type = ChessTask.InputTypeRewardId, value = cfg.tbArg.rewardId},
        },
        okHandler = function(tbArg) 
            for _, tb in ipairs(tbArg) do 
                cfg.tbArg[tb.id] = tb.value
            end
            cfg.tbArg["time"] = tonumber(cfg.tbArg["time"]) or 0
            self:UpdateTaskArgDesc()

            for _, tb in pairs(self.tbTasks) do
                if tb.refresh then 
                    tb.refresh(tb) 
                end
            end
            ChessEditor:Snapshoot()
        end
    }
    self.uw_chess_task_setting:OnOpen(tbParam)
    ChessEditor:Snapshoot()
end

function view:OnBtnClickEditorTaskContent()
    local cfg = self.currentCfg
    local tbParam = {
        title = "任务内容配置",
        tbArg = {
            {id = "desc", name = "任务描述", type = ChessTask.InputTypeText, value = cfg.tbContent.desc},
        },
        okHandler = function(tbArg) 
            for _, tb in ipairs(tbArg) do 
                cfg.tbContent[tb.id] = tb.value
            end
            self:UpdateTaskContentDesc()

            for _, tb in pairs(self.tbTasks) do
                if tb.refresh then 
                    tb.refresh(tb) 
                end
            end
            ChessEditor:Snapshoot()
        end
    }
    self.uw_chess_task_setting:OnOpen(tbParam)
    ChessEditor:Snapshoot()
end

function view:ShowPanelByType(type)
    if type == "list" then 
        WidgetUtils.SelfHitTestInvisible(self.PanelTaskList)
        WidgetUtils.Collapsed(self.PanelTasVar)
        self.BtnTaskList:SetBackgroundColor(ColorGreen)
        self.BtnTaskVar:SetBackgroundColor(ColorNormal)
        if self.currentCfg then 
            self:RefreshTaskContent()
        end
    elseif type == "var" then
        WidgetUtils.Collapsed(self.PanelTaskList)
        WidgetUtils.SelfHitTestInvisible(self.PanelTasVar)
        self.BtnTaskList:SetBackgroundColor(ColorNormal)
        self.BtnTaskVar:SetBackgroundColor(ColorGreen)
        self.uw_chess_task_var_def:Refresh()
    end

    if type ~= ChessConfigHandler:GetTempUICfg().taskPanelType then 
        ChessConfigHandler:GetTempUICfg().taskPanelType = type
        ChessEditor:Snapshoot()
    end
end


---------------------------------------------------------------------
--- update
---------------------------------------------------------------------
--- 更新任务参数描述
function view:UpdateTaskArgDesc()
    local cfg = self.currentCfg.tbArg
    local tbStr = {}
    table.insert(tbStr, string.format("%s", Text(cfg.name) or ""))
    table.insert(tbStr, cfg.main and "主线" or "支线")
    table.insert(tbStr, cfg.trace and "追踪" or "不追踪")
    table.insert(tbStr, (cfg.time and cfg.time > 0) and string.format("时间限制%d秒", cfg.time) or "无时间限制")
    table.insert(tbStr, (cfg.rewardId and #cfg.rewardId > 0) and string.format("奖励Id:%d", cfg.rewardId[1]) or "无奖励")
    self.TxtTaskArg:SetText(table.concat(tbStr, ", "))
end

--- 更新任务内容描述
function view:UpdateTaskContentDesc()
    -- 推动箱子到指定位置: {taskVar=1}/{taskVar=1,max}
    local cfg = self.currentCfg.tbContent
    local value = ChessTools:GetTaskContentDesc(ChessEditor.CurrentMapId, cfg.desc)
    self.TxtContent:SetText(value)
end

---------------------------------------------------------------------
--- pool
---------------------------------------------------------------------
function view:AllocItem(root)
    local pool = self.tbPool[root] or {}
    self.tbPool[root] = pool;

    for _, tbData in ipairs(pool) do 
        if tbData.isHidden then 
            WidgetUtils.Visible(tbData.widget)
            tbData.isHidden = false;
            return tbData
        end
    end

    local tbData = {}
    local widget = LoadWidget("/Game/UI/UMG/Chess/2DMap/Task/uw_chess_item_task_detail.uw_chess_item_task_detail_C")
    widget.parent = self
    root:AddChild(widget)
    tbData.widget = widget
    table.insert(pool, tbData)
    return tbData;
end

function view:FreeAll(root)
    if root then 
        local pool = self.tbPool[root] or {}
        for _, tbData in ipairs(pool) do 
            tbData.isHidden = true
            WidgetUtils.Collapsed(tbData.widget)
        end
    else 
        for _, pool in pairs(self.tbPool) do 
            for _, tbData in ipairs(pool) do 
                tbData.isHidden = true
                WidgetUtils.Collapsed(tbData.widget)
            end
        end
    end
end

---------------------------------------------------------------------
return view
---------------------------------------------------------------------