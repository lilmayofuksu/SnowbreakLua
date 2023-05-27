-- ========================================================
-- @File    : BulletScreen_630106.lua
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
    Yaw = Yaw + UE4.UKismetMathLibrary.Lerp(-75, 75, 1.0 * self.GenerateCount / self.BulletNum)
    if self.CircleCount%2 == 0 then
        Yaw = Yaw - 7.5
    end
    self.GenerateRotation.Yaw = Yaw
    local For = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation)
    self.GenerateLocation = For  * 30 + self.DefaultLocation
end



return ScreenEditor
