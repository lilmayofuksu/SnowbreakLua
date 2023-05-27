-- ========================================================
-- @File    : uw_task_target_progress.lua
-- @Brief   : 占领进度显示
-- @Author  :
-- @Date    :
-- ========================================================

local uw_task_target_progress = Class("UMG.SubWidget")

function uw_task_target_progress:Init(InOuter)
    if InOuter then
        EventSystem.OnTarget(
            InOuter,
            InOuter.OnDataChange,
            function(InTarget, InValue)
                self.Progress:SetPercent(InValue)
            end
        )
    end
end

return uw_task_target_progress
