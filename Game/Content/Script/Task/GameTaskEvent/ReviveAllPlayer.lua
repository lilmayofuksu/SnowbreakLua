-- ========================================================
-- @File    : ReviveAllPlayer.lua
-- @Brief   : 复活所有玩家
-- @Author  :
-- @Date    :
-- ========================================================
---@class ReviveAllPlayer : GameTaskEvent
local ReviveAllPlayer = Class()

function ReviveAllPlayer:OnTrigger()
    local Revives = UE4.UGameplayStatics.GetAllActorsOfClass(self, UE4.AReviveHelper)
    for i = 1, Revives:Length() do
        Revives:Get(i):ReviveImmediately()
    end
end

return ReviveAllPlayer
