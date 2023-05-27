-- ========================================================
-- @File    : BulletScreen_630107.lua
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
    local ForwardVector = self.Scene01:GetForwardVector() 
    local RightVector = self.Scene01:GetRightVector() 
    local Dir = ForwardVector * UE4.UKismetMathLibrary.Sqrt(3) + RightVector
    self.GenerateRotation01 = UE4.UKismetMathLibrary.FindLookAtRotation(ZeroVector, Dir)
    self.GenerateLocation01 = self.DefaultLocation + UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation01) * 30
    Dir = ForwardVector * UE4.UKismetMathLibrary.Sqrt(3) - RightVector
    self.GenerateRotation02 = UE4.UKismetMathLibrary.FindLookAtRotation(ZeroVector, Dir)
    self.GenerateLocation02 = self.DefaultLocation + UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation02) * 30
    self.RightVector = UE4.UKismetMathLibrary.GetRightVector(self.GenerateRotation02)
    self.LeftVector = UE4.UKismetMathLibrary.GetRightVector(self.GenerateRotation01) *(-1)
end



return ScreenEditor
