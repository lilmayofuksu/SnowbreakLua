-- ========================================================
-- @File    : BulletScreen_620303.lua
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
    local Yaw = self.DefaultRotation.Yaw
    Yaw = Yaw + UE4.UKismetMathLibrary.Lerp(-180, 180, 1.0 * self.GenerateCount/self.BulletNum)
    local Rot = UE4.FRotator(0, Yaw, 0)

    self.GenerateLocation = UE4.UKismetMathLibrary.GetForwardVector(Rot) * 1500.0 + self.DefaultLocation
    local Start = self.DefaultLocation
    local End = self.DefaultLocation - UE4.FVector(0, 0, 1000)
    local OutHit = self:Trance(Start, End);
    if OutHit.bBlockingHit then
        local Impact = UE4.FVector(0, 0, 15)
        Impact.X = Impact.X + OutHit.ImpactPoint.X
        Impact.Y = Impact.Y + OutHit.ImpactPoint.X
        Impact.Z = Impact.Z + OutHit.ImpactPoint.Z
        self.GenerateRotation = UE4.UKismetMathLibrary.FindLookAtRotation(self.GenerateLocation, Impact)
    else
        local Impact = UE4.FVector(0, 0, 50) + Start    
        self.GenerateRotation = UE4.UKismetMathLibrary.FindLookAtRotation(self.GenerateLocation, Impact)
    end
end

return ScreenEditor
