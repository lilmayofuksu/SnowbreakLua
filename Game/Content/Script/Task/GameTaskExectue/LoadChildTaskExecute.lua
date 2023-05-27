-- ========================================================
-- @File    : LoadChildTaskExecute.lua
-- @Brief   : 加载子任务
-- @Author  :
-- @Date    :
-- ========================================================

---@class LoadChildTaskExecute : TaskItem
local LoadChildTaskExecute = Class()

function LoadChildTaskExecute:OnActive()
    local TaskActor = self:GetGameTaskActor()
    TaskActor.AreaId = self.AreaId
    local ChildPath = UE4.UTaskRandomSubsystem.GetAreaSubTask(TaskActor, self.AreaId)
    print('===============>load ',ChildPath.AssetPathName)

    if not ChildPath or TaskActor.OptionTaskPath == ChildPath.AssetPathName then return end
    if TaskActor.ParentTask ~= ChildPath.AssetPathName then
        TaskActor:LoadChildGameTask(ChildPath.AssetPathName, self.InnerID)
    end
end

function LoadChildTaskExecute:OnActive_Client()
    
end

function LoadChildTaskExecute:OnFinish()
    
end

return LoadChildTaskExecute
