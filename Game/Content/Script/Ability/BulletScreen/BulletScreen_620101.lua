-- ========================================================
-- @File    : BulletScreen_620101.lua
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
    self.GenerateRotation.Yaw = self.GenerateRotation.Yaw + UE4.UKismetMathLibrary.Lerp(-180, 180, 1.0 * self.GenerateCount/self.BulletNum) + self.CircleCount*7.5
    self.GenerateLocation = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation) * 30 + self.DefaultLocation
    self.GenerateLocation.Z = self.GenerateLocation.Z + self.CircleCount * 25
end

return ScreenEditor
