-- ========================================================
-- @File    : BulletScreen_600202.lua
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
    local Count = self.GenerateCount
    local defLoc = self.DefaultLocation
    local targetForwardLoc = self.TargetForwardVector
    local targetRightLoc = self.TargetRightVector
    local targetUpLoc = self.TargetUpVector
    self.GenerateLocation01 = defLoc + targetForwardLoc * (Count+1)*350 + targetUpLoc*1000
    self.GenerateLocation02 = defLoc - targetForwardLoc * (Count+1)*350 + targetUpLoc*1000
    self.GenerateLocation03 = defLoc + targetRightLoc * (Count+1)*350 + targetUpLoc*1000
    self.GenerateLocation04 = defLoc - targetRightLoc * (Count+1)*350 + targetUpLoc*1000
    self.GenerateLocation05 = defLoc + (targetForwardLoc+targetRightLoc) * (Count+1)*350 + targetUpLoc*1000
    self.GenerateLocation06 = defLoc - (targetForwardLoc+targetRightLoc) * (Count+1)*350 + targetUpLoc*1000
    self.GenerateLocation07 = defLoc + (targetForwardLoc-targetRightLoc) * (Count+1)*350 + targetUpLoc*1000
    self.GenerateLocation08 = defLoc - (targetForwardLoc-targetRightLoc) * (Count+1)*350 + targetUpLoc*1000
end

return ScreenEditor
