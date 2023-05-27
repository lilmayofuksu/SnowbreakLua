-- ========================================================
-- @File    : BulletScreen_410106.lua
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
    local Rot = self:K2_GetActorRotation()
    local Option = (self.CircleCount % 2) == 0 and -3.75 or 0
    Rot.Yaw = Rot.Yaw + self.GenerateCount * (360 / self.CircleBulletNum) + Option
    self.GenerateRotation = Rot
    
    local Loc = UE4.UKismetMathLibrary.GetForwardVector(Rot) * self.CircleCount * 100 + self.DefaultLocation
    Loc = Loc + UE4.UKismetMathLibrary.GetUpVector(Rot) * (self.CircleCount % 3 ) * 30 + UE4.FVector(0, 0, 100)
    self.GenerateLocation = Loc
end

return ScreenEditor
