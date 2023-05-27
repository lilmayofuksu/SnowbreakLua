-- ========================================================
-- @File    : BulletScreen_620408.lua
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
    local Pitch = self.DefaultRotation.Pitch - 50 - self.SCount * self.Angle
    local Yaw = self.DefaultRotation.Yaw + 185 - self.HCount * self.Angle
    self.GenerateRotation = UE4.FRotator(Pitch, Yaw, 0)

    self.GenerateLocation = UE4.UKismetMathLibrary.GetForwardVector(self.GenerateRotation) * 200 + self.DefaultLocation

end

function ScreenEditor:CalcAlpha()
    local Value = math.sqrt(self.HCount * self.HCount + self.SCount * self.SCount)
    local Max = math.sqrt(self.HNum * self.HNum + self.SNum * self.SNum)
    Value = UE4.UKismetMathLibrary.NormalizeToRange(Value, 0, Max)
    self.Alpha = UE4.UKismetMathLibrary.FClamp(Value, 0, 1)
end

return ScreenEditor
