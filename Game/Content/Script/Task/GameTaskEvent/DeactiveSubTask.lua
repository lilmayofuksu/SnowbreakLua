-- ========================================================
-- @File    : DeactiveSubTask.lua
-- @Brief   : 终止子任务
-- @Author  :
-- @Date    :
-- ========================================================
---@class DeactiveSubTask : GameTaskEvent
local DeactiveSubTask = Class()

function DeactiveSubTask:OnTrigger()
    local GameTaskAsset = self:GetGameTaskAsset()
    if not GameTaskAsset then
        return false
    end
    local GameTaskActor = GameTaskAsset:GetTaskActor()
    if not GameTaskActor then
        return false
    end
    GameTaskAsset:EndSubRootNode(self.SubTaskName)
    return true
end

return DeactiveSubTask
