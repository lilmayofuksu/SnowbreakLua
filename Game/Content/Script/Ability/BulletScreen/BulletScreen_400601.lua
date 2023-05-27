-- ========================================================
-- @File    : BulletScreen_400601.lua
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
    self.GenerateLocation = self.DefaultLocation
    self.GenerateRotation = self.DefaultRotation
    local PawnLoc = self:GetTargetLocation()
    local Rot = UE4.UKismetMathLibrary.FindLookAtRotation(self.GenerateLocation, PawnLoc)    
    local Pitch = 0;
    if self.GenerateCount > self.BulletNum/2 then
        local diffAngle = math.abs(self.DiffusionAngle)
        Pitch = self.RandomFloat(-1 * diffAngle, diffAngle)
    else
        local diffAngle = math.abs(self.DiffusionAngle / 2)
        Pitch = self.RandomFloat(-1 * diffAngle, diffAngle)
    end

    local Yaw = 0;
    if self.GenerateCount > self.BulletNum/2 then
        local diffAngle = math.abs(self.DiffusionAngle)
        Yaw = self.RandomFloat(-1 * diffAngle, diffAngle)
    else
        local diffAngle = math.abs(self.DiffusionAngle / 2)
        Yaw = self.RandomFloat(-1 * diffAngle, diffAngle)
    end

    Rot.Pitch = Rot.Pitch + Pitch
    Rot.Yaw = Rot.Yaw + Yaw
    self.GenerateRotation = Rot
end

return ScreenEditor
