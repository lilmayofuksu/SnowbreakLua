-- ========================================================
-- @File    : OnlineLogic.lua
-- @Brief   : 联机关卡处理
-- ========================================================
local tbClass = Launch.Class(LaunchType.ONLINE)
function tbClass:OnEnd()
    Online.SetOnlineState(Online.STATUS_END)
    Online.DoPerformanceLog()

    GoToMainLevel()
end

return tbClass