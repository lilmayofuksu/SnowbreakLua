-- ========================================================
-- @File    : TransportMoveExecute.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

---@class TransportMoveExecute : GameTask_Execute
local TransportMoveExecute = Class()

function TransportMoveExecute:OnActive()
    self:FindTransporter()
    for i=1,self.Targets:Length() do
        if self.Time > 0 then
            self.Targets:Get(i):DoActive(self.Time, self.Speed, self.Loop, self.KeepForward, self.Unlimited, self.RunEndOpenRight, self.RunEndOpenLeft)
        end
    end
    self.Targets:Clear()
    self:Finish()
end

function TransportMoveExecute:OnEnd()
    
end

return TransportMoveExecute
