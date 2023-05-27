-- ========================================================
-- @File    : BulletScreen_620509.lua
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
    local Pitch = self.DefaultRotation.Pitch
    Pitch = Pitch + 90 + self.CircleCount * (self.SingleSectorAngle/(self.CircleNum-1))
    self.GenerateRotation = UE4.FRotator(Pitch, 0, 0)
    local For = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation)
    self.GenerateLocation = For  * 100 + self.DefaultLocation
    self.GenerateLocation.Z = self.GenerateLocation.Z + 100
end



return ScreenEditor
