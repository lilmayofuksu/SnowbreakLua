-- ========================================================
-- @File    : BulletScreen_410602.lua
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
    local Yaw = self.DefaultRotation.Yaw
    Yaw = Yaw + UE4.UKismetMathLibrary.Lerp(-180, 180, 1.0 * self.GenerateCount/self.BulletNum)
    self.GenerateRotation = self.DefaultRotation
    self.GenerateRotation.Yaw = Yaw

    self.GenerateLocation = UE4.UKismetMathLibrary.GetForwardVector(Rot) * 30 + self.DefaultLocation
end

return ScreenEditor
