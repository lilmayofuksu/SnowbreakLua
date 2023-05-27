-- ========================================================
-- @File    : BulletScreen_910110.lua
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

    local Val = self.GenerateCount * (360/self.BulletsNumPerCircle)
    local Loc = self.Scene01:GetForwardVector() * UE4.UKismetMathLibrary.DegCos(Val) + self.Scene01:GetRightVector() * UE4.UKismetMathLibrary.DegSin(Val)
    local Rot = UE4.UKismetMathLibrary.FindLookAtRotation(UE4.FVector(0, 0, 0), Loc)
    self.GenerateRotation = Rot
    self.GenerateLocation = self.Scene01:K2_GetComponentLocation()
    self.GenerateLocation.Z = self.GenerateLocation.Z - 50
end



return ScreenEditor
