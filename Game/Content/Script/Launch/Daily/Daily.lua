-- ========================================================
-- @File    : Daily.lua
-- @Brief   : 日常本
-- ========================================================

Daily = Daily or {tbChapterCfg = {}, tbCfg = {}, tbSupportDrop = {}, DefaultSuit = nil}

require "Launch.Daily.DailyChapter";
require "Launch.Daily.DailyActivity";

local var = {nSeed = 0 , nDifficult = 0, nID = nil, nChapterID = nil, nLevelID = nil, bReqEnter = nil}

function Daily.Clear()
    var.bReqEnter = nil
end

---是否在时间段
---@param nDay number 天数
function Daily.IsInTime(nDay)
    local nNow = GetTime()
    --获取当天的开始时间戳
    local tab = os.date("*t", nNow)
    local nWday = tab.wday - 1
    if nWday == 0 then nWday = 7 end
    if nWday == 1 and tab.hour < 4 then 
        nWday = 8
    end
    tab.hour = 4
    tab.min = 0
    tab.sec = 0
    local s = os.time(tab) 

    if nWday > nDay then
        s = s - (nWday - nDay) * 86400
    else
        s = s + (nDay - nWday) * 86400
    end
    local e = s + 86400
    return IsInTime(s, e, nNow)
end

---是否在开放时间段
function Daily.CheckOpen(tbOpenDay)
    for _, nDay in ipairs(tbOpenDay) do 
        if Daily.IsInTime(nDay) then
           
            return true
        end
    end
    return false
end

--检查是否限时开放
function Daily.IsInActivityOpenTime(tbActivity)
    local curTime = GetTime()
    for _,activityInfo in pairs(tbActivity or {}) do
        if #activityInfo == 3 and activityInfo[3] == 3 and  ParseTime(activityInfo[1]) < curTime and ParseTime(activityInfo[2]) > curTime then
            return true
        end
    end
    return false
end

---显示章节条件提示
---@param cfg DailyTemplateLogic
function Daily.ShowTip(cfg)
    local sTip = cfg:GetConditionStr()
    if sTip then
        return UI.ShowTip(Text(sTip))
    end
    UI.ShowTip(cfg:GetOpenDayStr())
end

---获取当前的副本类型ID
function Daily.GetID()
    return var.nID
end

---设置选择的ID
function Daily.SetID(nID)
    var.nID = nID
end

---设置选择的章节ID
function Daily.SetChapterID(nID)
    var.nChapterID = nID
end

---获取选择的章节ID
function Daily.GetChapterID()
    return var.nChapterID
end

---设置选择的关卡ID
---@param nID number 每日关卡ID
function Daily.SetLevelID(nID)
    var.nLevelID = nID
end

---获取选择的关卡ID
function Daily.GetLevelID()
    return var.nLevelID
end

---获取下一关ID
function Daily.GetNextLevelID()
    local tbCfg = DailyLevel.Get(var.nLevelID)
    if not tbCfg then return var.nLevelID end
    if tbCfg.nNextID == 0 then return var.nLevelID end
    return tbCfg.nNextID
end

---获取日常配置
function Daily.GetCfg()
    return Daily.tbCfg
end

function Daily.GetCfgByID(nID)
    return Daily.tbCfg[nID]
end

---获取日常章节配置
function Daily.GetChapterByID(nID)
    return DailyChapter.Get(1, nID)
end

function Daily.GetChapterCfg(nDifficult)
    return DailyChapter.GetChaptersByDifficult(nDifficult)
end

---GM指令 开放所有的曜日本
function Daily.GMOpenDaily()
    for _, Cfg in pairs(Daily.tbCfg) do
        Cfg.tbOpenDay = {1,2,3,4,5,6,7}
    end

    for _, ChapterCfg in pairs(DailyChapter.tbChapter) do
        for __, Cfg in pairs(ChapterCfg) do
            Cfg.tbOpenDay = {1,2,3,4,5,6,7}
        end
    end
end

---检查指定本是否开放
function Daily.CheckOpenByID(ID)
    if not ID then return false end
    local tbCfg = Daily.GetCfgByID(ID)
    return tbCfg and tbCfg:IsOpen()
end
---如果满足条件就打开指定本 不满足弹出提示
function Daily.OpenByID(ID)
    if not ID then return end
    local tbCfg = Daily.GetCfgByID(ID)
    if not tbCfg then return end

    if not Condition.Check(tbCfg.tbCondition) then
        UI.ShowMessage(Text("ui.LevelNotUnlock"))
        return
    end

    if Daily.IsInActivityOpenTime(tbCfg.tbActivity) or Daily.CheckOpen(tbCfg.tbOpenDay or {}) then
        if Launch.GetType() ~= LaunchType.DAILY then
            Launch.SetType(LaunchType.DAILY)
        end
        UI.Open("DungeonsSmap", ID)
    else
        UI.ShowMessage(Text("ui.LevelNotOpen"))
    end
end

-- 检查是否全通关
function Daily.CheckPassAll(ID)
    local tbCfg = Daily.GetCfgByID(ID)
    for nIdx, nChapterID in ipairs(tbCfg.tbChapter or {}) do
        local cfg = DailyChapter.Get(1, nChapterID)
        for _, levelId in ipairs(cfg.tbLevel) do
            local levelConf = DailyLevel.Get(levelId)
            if levelConf and not levelConf:IsPass() then
                return false
            end
        end
    end
    return true
end

---@class DailyTemplateLogic 日常本逻辑
local DailyTemplateLogic = {
    ---是否开放
    IsOpen = function(self)
        ---判断条件
        local bUnLock, _ = Condition.Check(self.tbCondition)
        if not bUnLock then return false end
        return Daily.IsInActivityOpenTime(self.tbActivity) or  Daily.CheckOpen(self.tbOpenDay or {})
    end,

    ---获取开放日期信息
    GetOpenDayStr = function(self)
        if #self.tbOpenDay >= 7 then
            return Text("ui.DailyOpenTimeAll")
        end

        if Daily.IsInActivityOpenTime(self.tbActivity) then
            return Text("ui.DailyOpenTimeAll")
        end

        local str = ''
        for _, n in ipairs(self.tbOpenDay) do
            str = str .. Text('ui.TxtNum' .. n) or ""
        end
        return string.format(Text('ui.TxtDailyOpenTime'), str)
    end,

    GetConditionStr = function(self)
        local bUnLock, tbTip = Condition.Check(self.tbCondition)
        if not bUnLock then return tbTip[1] or '' end
    end,
}


----------------------配置--------------------------

function Daily.LoadCfg()
    local tbFile = LoadCsv('daily/daily.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nID           = tonumber(tbLine.ID) or 0;
        local tbInfo = {
                Logic = DailyTemplateLogic,

                nID             = nID,
                tbChapter       = Eval(tbLine.Chapter) or {},
                tbOpenDay       = Eval(tbLine.OpenDay) or {},
                tbCondition      = Eval(tbLine.Condition) or {},
                sName           = 'chapter.daily_'.. nID,
                nBg             = tonumber(tbLine.Bg) or 0,
                tbActivity      = nil, ---客户端获取服务端活动信息
                nEntryBg        = tonumber(tbLine.EntryBg) or 0,
                I18N            = tbLine.I18N,
                Tips            = tbLine.Tips,
                Introduction    = tbLine.Introduction,
            }

        setmetatable(tbInfo, {
            __index = function(tb, key)
                local v = rawget(tb, key);
                return v or tb.Logic[key];
            end
        });

        Daily.tbCfg[nID] = tbInfo
    end
    print('load  daily/daily.txt')
end

function Daily.LoadSupportCfg()
    local tbFile = LoadCsv('daily/support_drop.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nSuitId = tonumber(tbLine.SuitId) or 0;
        if nSuitId > 0 then
            local tbInfo = {
                nSuitId         = nSuitId,
                }
            Daily.tbSupportDrop[nSuitId] = tbInfo
            if not Daily.DefaultSuit then
                Daily.DefaultSuit = nSuitId
            end
        end
    end
end

Daily.LoadCfg()
Daily.LoadSupportCfg()

---------------------数据请求----------------------------
--------------------------------------------------------

---数据请求类型
Daily.REQ_GET_ACTIVITY_INFO   = 'Daily_GetActivityInfo'
Daily.REQ_ENTER_LEVEL         = 'Daily_EnterLevel'
Daily.REQ_LEVEL_SETTLEMENT    = 'Daily_LevelSettlement'  
Daily.REQ_LEVEL_FAIL          = 'Daily_LevelFail'
Daily.REQ_Set_Select_Suit     = 'Daily_SetSelectSuit'
Daily.REQ_Get_Guarantee_Reward = 'Daily_GetGuaranteeReward'

---关卡失败
function Daily.Req_LevelFail(nLevelID, nReason)
    local cmd = {
        nID = nLevelID,
        tbLog = Daily.Log(nLevelID) or {}
    }
    me:CallGS(Daily.REQ_LEVEL_FAIL, json.encode(cmd))
end

---请求活动信息
function Daily.Req_GetActivityInfo()
    if me then
        me:CallGS(Daily.REQ_GET_ACTIVITY_INFO, {})
    end
end

---活动信息返回
s2c.Register(Daily.REQ_GET_ACTIVITY_INFO, function(tbInfo)
    print('daily activity :', json.encode(tbInfo))
    if tbInfo then
        for nID, tbActivity in pairs(tbInfo) do
            if Daily.tbCfg[nID] then
                --Dump(tbActivity)
                Daily.tbCfg[nID].tbActivity = tbActivity--Eval(json.encode(tbActivity))
                --Dump(Daily.tbCfg[nID].tbActivity)
            end
        end
    end
end
)

---是否可以进入
---@param nID Integer 类型ID
---@param nDifficult Integer 难度ID
---@param nChapterID Integer 章节ID
---@param nLevelID Integer 关卡ID
function Daily.IsCanEnter(nID, nDifficult, nChapterID, nLevelID)
    local cfg = Daily.GetCfgByID(nID)
    if cfg == nil then
        return false
    end

    local chapterCfg = DailyChapter.Get(nDifficult, nChapterID)
    if not chapterCfg then
        return false
    end

    if not Daily.IsInActivityOpenTime(cfg.tbActivity) then
        if not Daily.CheckOpen(cfg.tbOpenDay) then
            return false
        end

        if not Daily.CheckOpen(chapterCfg.tbOpenDay) then
            return false
        end
    end

    local levelCfg = DailyLevel.Get(nLevelID)
    if not levelCfg then
        return false
    end
    local bUnLock, _ = Condition.Check(levelCfg.tbCondition)
    if not bUnLock then
        return false
    end
    return true
end


---请求进入关卡
function Daily.Req_EnterLevel(nLevelID)
    local cfg = DailyLevel.Get(nLevelID)
    if not cfg then return end
    ---体力检查
    if cfg.tbConsumeVigor and #cfg.tbConsumeVigor > 1 and (not Cash.CheckMoney(Cash.MoneyType_Vigour, cfg.tbConsumeVigor[1] + cfg.tbConsumeVigor[2])) then
       return
    end

    if not var.nID or not var.nChapterID then
        return
    end

    
    -- 是否可以进入
    if not Daily.IsCanEnter(var.nID, 1, var.nChapterID, nLevelID) then
        return UI.ShowTip('tip.not_open')
    end
    
    local nLevelID = Daily.GetLevelID()
    local nMultiple = Launch.GetMultiple()
    local cfg = DailyLevel.Get(nLevelID)
    local nDifficult = cfg.nType == DailyLevel.TeachingLevelType and 1 or nLevelID % 10

    local sLoglevel = string.format('%s-%s-%s', nMultiple, nLevelID, nDifficult)
    local tbLog = LaunchLog.LogLevelEnter(2, sLoglevel)
    local cmd = {
        nID = var.nID,
        nChapterID = var.nChapterID,
        nLevelID = nLevelID,
        nTeamID = Formation.GetCurLineupIndex(),
        tbLog = tbLog,
        nMultiple = Launch.GetMultiple(),
    }
    
    if var.bReqEnter then
        return
    end
    
    var.bReqEnter = true
    me:CallGS(Daily.REQ_ENTER_LEVEL, json.encode(cmd))
    UI.ShowConnection()
end

---注册进入关卡的回调
s2c.Register(Daily.REQ_ENTER_LEVEL, function(tbRet)
    UI.CloseConnection()
    var.bReqEnter = nil
    if tbRet.sErr then
        UI.ShowTip(Text(tbRet.sErr))
        return
    end

    var.nSeed = tbRet.nSeed
    Launch.Response(Daily.REQ_ENTER_LEVEL)
end
)

---请求结算关卡
function Daily.Req_LevelSettlement(nLevelID)
    local tbKill = {}
    local TaskSubActor = UE4.ATaskSubActor.GetTaskSubActor(GetGameIns())
    local tbMonster = RikiLogic:GetMonsterData(TaskSubActor)
    if TaskSubActor  and TaskSubActor.GetAchievementData then
        local tbKillMonster = TaskSubActor:GetAchievementData()
        local tbKey = tbKillMonster:Keys()
        for i = 1, tbKey:Length() do
            local sName = tbKey:Get(i)
            tbKill[sName] = tbKillMonster:Find(tbKey:Get(i))
        end
    end

    local tbLog = Daily.Log(nLevelID)
    local cmd = {
        nID = nLevelID,
        nSeed = var.nSeed,
        tbKill = tbKill,
        tbLog = tbLog,
        tbMonster = tbMonster
    }
    Reconnect.Send_SettleInfo(Daily.REQ_LEVEL_SETTLEMENT, cmd)
    UI.ShowConnection()
end

---注册结算回调
s2c.Register(Daily.REQ_LEVEL_SETTLEMENT, function(tbAward)
    UI.CloseConnection()
    Launch.Response(Daily.REQ_LEVEL_SETTLEMENT, tbAward)
end
)

---收集日志
function Daily.Log(nLevelID)
    local tbLog = {}
    local extend = nil
    local levelCfg = DailyLevel.Get(nLevelID)
    if levelCfg and levelCfg.nType then
        local tbAct = DailyActivity.GetOpenActivity(levelCfg.nType);
        if tbAct and #tbAct > 0 then
            extend = ''
            for i,v in ipairs(tbAct) do
                if i ~= #tbAct then
                    extend = extend..v..'-'
                else
                    extend = extend..v
                end
            end
        end
    end
    
    tbLog['LevelFinish'] = LaunchLog.LogLevel(2,extend)
    tbLog['FightRecont'] = LaunchLog.LogFightRecont()
    tbLog['FightHistory'] = LaunchLog.LogFightHistory(2,extend)
    tbLog['LevelPerformance'] = LaunchLog.LogPerformance()
    return tbLog
end

---登录获取活动信息
EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    if bReconnected then return end
    Daily.Req_GetActivityInfo()
end)

function Daily.SetSelectSuit(nSuit, nLevelID, InCallback)
    local tbParam = {
        Suit = nSuit,
        Type = nLevelID
    }
    Daily.RSP_SetSelectSuit = InCallback
    me:CallGS(Daily.REQ_Set_Select_Suit, json.encode(tbParam))
end

s2c.Register(Daily.REQ_Set_Select_Suit, function(InParam)
    if Daily.RSP_SetSelectSuit then
        Daily.RSP_SetSelectSuit(InParam)
        Daily.RSP_SetSelectSuit = nil
    end
end)

function Daily.GetGuaranteeReward(nSuit, nLevelID, InCallback)
    local tbParam = {
        Suit = nSuit,
        Type = nLevelID
    }
    Daily.RSP_GuaranteeReward = InCallback
    me:CallGS(Daily.REQ_Get_Guarantee_Reward, json.encode(tbParam))
end

s2c.Register(Daily.REQ_Get_Guarantee_Reward, function(InParam)
    if Daily.RSP_GuaranteeReward then
        Daily.RSP_GuaranteeReward(InParam)
        Daily.RSP_GuaranteeReward = nil
    end
end)