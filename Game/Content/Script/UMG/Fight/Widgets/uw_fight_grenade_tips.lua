-- ========================================================
-- @File    : uw_fight_grenade_tips.lua
-- @Brief   : 预警通知
-- @Author  :
-- @Date    :
-- ========================================================

---@class uw_fight_grenade_tips :ULuaWidget
local uw_fight_grenade_tips = Class("UMG.SubWidget")

uw_fight_grenade_tips.bStartWarning = false;
uw_fight_grenade_tips.nTotalTime = 0
uw_fight_grenade_tips.nElapsedTime = 0
function uw_fight_grenade_tips:Construct()

end
function uw_fight_grenade_tips:OnDestruct()
    EventSystem.Remove(self.HitHanddel)
end


function uw_fight_grenade_tips:ReceiveWarning(bStart, InTotalTime, InElapsedTime)
    self.nTotalTime = InTotalTime
    self.nElapsedTime = InElapsedTime
    self.bStartWarning = bStart
    if bStart then
        self:Play()
    else
        self:Stop()
    end
end


function uw_fight_grenade_tips:Tick(MyGeometry, InDeltaTime)
    if not self.bStartWarning then return end
    if self.nTotalTime > 0 then
        self.nElapsedTime = math.min(self.nTotalTime, self.nElapsedTime + InDeltaTime);
        local nPre = self.nElapsedTime/self.nTotalTime
        self:SetPlaySpeed(nPre)
    end

end

return uw_fight_grenade_tips
