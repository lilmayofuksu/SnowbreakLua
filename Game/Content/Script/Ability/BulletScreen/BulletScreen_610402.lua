-- ========================================================
-- @File    : BulletScreen_610402.lua
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
    self.GenerateRotation.Yaw = self.GenerateRotation.Yaw + 80  - self.HCount * self.Angle
    local ForwardDir = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation)
    if self.Count%2 == 1 then
        local Z = self.Curve1:GetFloatValue(self.Time) + self.DefaultLocation.Z
        local Offset = UE4.FVector(self.DefaultLocation.X, self.DefaultLocation.Y, Z)
        self.GenerateLocation = ForwardDir + Offset
        self.EndLocation = ForwardDir*8000 + Offset
        self.Time = self.Time + 0.025
    else
        local Z = self.Curve2:GetFloatValue(self.Time) + self.DefaultLocation.Z
        local Offset = UE4.FVector(self.DefaultLocation.X, self.DefaultLocation.Y, Z)
        self.GenerateLocation = ForwardDir + Offset
        self.EndLocation = ForwardDir*8000 + Offset
        self.Time = self.Time + 0.025
    end
end

return ScreenEditor
