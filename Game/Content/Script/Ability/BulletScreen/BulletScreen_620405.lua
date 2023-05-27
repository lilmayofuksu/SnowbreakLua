-- ========================================================
-- @File    : BulletScreen_620405.lua
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
    local Pitch = self.DefaultRotation.Pitch + 90 + self.CircleCount * (self.SingleSectorAngle/(self.CircleNum - 1))
    local Yaw = self.DefaultRotation.Yaw + self.BulletCount * self.EveryCircleRotateAngle / (self.CircleCount*self.SectorNumPerCircle)
    self.GenerateRotation = UE4.FRotator(Pitch, Yaw, 0)
    self.GenerateLocation = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation) * 100 + self.DefaultLocation
    self.GenerateLocation.Z = self.GenerateLocation.Z + 100
end

return ScreenEditor
