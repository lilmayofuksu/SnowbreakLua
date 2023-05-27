-- ========================================================
-- @File    : BulletScreen_910101.lua
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
    self.GenerateRotation = self:K2_GetActorRotation()
    local Op = -3.75
    if self.CircleCount % 2 == 1 then
        Op = 0
    end
    self.GenerateRotation.Yaw = self.GenerateRotation.Yaw + self.GenerateCount * (360/self.CircleBulletNum) + Op
    local For = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation)
    --local Up = UE4.UKismetMathLibrary.GetUpVector(self.GenerateRotation)
    self.GenerateLocation = For * self.CircleCount * 100 + self.DefaultLocation
end



return ScreenEditor
