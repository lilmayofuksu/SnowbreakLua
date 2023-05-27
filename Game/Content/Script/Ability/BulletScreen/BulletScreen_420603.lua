-- ========================================================
-- @File    : BulletScreen_420603.lua
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
    self.GenerateRotation.Yaw = self.GenerateRotation.Yaw + UE4.UKismetMathLibrary.Lerp(-45, 45, 1.0 * self.GenerateCount/self.BulletNum)
    self.GenerateLocation = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation) * 30 + self.DefaultLocation
end

return ScreenEditor
