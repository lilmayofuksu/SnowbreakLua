-- ========================================================DLC_Chapter
-- @File    : DLC_Chapter.lua
-- @Brief   : DLC副本章节管理器
-- ========================================================

---@class DLC_Chapter 章节逻辑管理
DLC_Chapter = DLC_Chapter or {}

---临时变量
local var = {nChapterID = nil, nLevelID = nil, nSeed = 0}
DLC_Chapter.GID_MASK        = 30

function DLC_Chapter.Log(nLevelID)
    local tbLog = {}
    local nMultiple = Launch.GetMultiple()
    tbLog['LevelFinish'] = LaunchLog.LogLevel(12, nMultiple)
    tbLog['FightRecont'] = LaunchLog.LogFightRecont()
    tbLog['FightHistory'] = LaunchLog.LogFightHistory(12)
    tbLog['LevelPerformance'] = LaunchLog.LogPerformance()
    return tbLog
end

function DLC_Chapter.GetNewDotState()
    if not DLC_Chapter.CheckChapterOpen(1) then
        return false
    end
    local cfg = DLC_Chapter.GetChapterCfg(1)
    for _, nLevelID in ipairs(cfg.tbLevel) do
        local tbLevelCfg = DLCLevel.Get(nLevelID)
        if tbLevelCfg and tbLevelCfg.nType == 7 then
            local bUnLock, _ = Condition.Check(tbLevelCfg.tbCondition)
            local IsCompleted = tbLevelCfg:IsCompleted()
            if bUnLock and not IsCompleted then
                return true
            end
        end
    end

    return false
end

--检查活动是否开启
function DLC_Chapter.CheckChapterOpen(nChapterID)
    local cfg = DLC_Chapter.GetChapterCfg(nChapterID)
    if not cfg then return false end
    local nTime = GetTime()
    if nTime < cfg.OpenTime then
        return false, {'ui.TxtNotOpen'}
    elseif  nTime > cfg.CloseTime then
        return false, {'ui.TxtDLC1Over'}
    end

    return Condition.Check(cfg.tbCondition)
end

---保存关卡ID
function DLC_Chapter.SetLevelID(nLevelID)
    var.nLevelID = nLevelID
end

---获取关卡ID
function DLC_Chapter.GetLevelID()
    return var.nLevelID
end

---设置章节ID
---@param nChapterID number 章节ID
function DLC_Chapter.SetChapterID(nChapterID)
    if var.nChapterID ~= nChapterID then
        var.nChapterID = nChapterID
    end
end

function DLC_Chapter.GetLevelStarCfg(nLevelID)
    local tbLevel = DLCLevel.Get(nLevelID)
    if not tbLevel then 
        return ""
    end
    return tbLevel.sStarCondition
end

---获取章节ID
function DLC_Chapter.GetChapterID()
    return var.nChapterID
end

---获取指定ID的章节
---@param nChapterID number 章节ID
function DLC_Chapter.GetChapterCfg(nChapterID)
    return DLC_Chapter.tbChapter[nChapterID]
end

---获取下一关ID
function DLC_Chapter.GetNextLevelID()
    local tbCfg = DLCLevel.Get(var.nLevelID)
    if not tbCfg then return 0 end
    return tbCfg.nNextID
end

---获取队伍限制
function DLC_Chapter.GetTeamRule()
    local tbLevel = DLCLevel.Get(var.nLevelID)
    if tbLevel then
        return tbLevel.tbTeamRule
    end
end

---是否是剧情关卡
---@param nLevelID Integer 关卡ID
function DLC_Chapter.IsPlot(nLevelID)
    nLevelID = nLevelID or var.nLevelID
    local tbLevelCfg = DLCLevel.Get(nLevelID)
    return tbLevelCfg and (tbLevelCfg.nType == 2 or tbLevelCfg.nType == 7)
end

---更新章节星级奖励提示
---@param nChapterID number 章节ID
function DLC_Chapter.UpdateStarAwardTip(nChapterID)
    local bTip = DLC_Chapter.IsCanGetStarAward(nChapterID)
    local nNum = bTip and 1 or 0
    RedPoint.SetRedNum(RedPointType.StarAward, nNum, string.format('%d', nChapterID))
end

---章节星级奖励是否可以领取
---@param nChapterID number 章节ID
function DLC_Chapter.IsCanGetStarAward(nChapterID)
    local tbCfg = DLC_Chapter.GetChapterCfg(nChapterID)
    if tbCfg == nil then return false end
    local tbAward = tbCfg.tbStarAward
    if tbAward == nil then return false end

    local ret = false
    local tbRet = {}
    local nAllNum, nGetNum = DLC_Chapter.GetChapterStarInfo(nChapterID)
    for nLevel, tbInfo in ipairs(tbAward) do
        local bGet = DLC_Chapter.DidGotStarAward(nChapterID, nLevel)
        if (not bGet) and tbInfo[1] <= nGetNum then
            if not ret then
                ret = true
            end
            tbRet[nLevel] = true
        else
            tbRet[nLevel] = false
        end
    end


    return ret, tbRet
end

function DLC_Chapter.DidGotStarAward(nChapterID, nIndex)
    local nMask = me:GetAttribute(DLC_Chapter.GID_MASK, nChapterID);
    return GetBits(nMask, nIndex, nIndex) == 1
end

---刷新剧情关卡提示信息
---@param nChapterID Integer 章节ID
function DLC_Chapter.UpdatePlotLevelTip(nChapterID)
    local chapterCfg = DLC_Chapter.GetChapterCfg(nChapterID)
    if not chapterCfg then return end
     ---剧情关卡
     local tbLevel = chapterCfg.tbLevel
     for _, nLevelID in ipairs(tbLevel) do
         if DLC_Chapter.IsPlot(nLevelID) then
             local tbLevelCfg = DLCLevel.Get(nLevelID)
             if Condition.Check(tbLevelCfg.tbCondition) and tbLevelCfg:IsFirstPass() then
                 RedPoint.SetRedNum(RedPointType.PlotLevel, 1, string.format('%d-%d', chapterCfg.nID, tbLevelCfg.nID))
             end
         end
     end
end

---获取当前章节配置
function DLC_Chapter.GetCurrentChapterCfg()
    return DLC_Chapter.tbChapter[var.nChapterID]
end

---获取章节星级信息 星级总数 获得星级数
---@param nChapterID number 章节ID
function DLC_Chapter.GetChapterStarInfo(nChapterID)
    local nChapterID = nChapterID or var.nChapterID
    local tbCfg = DLC_Chapter.GetChapterCfg(nChapterID)
    if not tbCfg then return 999, 0 end
    local nStarNum = 0
    local nGetStarNum = 0
    for _, nLevelID in ipairs(tbCfg.tbLevel or {}) do
        local tbLevelCfg = DLCLevel.Get(nLevelID)
        local n = tbLevelCfg and #tbLevelCfg.tbStarCondition or 0
        if tbLevelCfg and n > 0 then
            nStarNum = nStarNum + #tbLevelCfg.tbStarCondition
            nGetStarNum = nGetStarNum + tbLevelCfg:CountGotStar()
        end
    end
    return nStarNum , nGetStarNum
end

function DLC_Chapter.GetProceedLevel(nChapterID)
    local chapterCfg = DLC_Chapter.GetChapterCfg(nChapterID)
    if not chapterCfg then return nil end

    local nLastLevelId, index = nil, 0
    for _, nLevelID in ipairs(chapterCfg.tbLevelBranch) do
        nLevelID = type(nLevelID) == 'table' and nLevelID[1] or nLevelID
        local tbLevelCfg = DLCLevel.Get(nLevelID)
        if not DLC_Chapter.IsPlot(nLevelID) then index = index + 1 end
        if tbLevelCfg and tbLevelCfg:GetPassTime() <= 0 then
            return tbLevelCfg.nID, index
        end
        nLastLevelId = nLevelID
    end
    return nLastLevelId, index
end

function DLC_Chapter.Load()
    DLC_Chapter.tbChapter = {}
    local tbFile = LoadCsv("dlc/dlc1/chapter/chapter.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nID           = tonumber(tbLine.ID) or 0
        local tbInfo        = {
            nID         = nID,
            tbLevel     = Eval(tbLine.Level) or {},
            tbCondition = Eval(tbLine.Condition) or {},
            tbStarAward = Eval(tbLine.StarAward) or {},
            tbLevelBranch = Eval(tbLine.LevelSort) or {},
            nPicture    = tonumber(tbLine.Picture),
        };
        local Coverage = tonumber(tbLine.Coverage)

        if CheckCoverage(Coverage) then
            local tbTime = Eval(tbLine.OpenTime)
            tbInfo.OpenTime = ParseTime(tbTime[1], tbInfo, "CloseTime")
            tbInfo.CloseTime = ParseTime(tbTime[2], tbInfo, "CloseTime")
            DLC_Chapter.tbChapter[nID] = tbInfo
        end    
    end

    print('load dlc/dlc1/chapter/chapter.txt')
end




--[[
        //数据请求
]]



---数据请求类型
DLC_Chapter.REQ_ENTER_LEVEL         = 'DLC_Chapter_EnterLevel'
DLC_Chapter.REQ_LEVEL_SETTLEMENT    = 'DLC_Chapter_LevelSettlement'
DLC_Chapter.REQ_LEVEL_FAIL          = 'DLC_Chapter_LevelFail'
DLC_Chapter.REQ_GET_STAR_AWARDC     = 'DLC_Chapter_STAR_AWARD'

--[[
        请求进入关卡
]]
function DLC_Chapter.Req_EnterLevel(nLevelID)
    local tbCfg = DLCLevel.Get(nLevelID)
    if not tbCfg then return end
    ---体力检查
    if tbCfg.tbConsumeVigor and #tbCfg.tbConsumeVigor > 1 and  (not Cash.CheckMoney(Cash.MoneyType_Vigour, tbCfg.tbConsumeVigor[1] + tbCfg.tbConsumeVigor[2])) then
        return
    end

    local tbLog = {}
    tbLog['LevelEnter'] = LaunchLog.LogLevelEnter(12, DLC_Chapter.GetLevelID())

    -- 是否开启
    local cmd = {
        nID = nLevelID,
        nTeamID = Formation.GetCurLineupIndex(),
        tbLog = tbLog,
        nMultiple = Launch.GetMultiple(),
    }

    me:CallGS(DLC_Chapter.REQ_ENTER_LEVEL, json.encode(cmd))
end

---注册进入关卡的回调
s2c.Register(DLC_Chapter.REQ_ENTER_LEVEL, function(tbRet)
    if tbRet.sErr then
        UI.ShowTip(Text(tbRet.sErr))
        return
    end

    var.nSeed = tbRet.nSeed
    Launch.Response(DLC_Chapter.REQ_ENTER_LEVEL)
end
)

-- 领取星级奖励
function DLC_Chapter.Req_GetStarAward(nChapterID, nLevel)
    local cmd = {
        nChapterID = nChapterID,
        nIndex = nLevel
    }
    me:CallGS(DLC_Chapter.REQ_GET_STAR_AWARDC, json.encode(cmd))
end

---注册领取星级奖励的回调
s2c.Register(DLC_Chapter.REQ_GET_STAR_AWARDC, function(...)
    EventSystem.TriggerTarget(DLC_Chapter, DLC_Chapter.REQ_GET_STAR_AWARDC)
end
)

--[[
    ---请求结算关卡
]]
function DLC_Chapter.Req_LevelSettlement(nLevelID)
    local nStar = 0
    local pSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelStarTaskManager)
    if pSubSys then
        local Infos = pSubSys:GetStarTaskProperties()
        for i = 1, Infos:Length() do
            local pItem = Infos:Get(i)
            if pItem.bFinished then
                nStar = SetBits(nStar, 1, i-1, i-1)
            end
        end
    end

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
        nChapterID = DLC_Chapter.GetChapterID(),
        nSeed = var.nSeed,
        tbLog = DLC_Chapter.Log(nLevelID) or {},
        nTime = Launch.GetLatelyTime(),
        tbKill = tbKill,
        tbMonster = tbMonster,
        nStar = nStar,
    }
    Reconnect.Send_SettleInfo(DLC_Chapter.REQ_LEVEL_SETTLEMENT, cmd)
end
---注册结算回调
s2c.Register(DLC_Chapter.REQ_LEVEL_SETTLEMENT, function(tbAward)
    Launch.Response(DLC_Chapter.REQ_LEVEL_SETTLEMENT, tbAward)
end
)

---关卡失败
function DLC_Chapter.Req_LevelFail(nLevelID)
    local cmd = {
        nID = nLevelID,
        tbLog = DLC_Chapter.Log(nLevelID) or {}
    }
    me:CallGS(DLC_Chapter.REQ_LEVEL_FAIL, json.encode(cmd))
end

-----------------------------------------------------------------
DLC_Chapter.Load()
