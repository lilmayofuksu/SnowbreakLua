-- ========================================================
-- @File    : BulletScreen_600403.lua
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
    local V100 = UE4.FVector(0, 0, 100)
    self.GenerateLocation01 = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation01) * 50 + self.DefaultLocation + V100
    self.GenerateLocation02 = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation02) * 50 + self.DefaultLocation + V100
end

return ScreenEditor
