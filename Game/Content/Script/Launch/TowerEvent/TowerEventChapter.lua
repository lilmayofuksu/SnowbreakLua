-- ========================================================
-- @File    : TowerEventChapter.lua
-- @Brief   : 爬塔章节管理器
-- ========================================================

---@class TowerEventChapter 章节逻辑管理
TowerEventChapter = TowerEventChapter or {}

---临时变量
local var = {nChapterID = nil, nLevelID = nil, nSeed = 0}

function TowerEventChapter.Log(nLevelID)
    local tbLog = {}
    local sBuffID = nil
    local cfg = TowerEventLevel.Get(nLevelID)
    if cfg then
        sBuffID = table.concat(cfg.tbBuffID, "-")
    end

    tbLog['LevelFinish'] = LaunchLog.LogLevel(6, sBuffID)
    tbLog['FightRecont'] = LaunchLog.LogFightRecont()
    tbLog['FightHistory'] = LaunchLog.LogFightHistory(6)
    tbLog['LevelPerformance'] = LaunchLog.LogPerformance()
    return tbLog
end

---保存关卡ID
function TowerEventChapter.SetLevelID(nLevelID)
    var.nLevelID = nLevelID
end

---获取关卡ID
function TowerEventChapter.GetLevelID()
    return var.nLevelID
end

---设置章节ID
---@param nChapterID number 章节ID
function TowerEventChapter.SetChapterID(nChapterID)
    if var.nChapterID ~= nChapterID then
        var.nChapterID = nChapterID
    end
end

---获取章节ID
function TowerEventChapter.GetChapterID()
    return var.nChapterID
end

---获取下一关ID
function TowerEventChapter.GetNextLevelID()
    local tbCfg = TowerEventLevel.Get(var.nLevelID)
    if not tbCfg then return 0 end
    return tbCfg.nNextID
end

---获取队伍限制
function TowerEventChapter.GetTeamRule()
    local tbLevel = TowerEventLevel.Get(var.nLevelID)
    if tbLevel then
        return tbLevel.tbTeamRule
    end
end

---获取当前挑战关的buffID
function TowerEventChapter.GetTbBuffID()
    local data = {}
    if Launch.GetType() ~= LaunchType.TOWEREVENT then
        return data
    end
    local levelcfg = TowerEventLevel.Get(TowerEventChapter.GetLevelID())
    if levelcfg and #levelcfg.tbBuffID > 0 then
        for _, id in pairs(levelcfg.tbBuffID) do
            table.insert(data, id)
        end
    end
    return data
end

function TowerEventChapter.GetIsBuffOnlyAddToPlayer()
    if Launch.GetType() ~= LaunchType.TOWEREVENT then
        return false
    end
    local levelcfg = TowerEventLevel.Get(TowerEventChapter.GetLevelID())
    if levelcfg and levelcfg.nBuffOnlyAddToPlayer == 1 then
        return true
    end
    return false
end

function TowerEventChapter.Load()
    TowerEventChapter.tbChapter = {}
    local tbFile = LoadCsv("challenge/tower_event/chapter.txt", 1);
    for _, tbLine in ipairs(tbFile) do
        local nID           = tonumber(tbLine.ID) or 0;
        local tbInfo        = {
            nID         = nID,
            sName       = "towereventchapter_" .. nID,
            sEnglishName = "towereventchapter_english_" .. nID,
            tbLevel     = Eval(tbLine.Level) or {},
            tbCondition = Eval(tbLine.Condition) or {},
            nPicture    = tonumber(tbLine.Picture)
        };

        TowerEventChapter.tbChapter[nID] = tbInfo;
    end

    print('load challenge/tower_event/chapter.txt')
end




--[[
        //数据请求
]]



---数据请求类型
TowerEventChapter.REQ_ENTER_LEVEL         = 'TowerEventChapter_EnterLevel'
TowerEventChapter.REQ_LEVEL_SETTLEMENT    = 'TowerEventChapter_LevelSettlement'
TowerEventChapter.REQ_LEVEL_FAIL          = 'TowerEventChapter_LevelFail'

--[[
        请求进入关卡
]]
function TowerEventChapter.Req_EnterLevel(nLevelID)
    local tbCfg = TowerEventLevel.Get(nLevelID)
    if not tbCfg then return end
    ---体力检查
    if tbCfg.tbConsumeVigor and #tbCfg.tbConsumeVigor > 1 and  (not Cash.CheckMoney(Cash.MoneyType_Vigour, tbCfg.tbConsumeVigor[1] + tbCfg.tbConsumeVigor[2])) then
        return
    end

    local tbLog = {}
    tbLog['LevelEnter'] = LaunchLog.LogLevelEnter(6, TowerEventChapter.GetLevelID())

    -- 是否开启
    local cmd = {
        nID = nLevelID,
        nTeamID = Formation.GetCurLineupIndex(),
        tbLog = tbLog,
    }

    me:CallGS(TowerEventChapter.REQ_ENTER_LEVEL, json.encode(cmd))
end

---注册进入关卡的回调
s2c.Register(TowerEventChapter.REQ_ENTER_LEVEL, function(tbRet)
    if tbRet.sErr then
        UI.ShowTip(Text(tbRet.sErr))
        return
    end

    var.nSeed = tbRet.nSeed
    Launch.Response(TowerEventChapter.REQ_ENTER_LEVEL)
end
)

--[[
    ---请求结算关卡
]]
function TowerEventChapter.Req_LevelSettlement(nLevelID)
    local tbKill = {}
    local TaskSubActor = UE4.ATaskSubActor.GetTaskSubActor(GetGameIns())
    local tbMonster = RikiLogic:GetMonsterData(TaskSubActor)
    if TaskSubActor and TaskSubActor.GetAchievementData then
        local tbKillMonster = TaskSubActor:GetAchievementData()
        local tbKey = tbKillMonster:Keys()
        for i = 1, tbKey:Length() do
            local sName = tbKey:Get(i)
            tbKill[sName] = tbKillMonster:Find(tbKey:Get(i))
        end
    end

    local cmd = {
        nID = nLevelID,
        nChapterID = TowerEventChapter.GetChapterID(),
        nSeed = var.nSeed,
        tbLog = TowerEventChapter.Log(nLevelID) or {},
        nTime = Launch.GetLatelyTime(),
        tbKill = tbKill,
        tbMonster = tbMonster
    }
    UI.ShowConnection()
    Reconnect.Send_SettleInfo(TowerEventChapter.REQ_LEVEL_SETTLEMENT, cmd)
end
---注册结算回调
s2c.Register(TowerEventChapter.REQ_LEVEL_SETTLEMENT, function(tbAward)
    UI.CloseConnection()
    Launch.Response(TowerEventChapter.REQ_LEVEL_SETTLEMENT, tbAward)
end)

---关卡失败
function TowerEventChapter.Req_LevelFail(nLevelID)
    local cmd = {
        nID = nLevelID,
        tbLog = TowerEventChapter.Log(nLevelID) or {}
    }
    UI.ShowConnection()
    me:CallGS(TowerEventChapter.REQ_LEVEL_FAIL, json.encode(cmd))
end
s2c.Register(TowerEventChapter.REQ_LEVEL_FAIL, function()
    UI.CloseConnection()
end)

-----------------------------------------------------------------
TowerEventChapter.Load()
