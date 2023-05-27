-- ========================================================
-- @File    : BulletScreen_401603.lua
-- @Brief   : 弹幕发射器
-- @Author  : 
-- @Date    : 
-- ========================================================

---@class ABulletScreenEditor
local ScreenEditor = Class()
function ScreenEditor.RandomFloat(m, n)
    return m + (n-m) * math.random()
end
function ScreenEditor:OnCalcBulletLocAndRot()
    self.GenerateRotation = self.DefaultRotation
    local loc = self.DefaultLocation + self.TargetUpVector*1000

    self.GenerateLocation01 = loc + self.TargetForwardVector * (self.GenerateCount + 1) * 100 
    self.GenerateLocation02 = loc + self.TargetForwardVector * (self.GenerateCount + 1) * (-100)
    self.GenerateLocation03 = loc + self.TargetRightVector * (self.GenerateCount + 1) * 100 
    self.GenerateLocation04 = loc + self.TargetRightVector * (self.GenerateCount + 1) * (-100)
    -- self.GenerateLocation01 = self.DefaultLocation + self.TargetForwardVector * (self.GenerateCount + 1) * 100 + self.TargetUpVector*1000
    -- self.GenerateLocation02 = self.DefaultLocation + self.TargetForwardVector * (self.GenerateCount + 1) * (-100) + self.TargetUpVector*1000
    -- self.GenerateLocation03 = self.DefaultLocation + self.TargetRightVector * (self.GenerateCount + 1) * 100 + self.TargetUpVector*1000
    -- self.GenerateLocation04 = self.DefaultLocation + self.TargetRightVector * (self.GenerateCount + 1) * (-100) + self.TargetUpVector*1000

end

return ScreenEditor
