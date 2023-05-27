-- ========================================================
-- @File    : BulletScreen_101102.lua
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
    self.GenerateLocation01 = self:K2_GetActorLocation()
    self.GenerateRotation01 = self:K2_GetActorRotation()

    self.GenerateRotation01.Pitch = self.GenerateRotation01.Pitch + 42
    local Yaw = self.GenerateRotation01.Yaw + self.TotalAngle/ (-2 )
    Yaw = Yaw + self.BulletIndex * self.TotalAngle / (self.BulletNum - 1)
    local rand = self.TotalAngle / (self.BulletNum * 2)
    Yaw = Yaw + self.RandomFloat(-0.5*rand, 0.5*rand)
    self.GenerateRotation01.Yaw = Yaw
    
end

return ScreenEditor
