-- ========================================================
-- @File    : BulletScreen_610401.lua
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
    local Pitch = self.DefaultRotation.Pitch - 25 + self.SCount * self.Angle
    local Yaw = self.DefaultRotation.Yaw + 75 - self.HCount * self.Angle
    self.GenerateRotation = UE4.FRotator(Pitch, Yaw, 0)
    self.GenerateLocation = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation) * 300 + self.DefaultLocation
end

return ScreenEditor
