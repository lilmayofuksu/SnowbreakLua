-- ========================================================
-- @File    : BulletScreen_600201.lua
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
    self.GenerateLocation01 = self.DefaultLocation + self.TargetForwardVector * (self.GenerateCount+1)*350 + self.TargetUpVector*1000
    self.GenerateLocation02 = self.DefaultLocation - self.TargetForwardVector * (self.GenerateCount+1)*350 + self.TargetUpVector*1000
    self.GenerateLocation03 = self.DefaultLocation + self.TargetRightVector * (self.GenerateCount+1)*350 + self.TargetUpVector*1000
    self.GenerateLocation04 = self.DefaultLocation - self.TargetRightVector * (self.GenerateCount+1)*350 + self.TargetUpVector*1000
end

return ScreenEditor
