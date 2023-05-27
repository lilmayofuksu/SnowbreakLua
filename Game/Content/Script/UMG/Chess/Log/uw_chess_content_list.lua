
local view = Class("UMG.SubWidget")


function view:Construct()
    self.tbPool = {}        -- pool
end

--- 更新所有主线任务
function view:UpdateTaskMain()
    self.TxtLevelTarget:SetText(Text("ui.TxtChessLogTxt1"))
    
    local tbList = {}
    local AllMainTask = ChessConfigHandler:GetAllMainTask()
    for _, tbData in ipairs(AllMainTask) do
        if (ChessData:GetMapTaskIsComplete(tbData.tbArg.id)) then
            table.insert(tbList, tbData)
        else
            table.insert(tbList, 1, tbData)
            break
        end
    end
    self:Update(tbList)
end

--- 更新所有子线任务
function view:UpdateTaskSub()
    self.TxtLevelTarget:SetText(Text("ui.TxtChessLogTxt2"))

    local tbList = ChessConfigHandler:GetAllSubTask()
    local tbCurTaskList = ChessTask:GetCurrentTasks()
    for _, tbTask in pairs(tbList) do
        for _, tbCurTask in pairs(tbCurTaskList) do
            if type(tbTask) == "table" and tbCurTask.cfg.tbArg.id == tbTask.tbArg.id then
                tbTask.bCurTask = true
                break
            end
        end
    end
    self:Update(tbList)
end


function view:Update(tbList)
    self:FreeAll()

    if #tbList == 0 then 
        WidgetUtils.Collapsed(self.Content)
        WidgetUtils.SelfHitTestInvisible(self.TxtIntro)
        return
    end 

    WidgetUtils.SelfHitTestInvisible(self.Content)
    WidgetUtils.Collapsed(self.TxtIntro)

    for i, tbTask in ipairs(tbList) do 
        local item = self:AllocItem()
        item.widget:SetData(tbTask)
    end
end

---------------------------------------------------------------------
--- pool
---------------------------------------------------------------------
function view:AllocItem()
    for _, tbData in ipairs(self.tbPool) do 
        if tbData.isHidden then 
            WidgetUtils.SelfHitTestInvisible(tbData.widget)
            tbData.isHidden = false;
            return tbData
        end
    end

    local tbData = {}
    local widget = LoadWidget("/Game/UI/UMG/Chess/Log/uw_chess_log_item.uw_chess_log_item_C")
    widget.parent = self
    tbData.widget = widget
    self.Content:AddChild(widget)
    table.insert(self.tbPool, tbData)
    return tbData;
end

function view:FreeAll()
    for _, tbData in ipairs(self.tbPool) do 
        tbData.isHidden = true
        WidgetUtils.Collapsed(tbData.widget)
    end
end

------------------------------------------------------------
return view
------------------------------------------------------------