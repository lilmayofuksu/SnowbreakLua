-- ========================================================
-- @File    : BulletScreen_910107.lua
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
    local ZeroVector = UE4.FVector(0, 0, 0)
    self.GenerateRotation = self.DefaultRotation
    local Yaw = self.DefaultRotation.Yaw
    Yaw = Yaw + self.BulletCount * self.SingleSectorAngle / self.BulletNumPerSector
    Yaw = Yaw + self.SectorCount * self.EverySectorRotateAngle
    Yaw = Yaw + self.CircleCount * self.EveryCircleRotateAngle
    self.GenerateRotation.Yaw = Yaw
    self.GenerateLocation = self.DefaultLocation + UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation) * 100

end



return ScreenEditor
