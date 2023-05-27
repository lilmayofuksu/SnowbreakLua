-- ========================================================
-- @File    : BulletScreen_910108.lua
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
    local Val = (self.GenerateCount + 3) * (self.SingleSectorAngle/self.BulletNumPerSector)
    local CosD = UE4.UKismetMathLibrary.DegCos(Val)
    local SinD = UE4.UKismetMathLibrary.DegSin(Val)
    local Rot1 = UE4.UKismetMathLibrary.FindLookAtRotation(ZeroVector, UpVector * CosD + RightVector * SinD)
    local Rot2 = UE4.UKismetMathLibrary.FindLookAtRotation(ZeroVector, UpVector * CosD - RightVector * SinD)
    self.GenerateRotation01 = Rot1
    self.GenerateRotation02 = Rot2
    self.GenerateLocation01 = self.DefaultLocation + UE4.FVector(0, 0, 150)
    self.GenerateLocation02 = self.DefaultLocation + UE4.FVector(0, 0, 150)

end



return ScreenEditor
