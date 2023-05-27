-- ========================================================
-- @File    : BulletScreen_410205.lua
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
    local PawnLoc = self:GetTargetLocation()
    local Rot = UE4.UKismetMathLibrary.FindLookAtRotation(self.DefaultLocation, PawnLoc)
    local Yaw = UE4.UKismetMathLibrary.Lerp(-20, 20, self.GenerateCount/self.BulletNum)
    Rot.Yaw = Rot.Yaw + Yaw
    self.GenerateRotation = Rot
    self.GenerateLocation = self.DefaultLocation + UE4.UKismetMathLibrary.GetForwardVector(Rot) * 30
end

return ScreenEditor
