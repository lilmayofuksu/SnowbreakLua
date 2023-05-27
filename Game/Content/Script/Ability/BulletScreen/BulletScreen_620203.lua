-- ========================================================
-- @File    : BulletScreen_620203.lua
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
    local ActorLoc = self:K2_GetActorLocation()
    local ActorRot = self:K2_GetActorRotation()
    ActorRot.Pitch = 0
    ActorRot.Yaw = ActorRot.Yaw + self.GenerateCount * (360/self.BulletNum)
    ActorLoc = ActorLoc + UE4.UKismetMathLibrary.GetForwardVector(ActorRot) * (self.RandomFloat(-50, 50) + 300)
    ActorLoc = ActorLoc + UE4.UKismetMathLibrary.GetUpVector(ActorRot) * self.RandomFloat(-35, 35)
    self.SpawnTrans = UE4.UKismetMathLibrary.MakeTransform(ActorLoc, ActorRot, UE4.FVector(1, 1, 1))
end

return ScreenEditor
