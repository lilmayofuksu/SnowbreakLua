-- ========================================================
-- @File    : uw_chess_item_task_detail.lua
-- @Brief   : 地图任务 - 任务详情条目
-- ========================================================

local view = Class("UMG.SubWidget")
local ColorNormal = UE4.UUMGLibrary.GetSlateColor(0.05, 0.33, 0.39, 1);
local ColorSelected = UE4.UUMGLibrary.GetSlateColor(0, 0.8, 0, 1);

function view:Construct()
    BtnAddEvent(self.BtnEditor, function() self:OnBtnClickEditor() end)
end

--- 更新任务触发条件描述
function view:UpdateCondition(list, conditon)
    self.type = "condition"
    self.tbList = list
    self.cfg = conditon
    self:OnSelected(self.isSelected)
    self:UpdateConditionDesc()
end

--- 更新任务完成条件描述
function view:UpdateTaskCompleteCondition(list, condition)
    self.type = "task_complete_condition"
    self.tbList = list
    self.cfg = condition
    self:OnSelected(self.isSelected)
    self:UpdateTaskCompleteConditionDesc()
end

-- 更新事件描述
function view:UpdateEvent(list, event)
    self.type = "event"
    self.tbList = list
    self.cfg = event
    self:OnSelected(self.isSelected)
    self:UpdateEventDesc()
end

-- 选择
function view:OnSelected(value)
    self.isSelected = value
    if value then 
        self.Background:SetColorAndOpacity(ColorSelected)
    else 
        self.Background:SetColorAndOpacity(ColorNormal)
    end
end

-- 点击编辑按钮
function view:OnBtnClickEditor()
    if self.type == "condition" then 
        local tbParam = {
            title = "任务触发条件编辑",
            cfg = Copy(self.cfg),
            okHandler = function(_cfg)
                self.cfg.id = _cfg.id 
                self.cfg.tbParam = _cfg.tbParam  
                self:UpdateConditionDesc()
                ChessEditor:Snapshoot()
            end
        }
        self.parent.uw_chess_task_condition:OnOpen(tbParam)

    elseif self.type == "task_complete_condition" then 
        local tbParam = {
            title = "任务完成条件编辑",
            cfg = Copy(self.cfg),
            okHandler = function(_cfg) 
                self.cfg.id = _cfg.id 
                self.cfg.tbParam = _cfg.tbParam  
                self:UpdateTaskCompleteConditionDesc()
                ChessEditor:Snapshoot()
            end
        }
        self.parent.uw_chess_task_complete_condition:OnOpen(tbParam)

    elseif self.type == "event" then 
        local tbParam = {
            title = "事件行为编辑",
            cfg = Copy(self.cfg),
            okHandler = function(_cfg) 
                self.cfg.id = _cfg.id 
                self.cfg.tbParam = _cfg.tbParam  
                self:UpdateEventDesc()
                ChessEditor:Snapshoot()
            end
        }
        self.parent.uw_chess_task_action:OnOpen(tbParam)
    else 
        return 
    end
    ChessEditor:Snapshoot()
end

---------------------------------------------------------------------
--- 更新任务触发条件描述
function view:UpdateConditionDesc()
    local class = ChessTaskCondition:FindClassById(self.cfg.id)
    if class then 
        self.TxtContent:SetText(class:GetDesc(self.cfg.tbParam))
    else 
        self.TxtContent:SetText("")
    end
end

--- 更新任务完成条件描述
function view:UpdateTaskCompleteConditionDesc()
    local desc = ChessTaskCompleteCondition:GetDesc(self.cfg)
    self.TxtContent:SetText(desc)
end

--- 更新事件描述
function view:UpdateEventDesc()
    local class = ChessTaskEventAction:FindClassById(self.cfg.id)
    if class then 
        self.TxtContent:SetText(class:GetDesc(self.cfg.tbParam))
    else 
        self.TxtContent:SetText("")
    end
end


---------------------------------------------------------------------
--- 当鼠标按下时
function view:OnMouseButtonDown(MyGeometry, MouseEvent)
    local key = UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent)
    if key == ChessEditor.KeyRightMouseButton then 
        local tbParam = {
            {"克隆", self.Menu_Clone, self},
            {"删除", self.Menu_Delete, self},
            {"上移", self.Menu_MoveUp, self},
            {"下移", self.Menu_MoveDown, self},
        }
        EventSystem.Trigger(Event.NotifyChessShowMenu, tbParam)
        UE4.Timer.Add(0.1, function() 
            self.parent:SetSelectedItem(self)
        end)
        return UE4.UWidgetBlueprintLibrary.Handled()
    end
    return UE4.UWidgetBlueprintLibrary.UnHandled()
end

-- 当鼠标进入时
function view:OnMouseEnter()
    self.parent:SetSelectedItem(self)
end

function view:OnMouseLeave()
    self.parent:SetSelectedItem(nil)
end


function view:Menu_Delete()
    for i, data in ipairs(self.tbList) do 
        if data == self.cfg then 
            table.remove(self.tbList, i)
            break
        end
    end
    self.parent:RefreshTaskContent()
    ChessEditor:Snapshoot()
end

function view:Menu_Clone()
    local newData = Copy(self.cfg)
    for i, data in ipairs(self.tbList) do 
        if data == self.cfg then 
            table.insert(self.tbList, i + 1, newData)
            break
        end
    end
    self.parent:RefreshTaskContent()
    ChessEditor:Snapshoot()
end

function view:Menu_MoveUp()

end

function view:Menu_MoveDown()

end

------------------------------------------------------------
return view
------------------------------------------------------------