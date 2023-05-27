-- ========================================================
-- @File    : LevelRecord.lua
-- @Brief   : 关卡成绩和阵容记录
-- @Author  :
-- @Date    :
-- ========================================================

LevelRecordLogic = LevelRecordLogic or {}

LevelRecordLogic.GID        = 20    --关卡成绩记录占用GID
--[[
recorddata = {
    levelId = 0
    tbAchievement = {
        teamdata,
        teamdata,
        ...
    }
}
teamdata = {
    lately = 0
    time = 0,
    member1 = {0,0,0,0}
    member2 = {0,0,0,0}
    member3 = {0,0,0,0}
}
]]--

---得到存储的关卡记录信息 没有则返回初始化信息
function LevelRecordLogic.GetRecordData(levelId)
    return json.decode(me:GetStrAttribute(LevelRecordLogic.GID, levelId)) or LevelRecordLogic.InitRecordData(levelId)
end

---得到关卡的挑战记录
function LevelRecordLogic.GetTeamData(levelId)
    return LevelRecordLogic.GetRecordData(levelId).tbAchievement
end

---初始化关卡记录信息
function LevelRecordLogic.InitRecordData(levelId)
    local data = {
        levelId = levelId,
        tbAchievement = {}
    }
    return data
end
