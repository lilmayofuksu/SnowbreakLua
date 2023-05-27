-- ========================================================
-- @File    : BulletScreen_410103.lua
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
    local UpVector= self.Scene:GetUpVector()
    local RightVector = self.Scene:GetRightVector()
    local angle = (self.GenerateCount + 3) * self.SingleSectorAngle/self.BulletNumPerSector
    local Cosd = UE4.UKismetMathLibrary.DegCos(angle)
    local Sind = UE4.UKismetMathLibrary.DegSin(angle)
    local UpCosd = UpVector * Cosd
    local RightSind =  RightVector * Sind
    local Zero = UE4.FVector(0, 0, 0)
    self.GenerateRotation01 = UE4.UKismetMathLibrary.FindLookAtRotation(Zero, UpCosd + RightSind)
    self.GenerateRotation02 = UE4.UKismetMathLibrary.FindLookAtRotation(Zero, UpCosd - RightSind)
    self.GenerateLocation01 = self.DefaultLocation + UE4.FVector(0, 0, 100)
    self.GenerateLocation02 = self.GenerateLocation01
end

return ScreenEditor
