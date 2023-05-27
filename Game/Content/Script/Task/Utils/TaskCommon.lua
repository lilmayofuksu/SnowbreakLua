-- ========================================================
-- @File    : TaskCommon.lua
-- @Brief   : 任务公共数据
-- @Author  :
-- @Date    :
-- ========================================================

TaskState = {
	Disable=0,
	Progress=1,
	Finish=2,
	Fail=3,
}

---@class TaskCommon
TaskCommon = TaskCommon or {}

TaskCommon.TaskChangeEvent = "CURRENT_NODE_DATA_CHANGE_EVENT"

TaskCommon.TaskActor = nil

TaskCommon.G_CLIENT = function()
    if TaskCommon.TaskActor then
        return not UE4.UKismetSystemLibrary.IsDedicatedServer(TaskCommon.TaskActor)
    end
    return true
end

TaskCommon.G_SERVER = function()
    return not TaskCommon.G_CLIENT
end

TaskCommon.G_AUTHORITY = function()
    if TaskCommon.TaskActor then
        return TaskCommon.TaskActor:HasAuthority()
    end
    return true
end

---任务中存储的事件
TaskCommon.CacheHandle = {}

function TaskCommon.AddHandle(InID)
    if TaskCommon.CacheHandle[InID] then
        return
    end
    table.insert(TaskCommon.CacheHandle, InID)
end

function TaskCommon.ClearHandle()
    for _, v in ipairs(TaskCommon.CacheHandle) do
        EventSystem.Remove(v)
    end
end
---

function TaskCommon.CheckGet(InArray, InIndex)
    if InArray:Length() < InIndex then
        return nil
    end
    return InArray:Get(InIndex)
end

---任务失败
function TaskCommon.TaskFail()
    UI.Open("Defead")
end

---任务结束 成功
function TaskCommon.TaskEnd()
    UI.Open("Success")
end

function TaskCommon.GetTaskExectueStatue(InObj)
    if not InObj then
        return
    end
    local Obj = InObj:Cast(UE4.UTaskItem)
    if Obj then
        if Obj.CurrentState == UE4.ETaskItem_State.Disable then
            return TaskState.Disable
        elseif Obj.CurrentState == UE4.ETaskItem_State.Finish then
            return TaskState.Finish
        elseif Obj.CurrentState == UE4.ETaskItem_State.Progress then
            return TaskState.Progress
        end
        return TaskState.Fail
    end

    local Obj = InObj:Cast(UE4.UGameTaskNode)
    if Obj then
        if Obj:GetNodeState() == UE4.EItemState.Disable then
            return TaskState.Disable
        elseif Obj:GetNodeState() == UE4.EItemState.Finish then
            return TaskState.Finish
        elseif Obj:GetNodeState() == UE4.EItemState.Progress then
            return TaskState.Progress
        end
        return TaskState.Fail
    end
end