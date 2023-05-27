-- ========================================================
-- @File    : BulletScreen_101103.lua
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
    local ActorLocation = self:K2_GetActorLocation()

    ActorLocation.X = self.RandomFloat(ActorLocation.X - self.RandomRange, ActorLocation.X + self.RandomRange)
    ActorLocation.Y = self.RandomFloat(ActorLocation.Y - self.RandomRange, ActorLocation.Y + self.RandomRange)
    ActorLocation.Z = self.RandomFloat(ActorLocation.Z, ActorLocation.Z + self.RandomRange)


    self.GenerateLocation01 = ActorLocation
    
end

return ScreenEditor
