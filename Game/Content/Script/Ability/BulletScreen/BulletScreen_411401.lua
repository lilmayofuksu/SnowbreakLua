-- ========================================================
-- @File    : BulletScreen_411401.lua
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
    local ActorLoc = self:GetTargetLocation()
    local Rot = UE4.UKismetMathLibrary.FindLookAtRotation(self.GenerateLocation, ActorLoc)
    local Pitch = Rot.Pitch
    local Yaw = Rot.Yaw
    if self.GenerateCount > self.BulletNum / 2 then
        local AngleAbs = math.abs(self.DiffusionAngle)
        Pitch = Pitch + self.RandomFloat(-1*AngleAbs, AngleAbs)
        Yaw = Yaw + self.RandomFloat(-1*AngleAbs, AngleAbs)
    else
        local AngleAbs = math.abs(self.DiffusionAngle/2)
        Pitch = Pitch + self.RandomFloat(-1*AngleAbs, AngleAbs)
        Yaw = Yaw + self.RandomFloat(-1*AngleAbs, AngleAbs)
    end
    self.GenerateRotation = UE4.FRotator(Pitch,Yaw,Rot.Roll);
end

return ScreenEditor
