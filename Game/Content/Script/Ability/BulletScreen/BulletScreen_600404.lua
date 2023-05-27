-- ========================================================
-- @File    : BulletScreen_600404.lua
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
    local UpVector = self.Scene:GetUpVector()
    local RightVector = self.Scene:GetRightVector()
    local tmp = (self.GenerateCount + 3) * (self.SingleSectorAngle + self.RandomFloat(-10, 10)) / self.BulletNumPerSector
    local CosD = UE4.UKismetMathLibrary.DegCos(tmp)
    local SinD = UE4.UKismetMathLibrary.DegSin(tmp)
    self.GenerateRotation01 = UE4.UKismetMathLibrary.FindLookAtRotation(ZeroVector, UpVector * CosD + RightVector * SinD)
    self.GenerateRotation02 = UE4.UKismetMathLibrary.FindLookAtRotation(ZeroVector, UpVector * CosD - RightVector * SinD)
    local V50 = UE4.FVector(0, 0, 50.0)
    self.GenerateLocation01 = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation01) * 120.0 + self.DefaultLocation + V50
    self.GenerateLocation02 = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation02) * 120.0 + self.DefaultLocation + V50
end

return ScreenEditor
