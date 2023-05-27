-- ========================================================
-- @File    : DefeatExecute.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

---@class DefeatExecute : GameTask_Execute
local DefeatExecute = Class()

function DefeatExecute:OnActive()
	self.DefeatHook = EventSystem.On(
        Event.DefeatFinish,
        function()
            self:Finish()
        end
    )
    self:SetExecuteDescription()
end

function DefeatExecute:OnEnd()
    EventSystem.Remove(self.DefeatHook)
end

return DefeatExecute
