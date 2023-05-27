-- ========================================================
-- @File    : PerformanceManager.lua
-- @Brief   : 优化AI性能
-- @Author  :
-- @Date    :
-- ========================================================

local PerformanceManager = Class()

function PerformanceManager:RegisterCharacterSpawn()
    self.Handle = EventSystem.On(
        Event.CharacterSpawned,
        function(InCharacter)
            if IsAI(InCharacter) then
                self:UpdateMonsterState(InCharacter)
            end
        end,
        false
    )
end

function PerformanceManager:ReceiveEndPlay()
    EventSystem.Remove(self.Handle)
end

return PerformanceManager
