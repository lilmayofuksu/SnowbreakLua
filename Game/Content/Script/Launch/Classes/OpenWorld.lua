-- ========================================================
-- @File    : OpenWorld.lua
-- @Brief   : 开放世界出击逻辑
-- ========================================================
local tbClass = Launch.Class(LaunchType.OPENWORLD)

function tbClass:OnStart()
    print("launch openworld");
    Map.Open(11)
end

return tbClass