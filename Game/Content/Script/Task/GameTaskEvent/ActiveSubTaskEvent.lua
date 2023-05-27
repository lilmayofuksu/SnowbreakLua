-- ========================================================
-- @File    : ActiveSubTaskEvent.lua
-- @Brief   : 激活子任务
-- @Author  :
-- @Date    :
-- ========================================================
---@class ActiveSubTaskEvent : GameTaskEvent
local ActiveSubTaskEvent = Class()

function ActiveSubTaskEvent:OnTrigger()
    local GameTaskAsset = self:GetGameTaskAsset()
    if not GameTaskAsset then
        return false
    end
    local GameTaskActor = GameTaskAsset:GetTaskActor()
    if not GameTaskActor then
        return false
    end
    GameTaskAsset:StartSubRootNode(self.SubTaskName, self.Loop)
    return true
end

return ActiveSubTaskEvent
