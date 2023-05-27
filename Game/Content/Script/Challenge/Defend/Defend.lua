-- ========================================================
-- @File    : Challenge/Defend/Defend.lua
-- @Brief   : 防御活动逻辑
-- ========================================================

DefendLogic = DefendLogic or {}

DefendLogic.GID         = 10        -- GID

DefendLogic.ActId       = 0         -- 当前开放期数ID
DefendLogic.Diff        = 1         -- 0-15位最大难度 16-31位当前难度
DefendLogic.PassWave    = 2         -- 最大通过波数
DefendLogic.AwardsGot   = 3         -- 领奖状态 按位存

-- 日志需求
DefendLogic.RoundId     = 11        -- 死斗轮次Id 开新局递增 用于关联日志
---

DefendLogic.FightData   = 1         -- 关卡存档

DefendLogic.TeamId      = 13        -- 死斗编队

DefendLogic.sUI = 'DungeonsDefend'

DefendLogic.tbCurTimeConf = {}

--- 死斗存档模板
DefendLogic.tbFightDataTpl = {
    Device = -1,
    Money = 0,
    Wave = 1,
    ExTimeWaves = 0,
    PlayerHp = -1,
    MonsterWave = 0,
}

DefendLogic.tbCache = {}

------------------------------------------Init--------------------------------------------
function DefendLogic.LoadConfig()
    DefendLogic.LoadTimeConf()
    DefendLogic.LoadLevelConf()
    DefendLogic.LoadRewardConf()
    DefendLogic.LoadWaveConf()
end

function DefendLogic.LoadTimeConf()
    DefendLogic.tbActConf = {}
    local tbFile = LoadCsv('challenge/defend/defend_act.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local Id = tonumber(tbLine['ID'])
        local Coverage = tonumber(tbLine['Coverage']) or 0
        if Id and CheckCoverage(Coverage) then
            local tb = {}
            tb.nId = Id
            tb.sUI = tbLine.UI
            tb.nShopId = tonumber(tbLine.ShopId) or 0
            tb.nHelpImg = tonumber(tbLine.HelpImg)
            tb.nEntryImg = tonumber(tbLine.EntryImg)
            tb.sEntryName = tbLine.EntryName
            tb.nNameImg = tonumber(tbLine.NameImg)
            DefendLogic.tbActConf[Id] = tb
        end
    end
    print('challenge/defend/defend_act.txt')

    DefendLogic.tbTimeConf = {}
    tbFile = LoadCsv('challenge/defend/defend_time.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local Coverage = tonumber(tbLine.Coverage) or 0
        if CheckCoverage(Coverage) then
            DefendLogic.tbTimeConf.nBeginTime = ParseTime(string.sub(tbLine['BeginTime'] or '', 2, -2))
            DefendLogic.tbTimeConf.tbRefreshTime = Eval(tbLine['RefreshTime']) or {}
        end
    end
    print('challenge/defend/defend_time.txt')
end

function DefendLogic.LoadLevelConf()
    DefendLogic.tbLevelOrder = {}
    local tbFile = LoadCsv('challenge/Defend/defend_levelorder.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID) or 0;
        local nDiff = tonumber(tbLine.Diff) or 0
        if nID > 0 and nDiff > 0 then
            local tbInfo = {
                nID                 = nID,
                nDiff               = nDiff,
                nLevelID            = tonumber(tbLine.LevelId) or 0,
                tbCondition	        = Eval(tbLine.Condition) or {},
                tbLevelBuff         = Eval(tbLine.LevelBuff) or {},
                sBuffDesc           = tbLine.BuffDesc,
            }
            DefendLogic.tbLevelOrder[nID] = DefendLogic.tbLevelOrder[nID] or {}
            DefendLogic.tbLevelOrder[nID][nDiff] = tbInfo
        end
    end
    print('challenge/defend/defend_levelorder.txt')

    DefendLogic.tbLevel = {}
    tbFile = LoadCsv('challenge/Defend/level.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local nLevelID = tonumber(tbLine.LevelId) or 0
        if nLevelID > 0 then
            local tbInfo = {
                nLevelID            = nLevelID,
                sName               = tbLine.Name,
                sDesc               = tbLine.Desc,
                nType               = ChapterLevelType.NORMAL,
                nMapID              = tonumber(tbLine.MapID) or 0,
                sTaskPath           = string.format('/Game/Blueprints/LevelTask/Tasks/%s', tbLine.TaskPath),
                tbStarCondition     = Eval(tbLine.StarCondition) or {},
                tbMonster           = Eval(tbLine.Monster) or {},
                tbTarget            = Eval(tbLine.Target) or {},
                nPicture            = tonumber(tbLine.Picture),
                nPictureBoss        = tonumber(tbLine.PictureBoss),
                nPictureLevel       = tonumber(tbLine.PictureLevel),
                nRecommendLevel     = tonumber(tbLine.RecommendLevel) or 0,
                tbShowReward        = Eval(tbLine.ShowReward),
            }

            tbInfo.GetOption = function(self)
                local sOption = 'TaskPath=%s?ReviveCount=%s?AutoReviveTime=%s?AutoReviveHealthScale=%s'
                sOption = string.format(sOption, self.sTaskPath, 0, 0, 0)
                return sOption
            end

            tbInfo.DidGotStar = function(self, index)
                local starVal = me:GetAttribute(DefendLogic.GID, DefendLogic.StarState)
                return GetBits(starVal, index, index) == 1
            end

            DefendLogic.tbLevel[nLevelID] = tbInfo
        end
    end
    print('challenge/defend/level.txt')
end

function DefendLogic.LoadRewardConf()
    DefendLogic.tbTarget = {}
    local tbFile = LoadCsv('challenge/defend/level_target.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local Id = tonumber(tbLine['Id']) or 0
        if Id > 0 then
            local tb = {}
            tb.nId = Id
            tb.nType = tonumber(tbLine['Type']) or 0
            if tb.nType == 1 then
                tb.nWave = tonumber(tbLine['Param']) or 0
            elseif tb.nType == 2 then
                tb.tbStarCondition = Eval(tbLine['Param']) or {}
                tb.sStarCondition = tbLine['Param'] or ''
            end
            tb.tbReward = Eval(tbLine['Award']) or {}
            DefendLogic.tbTarget[Id] = tb
        end
    end
    print('challenge/defend/level_target.txt')
end

function DefendLogic.LoadWaveConf()
    DefendLogic.tbWaveConf = {}
    local tbFile = LoadCsv('challenge/defend/wave.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local nDiff = tonumber(tbLine.Diff) or 0
        if nDiff > 0 then
            local tb = {}
            tb.nStartLevel = tonumber(tbLine.StartLevel) or 0
            tb.tbLevelAdd = Eval(tbLine.LevelAdd) or {}
            DefendLogic.tbWaveConf[nDiff] = tb
        end
    end
    print('challenge/defend/wave.txt')
end
------------------------------------------InitEnd--------------------------------------------


------------------------------------------GetData--------------------------------------------
-- 返回 最大难度
function DefendLogic.GetMaxDiff()
    local val = me:GetAttribute(DefendLogic.GID, DefendLogic.Diff)
    return GetBits(val, 0, 15)
end

-- 返回 当前难度
function DefendLogic.GetCurDiff()
    local val = me:GetAttribute(DefendLogic.GID, DefendLogic.Diff)
    return GetBits(val, 16, 31)
end

-- 当前进入 活动Id，难度Id
function DefendLogic.GetIDAndDiff()
    local ActId = me:GetAttribute(DefendLogic.GID, DefendLogic.ActId)
    local Diff = DefendLogic.GetCurDiff()
    if Diff == 0 then Diff = 1 end
    return ActId, Diff
end

function DefendLogic.GetLevelConf(nId, nDiff)
    local tbOrder = DefendLogic.GetLevelOrderConf(nId, nDiff)
    if tbOrder then
        return DefendLogic.tbLevel[tbOrder.nLevelID]
    end
end

function DefendLogic.GetLevel(nLevelID)
    if nLevelID then
        return DefendLogic.tbLevel[nLevelID]
    end
end

function DefendLogic.GetLevelOrderConf(nId, nDiff)
    if DefendLogic.tbLevelOrder[nId] then
        return DefendLogic.tbLevelOrder[nId][nDiff]
    end
end

function DefendLogic.GetLevelID()
    local levelConf = DefendLogic.GetLevelConf(DefendLogic.GetIDAndDiff())
    if levelConf then return levelConf.nLevelID end
    return 0
end

function DefendLogic.GetOpenConf()
    local nActId = me:GetAttribute(DefendLogic.GID, DefendLogic.ActId)
    if DefendLogic.tbActConf[nActId] then return DefendLogic.tbActConf[nActId] end
    return DefendLogic.tbActConf[0]
end

-- 获取战斗存档
function DefendLogic.GetFightData(bFight)
    local tbData
    local val = me:GetStrAttribute(DefendLogic.GID, DefendLogic.FightData)
    if not val or val == '' then
        tbData = Copy(DefendLogic.tbFightDataTpl)
    else
        tbData = json.decode(val)
    end
    if bFight and DefendLogic.GMWave then  --GM设置波数
        tbData.MonsterWave = DefendLogic.GMWave
        tbData.Wave = DefendLogic.GMWave // 3 + 1
        DefendLogic.GMWave = nil
    end
    return tbData
end

-- 是否已开始战斗
function DefendLogic.IsInFight()
    local val = me:GetStrAttribute(DefendLogic.GID, DefendLogic.FightData)
    if not val or val == '' then
        return false
    end
    return true
end

-- 当前难度最大波次
function DefendLogic.GetMaxWave()
    return me:GetAttribute(DefendLogic.GID, DefendLogic.PassWave)
end

-- 当前存档波数
function DefendLogic.GetCurrWave()
    local data = DefendLogic.GetFightData()
    return data and data.MonsterWave or 0
end

-- 是否可以修改难度 （未领奖可修改）
function DefendLogic.CanChangeDiff()
    return me:GetAttribute(DefendLogic.GID, DefendLogic.AwardsGot) == 0
end

-- 获取关卡buff
function DefendLogic.GetAllBuff()
    local tb = {}
    local nId, nDiff = DefendLogic.GetIDAndDiff()
    local tbConf = DefendLogic.GetLevelOrderConf(nId, nDiff)
    if not tbConf then return tb end
    for _, id in ipairs(tbConf.tbLevelBuff) do
        table.insert(tb, id)
    end
    return tb
end

-- 是否首次进入活动
function DefendLogic.IsFirstEnter()
    if UE4.UUserSetting.GetBool(string.format('FirstDefend_%d', me:Id()), true) then
        UE4.UUserSetting.SetBool(string.format('FirstDefend_%d', me:Id()), false)
        UE4.UUserSetting.Save()
        return true
    end
    return false
end

-- 根据波数获取怪物等级加成
function DefendLogic.GetMonsLevelByWave(nWave)
    local nDiff = DefendLogic.GetCurDiff()
    local WaveInfo = DefendLogic.tbWaveConf[nDiff]
    if not WaveInfo then return 1 end
    if nWave == 1 then return WaveInfo.nStartLevel end

    local pGetWaveAdd = function(_wave)
        for _, info in ipairs(WaveInfo.tbLevelAdd) do
            if #info >= 3 then
                if info[1] - 1 <= _wave and info[2] >= _wave then
                    return info[3]
                end
            end
        end
        return 1
    end

    local Level = WaveInfo.nStartLevel
    for i = 2, nWave do
        Level = Level + pGetWaveAdd(i)
    end
    return Level
end

-- 玩家死斗轮次ID
function DefendLogic.GetRoundId()
    return me:GetAttribute(DefendLogic.GID, DefendLogic.RoundId)
end
------------------------------------------GetDataEnd--------------------------------------------


------------------------------------------SetData--------------------------------------------
-- 修改难度
function DefendLogic.ChangeDiff(nDiff, pCallBack)
    if nDiff > DefendLogic.GetMaxDiff() + 1 then
        return UI.ShowMessage('ui.Defense_Unlock_Tips')
    end
    if not DefendLogic.CanChangeDiff() then
        return UI.ShowMessage(Text('ui.TxtDefenseTip3'))
    end
    if nDiff == DefendLogic.GetCurDiff() then return end

    if DefendLogic.IsInFight() then
        UI.OpenMessageBox(false, Text('ui.Defense_Change_Difficult'), function()
            local cmd = {
                nDiff = nDiff,
                tbLog = DefendLogic.SaveLog(false)
            }
            me:CallGS('DefendLogic_ChangeDiff', json.encode(cmd))
            DefendLogic.pChangeDiffCall = pCallBack
        end, function() end)
    else
        me:CallGS('DefendLogic_ChangeDiff', json.encode({nDiff = nDiff}))
        DefendLogic.pChangeDiffCall = pCallBack
    end
end

-- 注册修改难度回调
s2c.Register('DefendLogic_ChangeDiff', function()
    if DefendLogic.pChangeDiffCall then
        DefendLogic.pChangeDiffCall()
        DefendLogic.pChangeDiffCall = nil
    end
end)

-- 手动清空存档
function DefendLogic.ClearFightData()
    if not DefendLogic.IsInFight() then
        return UI.ShowTip(Text("ui.Defense_Wave_NoNeedReset"))
    end
    UI.OpenMessageBox(false, Text('ui.Defense_Wave_Reset'), function()
        local cmd = { tbLog = DefendLogic.SaveLog(false) }
        me:CallGS('DefendLogic_ClearFightData', json.encode(cmd))
    end, function() end)
end

-- 注册清空存档回调
s2c.Register('DefendLogic_ClearFightData', function()
    UI.ShowTip(Text("ui.Defense_Wave_ResetSuccess"))
    UI.Call2(DefendLogic.sUI, 'ShowInfo')
    UI.Call2(DefendLogic.sUI, 'UpdateWave')
end)
------------------------------------------SetDataEnd--------------------------------------------


------------------------------------------Time--------------------------------------------
function DefendLogic.CheckOpenAct()
    FunctionRouter.CheckEx(FunctionType.Defend, function()
        UI.ShowConnection()
        me:CallGS("DefendLogic_CheckOpenAct")
    end)
end

s2c.Register('DefendLogic_CheckOpenAct', function(tbParam)
    UI.CloseConnection()
    if tbParam and tbParam.bOpen then
        if tbParam.nId and tbParam.nBeginTime and tbParam.nEndTime then
            DefendLogic.tbCurTimeConf = {tbParam.nBeginTime, tbParam.nEndTime}
        end
        Launch.SetType(LaunchType.DEFEND)
        local conf = DefendLogic.GetOpenConf()
        DefendLogic.sUI = (conf.sUI and conf.sUI ~= '') and conf.sUI or 'DungeonsDefend'
        if not UI.IsOpen(DefendLogic.sUI) then UI.Open(DefendLogic.sUI) end
        DefendLogic.bReqEnter = false
    else
        UI.ShowTip(Text("ui.TxtNotOpen"))
    end
end)

-- 根据期数获取开启时间
function DefendLogic.GetTimeInfo(nId)
    local nBeginTime, tbRefreshTime = DefendLogic.tbTimeConf.nBeginTime, DefendLogic.tbTimeConf.tbRefreshTime
    local startTime, endTime = 0, 0

    local spendWeek = math.floor(nId / #tbRefreshTime)
    local time = spendWeek * 7 * 86400 + nBeginTime
    local overTime = nId - spendWeek * #tbRefreshTime

    local tab = os.date('*t', time)
    local nWday = tab.wday - 1
    nWday = nWday == 0 and 7 or nWday

    if overTime == 0 then
        local timeStr = string.format('%d%02d%02d%04d', tab.year, tab.month, tab.day, tbRefreshTime[#tbRefreshTime][2])
        startTime = ParseTime(timeStr) - 7 * 86400 + (tbRefreshTime[#tbRefreshTime][1] - nWday) * 86400
    else
        local timeStr = string.format('%d%02d%02d%04d', tab.year, tab.month, tab.day, tbRefreshTime[overTime][2])
        startTime = ParseTime(timeStr) + (tbRefreshTime[overTime][1] - nWday) * 86400
    end
    local timeStr = string.format('%d%02d%02d%04d', tab.year, tab.month, tab.day, tbRefreshTime[overTime+1][2])
    endTime = ParseTime(timeStr) + (tbRefreshTime[overTime+1][1] - nWday) * 86400

    return startTime, endTime
end

-- 特殊期数开放时间
function DefendLogic.GetSpecialTime(Str)
    local startTime, endTime = 0, 0
    for _, tbConf in pairs(DefendLogic.tbActConf) do
        if tbConf.sUI == Str then
            local time1, time2 = DefendLogic.GetTimeInfo(tbConf.nId)
            if startTime == 0 or time1 < startTime then
                startTime = time1
            end
            if endTime == 0 or time2 > endTime then
                endTime = time2
            end
        end
    end
    return startTime, endTime
end
------------------------------------------TimeEnd--------------------------------------------


------------------------------------------Fight--------------------------------------------
---请求进入关卡
function DefendLogic.Req_EnterLevel(nLevelID, nDiff)
    local tbCfg = DefendLogic.GetLevelConf(nLevelID, nDiff)
    if not tbCfg then return end

    local tbLog = {}
    tbLog['LevelEnter'] = LaunchLog.LogLevelEnter(LaunchType.DEFEND)

    local cmd = {
        nID = nLevelID,
        nDiff= nDiff,
        nTeamID = Formation.GetCurLineupIndex(),
        tbLog = tbLog,
    }

    if DefendLogic.bReqEnter then return end

    DefendLogic.bReqEnter = true
    me:CallGS('DefendLogic_EnterLevel', json.encode(cmd))
end

---注册进入关卡的回调
s2c.Register('DefendLogic_EnterLevel', function(tbRet)
    DefendLogic.bReqEnter = false
    DefendLogic.nSeed = tbRet.nSeed
    local tbFightData = DefendLogic.GetFightData()
    DefendLogic.tbCache.nStartWave = tbFightData and ((tbFightData.Wave - 1) * 3 + 1) or 1
    Launch.Response('DefendLogic_EnterLevel')
end)

-- 保存关卡进度
function DefendLogic.SaveFightData(tbData, pCallBack)
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
        tbKillMonster:Clear()
    end

    local nID, nDiff = DefendLogic.GetIDAndDiff()
    local cmd = {
        nID = nID,
        nDiff = nDiff,
        nSeed = DefendLogic.nSeed,
        tbData = tbData,
        tbLog = DefendLogic.SaveLog(true, tbData),
        tbKill = tbKill,
        tbMonster = tbMonster,
    }
    UI.ShowConnection()
    Reconnect.Send_SettleInfo("DefendLogic_SaveFightData", cmd)
    DefendLogic.SaveFinishCall = pCallBack
end

-- 注册保存关卡回调
s2c.Register('DefendLogic_SaveFightData', function(tbRet)
    UI.CloseConnection()
    if DefendLogic.SaveFinishCall then
        DefendLogic.SaveFinishCall()
        DefendLogic.SaveFinishCall = nil
        DefendLogic:ClearCacheLogAfterSave()
    end
    if tbRet.unlockNew then
        UI.ShowTip(Text('ui.Defense_Unlock_Done'))
    end
end)

---关卡结算
function DefendLogic.Req_LevelSettlement(nLevelID, nDiff, nResult)
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
        tbKillMonster:Clear()
    end

    local finishWave = DefendLogic.GetCurWave()
    if nResult ~= UE4.ELevelFinishResult.Success then finishWave = finishWave - 1 end
    local cmd = {
        nID = nLevelID,
        nDiff = nDiff,
        nWave = finishWave,
        nSeed = DefendLogic.nSeed,
        tbLog = DefendLogic.SettlementLog(nResult),
        tbKill = tbKill,
        tbMonster = tbMonster,
    }
    UI.ShowConnection()
    Reconnect.Send_SettleInfo("DefendLogic_LevelSettlement", cmd)
end

s2c.Register('DefendLogic_LevelSettlement', function()
    UI.CloseConnection()
    Launch.Response('DefendLogic_LevelSettlement')
    DefendLogic:ClearAllCacheLog()
    UI.Call2(DefendLogic.sUI, 'UpdateWave')
end)

-- 当前波数
function DefendLogic.GetCurWave()
    local pTaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
    if pTaskActor and pTaskActor.TaskDataComponent then
        return pTaskActor.TaskDataComponent:GetOrAddValue('MonsterWave')
    end
    return 0
end
------------------------------------------FightEnd--------------------------------------------



------------------------------------------Log--------------------------------------------
-- 关卡暂存日志
function DefendLogic:WaveIndexLog(Wave,Index)
    self.tbCacheLog = self.tbCacheLog or {}
    self.tbCacheLog['Wave'] = self.tbCacheLog['Wave'] or {}
    if self.tbCacheLog['Wave'][#self.tbCacheLog['Wave']] and self.tbCacheLog['Wave'][#self.tbCacheLog['Wave']].Wave == Wave then
        table.insert(self.tbCacheLog['Wave'][#self.tbCacheLog['Wave']].tbIndex,Index)
    else
        self.tbCacheLog['Wave'][#self.tbCacheLog['Wave'] + 1] = {Wave = Wave,tbIndex = {Index}}
    end
end

function DefendLogic:GetWaveIndexLogStr()
    if not self.tbCacheLog or not self.tbCacheLog['Wave'] then
        return 'NULL'
    end
    local str = ''
    for i,v in ipairs(self.tbCacheLog['Wave']) do
        for id,Index in ipairs(v.tbIndex) do
            if id ~= #v.tbIndex then
                str = str..Index..'-'
            else
                str = str..Index
            end
        end

        if i ~= #self.tbCacheLog['Wave'] then
            str = str..'#'
        end
    end
    return str
end

function DefendLogic:WaveLeftTimeCacheLog(Wave,LeftTime)
    self.tbCacheLog = self.tbCacheLog or {}
    self.tbCacheLog['WaveLeftTime'] = self.tbCacheLog['WaveLeftTime'] or {}
    self.tbCacheLog['WaveLeftTime'][#self.tbCacheLog['WaveLeftTime'] + 1] = {Wave = Wave,LeftTime = LeftTime}
end

function DefendLogic:GetWaveLeftTimeLogStr()
    if not self.tbCacheLog or not self.tbCacheLog['WaveLeftTime'] then
        return 'NULL'
    end
    local str = ''
    for i,v in ipairs(self.tbCacheLog['WaveLeftTime']) do
        if i == #self.tbCacheLog['WaveLeftTime'] then
            str = str..v.Wave..':'..v.LeftTime
        else
            str = str..v.Wave..':'..v.LeftTime..'#'
        end
    end
    return str
end

function DefendLogic:BillCacheLog(Id)
    self.tbCacheLog = self.tbCacheLog or {}
    self.tbCacheLog['Bill'] = self.tbCacheLog['Bill'] or {}
    self.tbCacheLog['Bill'][Id] = (self.tbCacheLog['Bill'][Id] or 0) + 1
end

function DefendLogic:GetBillLogStr()
    if not self.tbCacheLog or not self.tbCacheLog['Bill'] then
        return 'NULL'
    end

    local str = ''
    local allCount = 0
    for k,v in pairs(self.tbCacheLog['Bill']) do
        allCount = allCount + 1
    end
    local NowCount = 0
    for i,v in pairs(self.tbCacheLog['Bill']) do
        NowCount = NowCount + 1
        if NowCount == allCount then
            str = str..i..':'..v
        else
            str = str..i..':'..v..','
        end
    end
    return str
end

function DefendLogic:ClearCacheLogAfterSave()
    self.tbCacheLog = self.tbCacheLog or {}
    self.tbCacheLog['Bill'] = nil
    self.tbCacheLog['Wave'] = nil
end

function DefendLogic:ClearAllCacheLog()
    self.tbCacheLog = {}
end

-- 结算日志
function DefendLogic.SettlementLog(nResult)
    local finishWave = DefendLogic.GetCurWave()
    if nResult ~= UE4.ELevelFinishResult.Success then finishWave = finishWave - 1 end
    finishWave = (finishWave <= DefendLogic.tbCache.nStartWave) and 0 or finishWave

    local tbLog = {}
    tbLog['LevelFinish'] = LaunchLog.LogLevel(LaunchType.DEFEND, string.format("%d-%d", DefendLogic.tbCache.nStartWave, finishWave))
    tbLog['FightRecont'] = LaunchLog.LogFightRecont()
    tbLog['FightHistory'] = LaunchLog.LogFightHistory(LaunchType.DEFEND)
    tbLog['LevelPerformance'] = LaunchLog.LogPerformance()

    local id, diff = DefendLogic.GetIDAndDiff()
    local levelConf = DefendLogic.GetLevelConf(id, diff)
    local LevelId = string.format('%d-%d-%d', id, diff, levelConf.nLevelID)
    local GameTaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
    local LevelFinishType = GameTaskActor and GameTaskActor:GetFightLog_LevelFinishType() or ""
    local WaveLeftTimeStr = DefendLogic:GetWaveLeftTimeLogStr()
    local WaveGroupStr = DefendLogic:GetWaveIndexLogStr()
    local BillStr = DefendLogic:GetBillLogStr()
    --print('死斗日志，结算:',WaveLeftTimeStr,WaveGroupStr,BillStr)

    tbLog['DefenseLevel'] = {
        --[[1['LevelType'] = ]]         LaunchType.DEFEND,
        --[[2['LevelId'] = ]]           LevelId,
        --[[3['LevelFinishType'] = ]]   LevelFinishType,
        --[[4['DefenseRoundId'] = ]]    DefendLogic.GetRoundId(),
        --[[5['DefenseBuffId'] = ]]     table.concat(DefendLogic.GetAllBuff(), '-'),
        --[[6['StartWave'] = ]]         DefendLogic.tbCache.nStartWave,
        --[[7['FinishWave'] = ]]        finishWave,
        --[[8['WaveLeftTime'] = ]]      WaveLeftTimeStr,
        --[[9['WaveGroup'] = ]]         WaveGroupStr,
        --[[10['Bill'] = ]]             BillStr,
    }

    return tbLog
end

-- 存档日志
function DefendLogic.SaveLog(bAuto, tbData)
    tbData = tbData or DefendLogic.GetFightData()
    local strHp = ''
    for i = 1, 3 do
        local hp = tostring(GetBits(tbData.PlayerHp, (i-1)*8, i*8-1))
        if strHp == '' then
            strHp = hp
        else
            strHp = strHp..'-'..hp
        end
    end
    local hpDevice, boomDevice = 0, 0
    for i = 1, 5 do
        if GetBits(tbData.Device, i, i) == 1 then hpDevice = hpDevice + 1 end
    end
    for i = 6, 31 do
        if GetBits(tbData.Device, i, i) == 1 then boomDevice = boomDevice + 1 end
    end
    local WaveGroupStr = DefendLogic:GetWaveIndexLogStr()
    local BillStr = DefendLogic:GetBillLogStr()
    local tbLog = {}
    --print('死斗日志，存档:',WaveGroupStr,BillStr)
    tbLog['DefenseRecord'] = {
        --[[1['DefenseRoundId'] = ]]    DefendLogic.GetRoundId(),
        --[[2['RecordType'] = ]]        bAuto and 1 or 3,
        --[[3['CurrentWave'] = ]]       tbData.MonsterWave,
        --[[4['CurrentHp'] = ]]         strHp,
        --[[5['CurrentLXL'] = ]]        tbData.Money,
        --[[6['CurrentExTime'] = ]]     tbData.ExTimeWaves,
        --[[7['CurrentDevice'] = ]]     string.format('1:%d#2:%d', hpDevice, boomDevice),
        --[[8['WaveGroup'] = ]]         WaveGroupStr,
        --[[9['Bill'] = ]]              BillStr,
    }

    return tbLog
end
------------------------------------------LogEnd--------------------------------------------



------------------------------------------Reward--------------------------------------------
-- 返回任务状态 0未完成 1可领 2已领
function DefendLogic.GetTargetState(targetId)
    local nId, nDiff = DefendLogic.GetIDAndDiff()
    local levelConf = DefendLogic.GetLevelConf(nId, nDiff)
    local targetConf = DefendLogic.tbTarget[targetId]
    local idx = 0
    for i, v in ipairs(levelConf.tbTarget) do
        if v == targetId then
            idx = i
            break
        end
    end
    local GotVal = me:GetAttribute(DefendLogic.GID, DefendLogic.AwardsGot)
    if targetConf.nType == 1 then
        if me:GetAttribute(DefendLogic.GID, DefendLogic.PassWave) < targetConf.nWave then
            return 0
        elseif GetBits(GotVal, idx, idx) == 0 then
            return 1
        else
            return 2
        end
    end
end

-- 是否有奖励可领
function DefendLogic.CanGetReward()
    local tbLevelConf = DefendLogic.GetLevelConf(DefendLogic.GetIDAndDiff())
    if not tbLevelConf then return false end
    for _, v in ipairs(tbLevelConf.tbTarget) do
        if DefendLogic.GetTargetState(v) == 1 then
            return true
        end
    end
    return false
end

-- 一键领奖
function DefendLogic.GetRewardAll()
    if not DefendLogic.CanGetReward() then return end
    local nId, nDiff = DefendLogic.GetIDAndDiff()
    me:CallGS("DefendLogic_GetReward", json.encode({nID = nId, nDiff = nDiff, bAll = true}))
end

-- 领奖
function DefendLogic.GetReward(targetId)
    local nId, nDiff = DefendLogic.GetIDAndDiff()
    local levelConf = DefendLogic.GetLevelConf(nId, nDiff)
    local bCheck, index = false, 0
    for i, id in ipairs(levelConf.tbTarget) do
        if id == targetId then
            bCheck = true
            index = i
            break
        end
    end
    if not bCheck then return end
    local targetConf = DefendLogic.tbTarget[targetId]
    if not targetConf then return end

    local val = me:GetAttribute(DefendLogic.GID, DefendLogic.AwardsGot)
    if GetBits(val, index, index) == 1 then return end
    local cmd = {
        nID = nId,
        nDiff = nDiff,
        nTargetId = targetId,
        nIdx = index
    }
    UI.ShowConnection()
    me:CallGS("DefendLogic_GetReward", json.encode(cmd))
end

-- 注册领奖回调
s2c.Register('DefendLogic_GetReward', function(tbParam)
    UI.CloseConnection()
    if tbParam and tbParam.tbReward and CountTB(tbParam.tbReward) > 0 then
        UI.Open('GainItem', tbParam.tbReward)
    end
    DefendLogic.bGetAllReward = tbParam.bGetAll
    UI.Call2('DefenseAward', 'OnOpen')
    UI.Call2(DefendLogic.sUI, 'UpdateNew')
end)

-- 领取所有奖励后提示
function DefendLogic.ShowGetAll()
    if DefendLogic.bGetAllReward then
        UI.ShowTip('ui.Defense_Mission_Tips')
        DefendLogic.bGetAllReward = nil
    end
end
------------------------------------------RewardEnd--------------------------------------------



------------------------------------------GM--------------------------------------------
-- GM指令 打开指定期数
function DefendLogic.GMOpenActive(ActId)
    -- if not ActId then return end
    -- if ActId == 0 then return DefendLogic.LoadTimeConf() end
    -- if me:GetAttribute(DefendLogic.GID, DefendLogic.ActId) == ActId then return end
    -- if not DefendLogic.tbTimeConf[ActId] then return end

    -- local Time = GetTime()
    -- local startTime = Time - 3600
    -- local endTime = Time + 86400

    -- for _, cfg in pairs(DefendLogic.tbTimeConf) do
    --     if cfg.nId == ActId then
    --         cfg.nBeginTime = startTime
    --         cfg.nEndTime = endTime
    --     else
    --         cfg.nEndTime = startTime
    --     end
    -- end 
end

-- GM增加关卡时长
function DefendLogic.GMAddLevelTime(Time)
    if Launch.GetType() ~= LaunchType.DEFEND then return end
    if not Time or Time == 0 then return end
    local Actor = UE4.UGameplayStatics.GetActorOfClass(GetGameIns(), UE4.AGameTaskActor)
    if not Actor then return end
    local TaskActor = Actor:Cast(UE4.AGameTaskActor)
    if not IsValid(TaskActor) or not TaskActor.CurrentFlow then return end
    local Tasks = TaskActor.CurrentFlow:GetAllInProgressExecuteNodes()
    if Tasks == nil then return end
    for i = 1, Tasks:Length() do
        local Task = Tasks:Get(i)
        if Task.CountDown > 0 then
            Task:ClearCountDownTimer()
            Task.CountDown = Task.CountDown + Time
            Task:ActiveCountDown()
        end
    end
end

-- GM设置波数
function DefendLogic.GMSetWave(nWave)
    DefendLogic.GMWave = nWave
end

------------------------------------------GMEnd--------------------------------------------



DefendLogic.LoadConfig()