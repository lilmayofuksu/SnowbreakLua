-- ========================================================
-- @File    : BulletScreen_460201.lua
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
    if not self.OwnerCharacter then return end
    if not self.OwnerCharacter.Mesh then return end
    local TransSocket01 = self.OwnerCharacter.Mesh:GetSocketTransform("FireSocket01")
    local TransSocket02 = self.OwnerCharacter.Mesh:GetSocketTransform("FireSocket02")
    local RotSocket01 = UE4.FRotator()
    local RotSocket02 = UE4.FRotator()
    local Scale = UE4.FVector()
    UE4.UKismetMathLibrary.BreakTransform(TransSocket01, self.GenerateLocation01, RotSocket01, Scale)
    UE4.UKismetMathLibrary.BreakTransform(TransSocket02, self.GenerateLocation02, RotSocket02, Scale)
    local V1 = UE4.UKismetMathLibrary.Normal(UE4.UKismetMathLibrary.GetUpVector(RotSocket01) + UE4.UKismetMathLibrary.GetRightVector(RotSocket01) * 0.5)
    local V2 = UE4.UKismetMathLibrary.Normal(UE4.UKismetMathLibrary.GetUpVector(RotSocket02) + UE4.UKismetMathLibrary.GetRightVector(RotSocket02) * (-0.5))
    local ZeroVector = UE4.FVector(0, 0, 0)
    self.GenerateRotation01 = UE4.UKismetMathLibrary.FindLookAtRotation(ZeroVector, UE4.UKismetMathLibrary.RandomUnitVectorInConeInDegrees(V1, 30))
    self.GenerateRotation02 = UE4.UKismetMathLibrary.FindLookAtRotation(ZeroVector, UE4.UKismetMathLibrary.RandomUnitVectorInConeInDegrees(V2, 30))
    self.ForwardVelocity01 = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation01)
    self.ForwardVelocity02 = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation02)
end

return ScreenEditor
