-- ========================================================
-- @File    : BulletScreen_630104.lua
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
    local Yaw = self.DefaultRotation.Yaw
    Yaw = Yaw + UE4.UKismetMathLibrary.Lerp(-45.0, 45.0, 1.0 * self.GenerateCount / self.BulletNum)

    self.GenerateRotation.Yaw = Yaw
    local For = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation)
    self.GenerateLocation = For  * 30 + self.DefaultLocation
end



return ScreenEditor
