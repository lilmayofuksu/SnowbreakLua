-- ========================================================
-- @File    : CheckRoundStartExecute.lua
-- @Brief   : 检查回合是否能够开始
-- @Author  :
-- @Date    :
-- ========================================================

---@class CheckRoundStartExecute : TaskItem
local CheckRoundStartExecute = Class()

function CheckRoundStartExecute:OnActive()
    if TargetShootLogic.GetCanEnterRound() then
        self:Finish()
    end
end

function CheckRoundStartExecute:OnActive_Client()
end

function CheckRoundStartExecute:OnFinish()
end

function CheckRoundStartExecute:OnTick()
    if TargetShootLogic.GetCanEnterRound() then
        self:Finish()
    end
end

return CheckRoundStartExecute
