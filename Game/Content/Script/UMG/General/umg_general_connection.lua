
-- ========================================================
-- @File    : umg_general_connection.lua
-- @Brief   : 连接Mask
-- @Author  :
-- @Date    :
-- ========================================================

local umg_general_connection = Class("UMG.BaseWidget")

function umg_general_connection:DontFocus()
    if Launch.GetType() == LaunchType.TOWER then
        return true
    end
    return false
end

function umg_general_connection:OnOpen()
    self:PlayAnimation(self.AllEnter)
    if GuideLogic.IsGuiding() then
        GuideLogic.SetGuidePaused(true)
    end
end

function umg_general_connection:OnClose()
    if GuideLogic.IsGuiding() then
        GuideLogic.SetGuidePaused(false)
    end
end

return umg_general_connection
