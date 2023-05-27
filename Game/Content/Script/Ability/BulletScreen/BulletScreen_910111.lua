-- ========================================================
-- @File    : BulletScreen_910111.lua
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
    if self.CircleCount < self.MaxBulletsNumPerCircle then
        self.CurrentBulletsNumPerCircle = self.CircleCount + 1
    else
        if self.CircleNum >= self.MaxBulletsNumPerCircle * 2 and (self.CircleNum-self.CircleCount) < self.MaxBulletsNumPerCircle then
            self.CurrentBulletsNumPerCircle = self.CircleNum - self.CircleCount
        else
            self.CurrentBulletsNumPerCircle = self.MaxBulletsNumPerCircle
        end
    end
    self.CircleLerpAlpha = UE4.UKismetMathLibrary.FClamp(UE4.UKismetMathLibrary.NormalizeToRange(self.CurrentBulletsNumPerCircle, 1.0, self.MaxBulletsNumPerCircle), 0, 1)
    local Val = self.GenerateCount * (360/self.CurrentBulletsNumPerCircle)
    local Loc = self.Scene01:GetUpVector() * UE4.UKismetMathLibrary.DegCos(Val) + self.Scene01:GetRightVector() * UE4.UKismetMathLibrary.DegSin(Val)
    local Rot = UE4.UKismetMathLibrary.FindLookAtRotation(UE4.FVector(0, 0, 0), Loc)
    self.GenerateRotation = Rot
    self.GenerateLocation = self.Scene01:K2_GetComponentLocation()
    self.GenerateLocation.Z = self.GenerateLocation.Z + 250
end



return ScreenEditor
