-- ========================================================
-- @File    : DisableSpawnInfiniteEvent.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

---@class DisableSpawnInfiniteEvent : GameTaskEvent
local DisableSpawnInfiniteEvent = Class()

function DisableSpawnInfiniteEvent:OnTrigger()
    for i = 1,self.TagNames:Length() do
        MonsterSpawnStatistics.StopInfiniteSpawn(self.TagNames:Get(i))
    end
end

return DisableSpawnInfiniteEvent