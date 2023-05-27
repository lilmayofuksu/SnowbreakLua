-- ========================================================
-- @File    : PreTaskItemExecute.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

---@class  TaskTrigger: GameTask_Execute
local TaskTrigger = Class()

---是否触发
TaskTrigger.bTrigger = false

---激活的触发区域
TaskTrigger.Triggers = nil


function TaskTrigger:OnActive()
    self.bTrigger = false
    self.Triggers = self:GetTriggers()
    for i = 1, self.Triggers:Length() do
        self.Triggers:Get(i):BindTaskItem(self, self.bCheckPlayer, self.bCheckMonster, self.bCheckFrindlySummon)
    end
    self:SetExecuteDescription(self:GetUIDescription())
end

function TaskTrigger:OnActive_Client()
    self:SetExecuteDescription(self:GetUIDescription())
end

function TaskTrigger:OnCountDown_Client()
    UI.Call("Fight", "UpdateTaskCountDown", self:GetCountDown(), self)
end

function TaskTrigger:BeginOverlap()
    self.bTrigger = true
    if self:Check() then
        self:Finish()
    end
end

function TaskTrigger:EndOverlap()
    self.bTrigger = false
end

function TaskTrigger:Check()
    return self:GetNodeState() == UE4.ENodeState.InProgress
end

function TaskTrigger:OnEnd_Client()
    UI.Call("Fight", "HiddenTaskCountDown", self)
end

function TaskTrigger:OnEnd()
    if self.Triggers then
        for i = 1, self.Triggers:Length() do
            self.Triggers:Get(i):Clear()
        end
    end
    self.Triggers = nil
end
 
function TaskTrigger:OnTick()

end

return TaskTrigger