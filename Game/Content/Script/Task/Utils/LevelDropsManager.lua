-- ========================================================
-- @File    : LevelDropsManager.lua
-- @Brief   : 掉落物管理器
-- @Author  : cms
-- @Date    : 21.4.6
-- ========================================================

LevelDropsManager = LevelDropsManager or {}

function LevelDropsManager.AllocateDrops(LevelDropManager)
    local DropInfos = me:GetStrAttribute(21, Launch.GetLevelID())
    local allTable = json.decode(DropInfos) or {}
    for i,DropTable in ipairs(allTable) do
        for _, DropInfo in pairs(DropTable[2] or {}) do
            local GDPL = string.format("%s-%s-%s-%s", DropInfo[1][1], DropInfo[1][2], DropInfo[1][3], DropInfo[1][4])
            LevelDropManager:AllocateDrop(GDPL,DropInfo[2],DropInfo[3])
        end
    end
end
