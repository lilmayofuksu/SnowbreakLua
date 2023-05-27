-- ========================================================
-- @File    : BulletScreen_600309.lua
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
    local Rot = self.DefaultRotation
    local Yaw = Rot.Yaw + UE4.UKismetMathLibrary.Lerp(-180, 180, 1.0 * self.GenerateCount/self.BulletNum)
    self.Scene01:K2_SetWorldRotation(UE4.FRotator(Rot.Pitch, Yaw, Rot.Roll))
    self.GenerateRotation = self.Scene:K2_GetComponentRotation()
    self.GenerateLocation = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation) * 10 + self.DefaultLocation
end

return ScreenEditor
