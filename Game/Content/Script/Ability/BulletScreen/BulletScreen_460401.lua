-- ========================================================
-- @File    : BulletScreen_460401.lua
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
    local ActorLoc = self:GetTargetLocation()
    local Rot = UE4.UKismetMathLibrary.FindLookAtRotation(self.DefaultLocation, ActorLoc)
    if self.GenerateCount < self.BulletNum/2 then
        Rot.Pitch = Rot.Pitch + UE4.UKismetMathLibrary.Lerp(-1 * self.DiffusionAngle, self.DiffusionAngle, self.GenerateCount/(self.BulletNum/2))
        self.GenerateRotation = Rot        
        self.GenerateLocation = self.DefaultLocation + UE4.UKismetMathLibrary.GetForwardVector(Rot) * self.BulletForwardLocationCurve:GetFloatValue(self.GenerateCount/(self.BulletNum/2))
    else
        local lerp = (self.GenerateCount - self.BulletNum/2) / (self.BulletNum/2)
        Rot.Yaw = Rot.Yaw + UE4.UKismetMathLibrary.Lerp(-1 * self.DiffusionAngle, self.DiffusionAngle, lerp)
        self.GenerateRotation = Rot        
        self.GenerateLocation = self.DefaultLocation + UE4.UKismetMathLibrary.GetForwardVector(Rot) * self.BulletForwardLocationCurve:GetFloatValue(lerp)    
    end
end

return ScreenEditor
