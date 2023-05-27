-- ========================================================
-- @File    : uw_fight_level_task.lua
-- @Brief   : 战斗界面 任务面板
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_level_task = Class("UMG.SubWidget")

local LevelTask = uw_fight_level_task

---绑定代理
function LevelTask:InitFlowList(InFlow,InGameTask)
    if not self.Factory then
        self.Factory = Model.Use(self)
    end
    self.NewItem = self.Factory:Create({Flow = InFlow,GameTask = InGameTask})
    self:DoClearListItems(self.TaskList)
    self.TaskList:AddItem(self.NewItem)
end

return LevelTask
