-- ========================================================
-- @File    : Launch/Online/Online.lua
-- @Brief   : 联机关卡数据
-- ========================================================
require("DS_ProfileTest.Utils.DsCommonError")

Online = Online or {}

--数据变量
--group
Online.GroupId = 23
--taskid
Online.WeeklyPointTask = 1 --每周积分
Online.WeeklyAwardTask = 2 --每周积分奖励领取标记
Online.PreIdTask = 3 --创建房间时的玩法id
Online.JoinIdTask = 4 --进入游戏的玩法id
Online.VigorTask = 5 --体力开关
Online.LevelTask = 6 --进入游戏的关卡id
Online.EnterTimeTask = 7 --进入关卡的时间戳
Online.FightNumTask = 8 --联机战斗次数

Online.FirstPopTask = 20 --首次弹窗说明 预留10个 每个30 * 10  300个id
Online.FirstPopEndTask = 29

--str group
Online.Str_GroupId = 43
Online.RecentTask =1 --最近参战的玩家列表 

--编队id
Online.TeamId = 10

--编队允许上阵队员数量
Online.MaxTeammate = 1

--房间状态
Online.STATUS_INVALID = -1 --没在联机状态
Online.STATUS_OPEN = 0 --进入界面
Online.STATUS_READY = 1 --准备好了
Online.STATUS_ENTER = 2 --进入游戏 等待服务器下发 ds信息?
Online.STATUS_FIGHT = 3 --ds战斗中
Online.STATUS_END = 4 --ds战斗结束

--临时邀请列表 [pid] = GetTime()
Online.tbInviteList = {}
Online.InviteCD = 30

--近期列表
Online.tbRecentList = {}
Online.nRecentTime = 0 --一般不会变 cd时间10分钟
--推荐列表
Online.tbRecommendList = {}
Online.nRecommendTime = 0 --一般不会变 cd时间30秒

--收到的邀请列表
Online.tbReceiveInviteList = {}

--一场战斗重连询问时间
Online.Req_Reconnect_Time = 10 * 60  --10分钟

---房间玩家状态
Online.Player_State_Empty = 0  --空闲
Online.Player_State_Change = 1 --换装
Online.Player_State_Ready = 2 --准备
Online.Player_State_Fight = 3 --战斗
Online.Player_State_End = 4 --结算

---检查准备时间
Online.Ready_Kick_Time = 15

---临时变量{nOnlineId online.tx配置信息id, nState状态STATUS), 
-- tbCaptain玩家队长标记, tbStateFlag玩家状态, tbAwardList掉落缓存, bMatch房间匹配标记
-- nReadyTime队员全部准备时间戳, tbBuffInfo 增益buff信息, nPollingWeek 轮换第几周, 
-- nPopId 记录当前玩法id(防止界面返回报错), nPickNum 上阵角色}
local var = { nOnlineId = 0, nState = -1, tbCaptain = {true}, tbStateFlag = {0}, tbAwardList = nil, 
bMatch = false, nReadyTime =0, tbBuffInfo = nil, nPollingWeek = nil, nPopId = 0, tbPickCard = nil}

--- 禁止自动重连
Online.AllowAutoConnection = true

-- 当前是否主动放弃关卡
Online.bGiveUp = false

---App background handle
Online.willDeactivateHandle = nil
---App foreground handle
Online.hasReactivatedHandle = nil
Online.EnterBackgroundTime = 0

---清空联机关卡
function Online.ClearAll()
    Online.SetOnlineId(0)
    Online.SetPickCard(nil)
    -- print("Online.ClearAll  Online.ClearAll Online.ClearAll Online.ClearAll", debug.traceback())
    Online.SetOnlineState(Online.STATUS_INVALID)
    Online.ClearPlayerState()
    Online.SetBuffInfo(nil)
    EventSystem.Remove(Online.nAttChangeHandle)
    
    if Online.willDeactivateHandle then
        EventSystem.Remove(Online.willDeactivateHandle)
        Online.willDeactivateHandle = nil
    end
    if Online.hasReactivatedHandle then
        EventSystem.Remove(Online.hasReactivatedHandle)
        Online.hasReactivatedHandle = nil
    end
    Online.EnterBackgroundTime = 0
end

function Online.ClearPlayerState()
    var.tbCaptain = {true}
    var.tbStateFlag = {0}
end

function Online.SetOnlineLevelId(LevelId)
    var.nLevelId = LevelId
end

function Online.GetOnlineLevelId()
    return var.nLevelId
end

---保存玩法ID
function Online.SetOnlineId(OnlineId)
    var.nOnlineId = OnlineId
    if OnlineId > 0 then
        var.nPopId = OnlineId
    end
end

---获取玩法ID
function Online.GetOnlineId()
    return var.nOnlineId
end

--保存弹出ID
function Online.GetPopId()
    return var.nPopId
end

---保存玩法状态
function Online.SetOnlineState(nState)
    var.nState = nState

    DSAutoTestAgent.SetOnlineState(nState)
end

---获取玩法状态
function Online.GetOnlineState()
    return var.nState
end

--获取房间队长状态
function Online.GetCaptain()
    return var.tbCaptain
end

--获取房间准备状态
function Online.GetStateFlag()
    return var.tbStateFlag
end

--获取房间匹配状态
function Online.GetMatchState()
    return var.bMatch
end

--设置房间匹配状态
function Online.SetMatchState(bMatch)
    var.bMatch = bMatch
end

--结算获取掉落物品奖励
function Online.GetDropList()
    return var.tbAwardList
end

--缓存掉落物品奖励
function Online.SetDropList(tbAward)
    var.tbAwardList = tbAward
end

--监控掉落关卡变化
function Online.DoChangeDropList()
    Online.SetDropList(Online.GetDropAwardList())
    if Online.nAttChangeHandle then
        EventSystem.Remove(Online.nAttChangeHandle)
    end

    Online.nAttChangeHandle = EventSystem.On(Event.CustomAttr, function(gid, sid, value)
        if gid ==Online.GroupId and sid == Online.LevelTask and value > 0 then
            Online.SetDropList(Online.GetDropAwardList())
        end

        if gid ==OnlineLevel.GID and sid == Online.GetLevelId() and value ~= "" then
            Online.SetDropList(Online.GetDropAwardList())
        end
    end)
end

--获取全员准备标记
function Online.GetReadyTime()
    return var.nReadyTime
end

--设置全员准备时间
function Online.SetReadyTime(nTime)
    var.nReadyTime = nTime
end

--获取当前Buff信息
function Online.GetBuffInfo()
    return var.tbBuffInfo
end

--设置Buff信息
function Online.SetBuffInfo(tbInfo)
    var.tbBuffInfo = tbInfo
end

--获取当前房间的轮换周
function Online.GetPollingWeek()
    return var.nPollingWeek
end

--设置当前房间的轮换周
function Online.SetPollingWeek(nWeek)
    var.nPollingWeek = nWeek
end

--获取当前房间的上阵增值角色
function Online.GetPickCard()
    return var.tbPickCard
end

--设置当前房间的上阵增值角色
function Online.SetPickCard(tbList)
    var.tbPickCard = tbList
end
-----------------------
--检查邀请
function Online.CheckSetInvite(nPid)
    local tbId = Online.GetRoomOthers()
    if tbId and tbId[nPid] then
        UI.ShowTip("error.711")
        return
    end

    if Online.CheckInviteState(nPid) then
        Online.tbInviteList[nPid] = GetTime() + Online.InviteCD
        return true
    end
end

function Online.CheckInviteState(nPid)
    if not nPid then
        return 
    end

    local nTime = Online.tbInviteList[nPid]
    if not nTime or nTime < GetTime() then
        return true
    end
end

--获取房间队员id
function Online.GetRoomOthers()
    local tbPlayerId = {}
    for i=1,2 do
        local tbPlayerInfo = UE4.UAccount.Find(i, true)
        if tbPlayerInfo and tbPlayerInfo:Id() > 0  then
            tbPlayerId[tbPlayerInfo:Id()] = i
        end
    end

    return tbPlayerId
end

---处理收到邀请信息
--添加新的邀请
---@param tbParam table   {邀请者名字，其他信息(TArray<uint64> 顺序:房间id,玩法id,角色id,头像,头像框,等级)}
function Online.AddNewInfo(tbParam)
    if not tbParam or #tbParam < 2 then return end

    --没有解锁，无法收到
    if not FunctionRouter.IsOpenById(FunctionType.TimeActivitie) then
        return
    end

    if not Online.tbReceiveInviteList then
        Online.tbReceiveInviteList = {}
    end

    local tArray = tbParam[2]
    if not tArray or tArray:Length() < 5 then
        return
    end

    local tbInfo = {}
    table.insert(tbInfo, tbParam[1])
    for i = 1, tArray:Length() do
        table.insert(tbInfo, tArray:Get(i))
    end

    local tbConf = Online.GetConfig(tbInfo[3])
    if not Online.CheckOpen(tbConf) then
        return
    end

    --黑名单不显示
    if Friend.BlacklistCheck(tbInfo[4]) then
        return
    end

    --检查编队
    Online.CheckFormation(Online.TeamId)

    if #Online.tbReceiveInviteList > 0 then
        local nFindIdx = 0
        for i,v in ipairs(Online.tbReceiveInviteList) do
            if v[2] == tbInfo[2] and v[4] == tbInfo[4] then
                nFindIdx = i
                break
            end
        end

        if nFindIdx == 0 then 
            table.insert(Online.tbReceiveInviteList, tbInfo)
        else
            local tbFindInfo = Online.tbReceiveInviteList[nFindIdx]
            if tbFindInfo and tbFindInfo[8] and tbFindInfo[8] - GetTime() <= 0 then
                table.remove(Online.tbReceiveInviteList, nFindIdx)
                table.insert(Online.tbReceiveInviteList, tbInfo)
            end
        end
    else
        table.insert(Online.tbReceiveInviteList, tbInfo)
    end
    --- tbInfo {邀请者名字,房间id,玩法id,角色id,头像,头像框,等级}
end

---获取当前需要显示的邀请
function Online.GetCurInviteInfo()
    if not Online.tbReceiveInviteList or #Online.tbReceiveInviteList == 0 then
        return
    end

    --第一次获取显示，添加时间
    local tbGetInfo = Online.tbReceiveInviteList[1]
    if tbGetInfo and not tbGetInfo[8] then
       tbGetInfo[8] = GetTime() + Online.InviteCD
    end

    return tbGetInfo
end

--检查当前是否已经在邀请的房间中
function Online:CheckRoomPlayer()
    if not Online.tbReceiveInviteList or #Online.tbReceiveInviteList == 0 then return end

    local tbId = Online.GetRoomOthers()
    local nLen = #Online.tbReceiveInviteList
    local bNext = false
    for i=nLen, 1, -1 do
        local tbInfo = Online.tbReceiveInviteList[i]
        if tbInfo and tbId[tbInfo[4]] then
            table.remove(Online.tbReceiveInviteList, i)

            if 1 == 1 then --当前显示的就是已经进入的房间
                bNext = true
            end
        end
    end

    return bNext
end

---切换下一个邀请
function Online.DoNextInviteInfo()
    if not Online.tbReceiveInviteList or #Online.tbReceiveInviteList == 0 then
        return
    end

    table.remove(Online.tbReceiveInviteList, 1)
end

---清空所有邀请
function Online.ClearInviteInfo()
    Online.tbReceiveInviteList = {}
    local sUI = UI.GetUI("OnlineInvite")
    if sUI then
        sUI:ClearAndClose()
    end
end

--显示邀请界面
function Online.CheckAndShowInviteUI(bSpe)
    if not Online.tbReceiveInviteList or #Online.tbReceiveInviteList == 0 then
        return
    end

    if not UI.IsOpen("OnlineInvite") then
        UI.Open("OnlineInvite", nil, bSpe)
    end
end

--获取玩家状态文字
function Online.GetStateText(nFlag)
    nFlag = nFlag or Online.Player_State_Empty
    if nFlag == Online.Player_State_Empty then
        return Text("TxtOnlinePrepare")
    elseif nFlag == Online.Player_State_Change then
        return Text("TxtOnlineChange")
    elseif nFlag == Online.Player_State_Ready then
        return Text("TxtOnlineCompleted")
    elseif nFlag == Online.Player_State_Fight then
        return Text("TxtOnlineFightFlag")
    elseif nFlag == Online.Player_State_End then
        return Text("TxtOnlineEnd")
    end

    return ""
end

---是否队员都准备完毕
function Online.CheckMemberAllReady()
    local tbConfig = Online.GetConfig(Online.GetPreId())
    if not tbConfig then return end

    local nLen = #var.tbStateFlag
    if nLen ~= tbConfig.nMaxPlayer then return end

    local bAllReady = true
    for i=1,#var.tbStateFlag do
        if var.tbStateFlag[i] ~= Online.Player_State_Ready and not var.tbCaptain[i] then
            bAllReady = false
            break
        end
    end

    return bAllReady
end

--检查是否询问 踢队长
function Online.CheckForKickCaptain()
    if not Online.CheckMemberAllReady() then return end
    local nTime = Online.GetReadyTime()
    if nTime <= 0 then return end

    local nLeftTime = math.floor(GetTime() - nTime - Online.Ready_Kick_Time)
    if nLeftTime < 0 then
        return
    end

    local tbList = {}
    for i=1,#var.tbCaptain do
        local tbPlayerInfo = UE4.UAccount.Find(i-1, true)
        if tbPlayerInfo and tbPlayerInfo:Id() > 0  then
            tbList[i] = tbPlayerInfo:Id()
        end
    end


    local nKickId = tbList[2]
    if var.tbCaptain[1] then
        nKickId = me:Id()
    else
        if #tbList < 3 then return end
        local nOtherId = tbList[3]
        if var.tbCaptain[3] then
           nOtherId = tbList[2]
           nKickId = tbList[3]
        end

        if me:Id() > nOtherId and nLeftTime < 1 then
            return
        elseif me:Id() < nOtherId and nLeftTime < 2 then
            return
        end
    end

    Online.SetReadyTime(0)
    if nKickId <= 0 then return end    

    Online.ExitRoom(nKickId)
end

-------------------
--初始化
function Online.Init()
    Online.LoadConfig()
    Online.LoadRewardConfig()
end

---加载配置
function Online.LoadConfig()
    Online.tbOnlineList = {}
    Online.tbResetLevelList = {}

    local AddResetLevelList = function(nId)
            if type(nId) ~= "number" then return end

            for i,v in ipairs(Online.tbResetLevelList) do
                if v == nId then
                    return
                elseif nId < v then
                    table.insert(Online.tbResetLevelList, i, nId)
                    return
                end
            end

            table.insert(Online.tbResetLevelList, nId)
        end

    local tbConfig = LoadCsv("online/online.txt", 1)
    for _, tbLine in ipairs(tbConfig) do
        local nId = tonumber(tbLine.Id) or 0
        if nId > 0 then
            local tbInfo = {
                nId = nId,
                sName = tbLine.Name, --玩法名字
                tbDate = Eval(tbLine.Date),
                tbOpenHour        = Eval(tbLine.OpenHour) or {},
                tbCondition         = Eval(tbLine.Condition) or {},
                nConsumeVigor = tonumber(tbLine.ConsumeVigor) or 0,
                nReturnVigor = tonumber(tbLine.ReturnVigor) or 0,
                nMaxPlayer = tonumber(tbLine.MaxPlayer) or 0,

                tbResetLevel = Eval(tbLine.ResetLevel) or {},
                tbBuff = Eval(tbLine.Buff) or {},
                tbGainRole = Eval(tbLine.GainRole) or {},
                nGainRoleRate = tonumber(tbLine.GainRoleRate) or 0,
                nBg = tonumber(tbLine.BG),
                nIcon = tonumber(tbLine.Icon),
                sIntro = tbLine.Intro,
                nHelpImgId = tonumber(tbLine.HelpImgId) or 0,
            }

            for _,tbLevel in ipairs(tbInfo.tbResetLevel) do
                for _,v in ipairs(tbLevel or {}) do
                    AddResetLevelList(v)
                end
            end

            tbInfo.nStartTime  = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), tbInfo, "nStartTime")
            tbInfo.nEndTime    = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), tbInfo, "nEndTime")

            Online.tbOnlineList[nId] = tbInfo
        end
    end
end

---加载配置
function Online.LoadRewardConfig()
    Online.tbAwards = {}
    Online.nMaxPoint = 0
    local tbConfig = LoadCsv("online/reward.txt", 1)
    for _, tbLine in ipairs(tbConfig) do
        local nId = tonumber(tbLine.Id) or 0
        if nId > 0  then
            local tbInfo = {
                nId = nId,
                nPoint    = tonumber(tbLine.Point) or 0,
                tbRewards   = Eval(tbLine.Rewards),
            }
            Online.tbAwards[nId] = tbInfo
            if Online.nMaxPoint  < tbInfo.nPoint then
                Online.nMaxPoint = tbInfo.nPoint
            end
        end
    end
end

--获取玩法配置信息
function Online.GetConfig(nId)
    if not nId then return end

    return Online.tbOnlineList[nId]
end

--获取地图类型列表
function Online.GetResetLevelList()
    return Online.tbResetLevelList
end

--gm 开启玩法
function Online.GmOpenOne(nId)
    if nId == 0 then
        Online.LoadConfig()
        UI.ShowTip("执行成功")
        return true
    end

    local tbConfig = Online.GetConfig(nId)
    if not tbConfig then
        return
    end

    tbConfig.nStartTime = GetTime() - 3600
    tbConfig.nEndTime = -1
    tbConfig.tbCondition = {}
    tbConfig.tbOpenHour = {}
    tbConfig.tbDate = {1,2,3,4,5,6,7}
    return true
end

--计算轮换到第几周了
function Online.GetResetWeek(tbOnline)
    local tbStartWeek = os.date("*t", tbOnline.nStartTime)
    local nMon = tbStartWeek.wday - 1
    if nMon == 0 then
        tbStartWeek.day = tbStartWeek.day - 6
    elseif nMon > 1 then
        tbStartWeek.day = tbStartWeek.day - nMon + 1
    end

    tbStartWeek.hour = Activityface.DailyTime
    tbStartWeek.min = 0
    tbStartWeek.sec = 0

    local nStartTime = os.time(tbStartWeek)
    local nEndTime = GetTime()

    local nDissDay = (nEndTime - nStartTime) / (24 * 3600)
    return math.floor(nDissDay / 7) + 1
end

--获取当前周的轮换信息
function Online.GetWeekRotation(tbConfig)
    if not tbConfig then return end

    local nWeek = Online.GetPollingWeek() or Online.GetResetWeek(tbConfig)
    local tbLevels = nil
    local nLevelNum = tbConfig.tbResetLevel and #tbConfig.tbResetLevel or 0
    if nLevelNum == 0 then return end
    local nIdx = math.floor((nWeek - 1) % nLevelNum)  +1
    tbLevels = tbConfig.tbResetLevel[nIdx]

    if not tbLevels or #tbLevels == 0 then return end

    return tbLevels
end

--获取当前周的轮换关卡信息
function Online.GetRotationLevels()
    local tbConfig = Online.GetConfig(Online.GetOnlineId())
    if not tbConfig then return end

    local tbLevels = Online.GetWeekRotation(tbConfig)
    local findLevelFunc = function(nLevelType, tbLevel)
        if not nLevelType or not tbLevel then return end

        for i,v in ipairs(tbLevel) do
            if v == nLevelType then
                return true
            end
        end
    end

    local tbLevelInfo = {}
    local tbAllList = Online.GetResetLevelList()
    for i,v in ipairs(tbAllList) do
        local tbLevel = OnlineLevel.GetConfigByMapType(v)
        if tbLevel then
            table.insert(tbLevelInfo, {tbLevel[1].sLevelName,  tbLevel[1].nLevelIcon, not findLevelFunc(v, tbLevels)})
        end
    end

    -- local tbLevelInfo = {}
    -- for i,v in ipairs(tbLevels) do
    --     local tbLevel = OnlineLevel.GetConfigByMapType(v)
    --     if tbLevel then
    --         table.insert(tbLevelInfo, {tbLevel[1].sLevelName,  tbLevel[1].nLevelIcon})
    --     end
    -- end

    return tbLevelInfo
end

--获取当前轮换上阵角色
function Online.GetWeekGainRole(tbConfig)
    if not tbConfig then return end

    local nWeek = Online.GetPollingWeek() or Online.GetResetWeek(tbConfig)
    local tbInfos = nil
    local nNum = tbConfig.tbGainRole and #tbConfig.tbGainRole or 0
    if nNum == 0 then return end

    local nIdx = math.floor((nWeek - 1) % nNum)  +1
    tbInfos = tbConfig.tbGainRole[nIdx]

    if not tbInfos or #tbInfos == 0 then return end

    return tbInfos
end

--设置当前周的轮换Buff
--@tbParam 服务器下发更新buff和轮换周信息
function Online.SetWeekBuff(tbParam)
    if not tbParam then --本地构建
        local tbConfig = Online.GetConfig(Online.GetOnlineId())
        if not tbConfig then return end

        local nWeek = Online.GetResetWeek(tbConfig)
        Online.SetPollingWeek(nWeek)

        local nBuffNum = tbConfig.tbBuff and #tbConfig.tbBuff or 0
        if nBuffNum > 0 then
            nWeek = math.floor((nWeek - 1) % nBuffNum)+1

            Online.SetBuffInfo(tbConfig.tbBuff[nWeek])
        end
        return
    end

    local tbInfo = {}
    local nLen = tbParam:Length()
    local nWeekIdx = 1
    if nLen >= 4 then
        for i = 1, 4 do
            table.insert(tbInfo, tbParam:Get(i))
        end
        Online.SetBuffInfo(tbInfo)
        nWeekIdx = 5
    end

    if nLen >= nWeekIdx then
        Online.SetPollingWeek(tbParam:Get(nWeekIdx))
    end
end

--检查是否有关卡信息
function Online.CheckOnlineLevel(nOnlineId)
    if not nOnlineId then return end

    local tbConfig = Online.GetConfig(nOnlineId)
    if not tbConfig then return end

    if not tbConfig.tbResetLevel or #tbConfig.tbResetLevel == 0 then
        return
    end

    local tbLevels = Online.GetWeekRotation(tbConfig)
    if not tbLevels then return end

   local nRand = math.random(#tbLevels);
   local tbLevelList = OnlineLevel.GetConfigByMapType(tbLevels[nRand])
   if not tbLevelList then return end

    return #tbLevelList > 0
end

--获取关卡内所有掉落
function Online.GetAllLevelDrop(nOnlineId)
    if not nOnlineId then return end

    local tbConfig = Online.GetConfig(nOnlineId)
    if not tbConfig then return end

    if not tbConfig.tbResetLevel or #tbConfig.tbResetLevel == 0 then
        return
    end

    local tbLevels = Online.GetWeekRotation(tbConfig)
    if not tbLevels then return end

    local AddFunc = function(tbAward, tbMap, tbSave)
        if not tbAward then return end
        for _, tbInfo in pairs(tbAward) do
            local sId = string.format("%d-%d-%d-%d", tbInfo[1], tbInfo[2], tbInfo[3], tbInfo[4])
            if not tbMap[sId] then
                table.insert(tbSave, tbInfo)
                tbMap[sId] = true
            end
        end
    end

    local tbMapFirst = {}
    local tbMapData = {}
    local tbFirstList = {}
    local tbDropList = {}
    local tbRandomList = {}

    for _,mapType in ipairs(tbLevels) do
        local tbLevelList = OnlineLevel.GetConfigByMapType(mapType)
        if tbLevelList then
            for _,tbCfg in ipairs(tbLevelList) do
                if tbCfg and tbCfg.tbShowFirstAward then
                    AddFunc(tbCfg.tbShowFirstAward, tbMapFirst, tbFirstList)
                end
                if tbCfg and tbCfg.tbShowAward then
                    AddFunc(tbCfg.tbShowAward, tbMapData, tbDropList)
                end
                if tbCfg and tbCfg.tbShowRandomAward then
                    AddFunc(tbCfg.tbShowRandomAward, tbMapData, tbRandomList)
                end
            end
        end
    end

    return tbFirstList, tbDropList, tbRandomList
end

--获取奖励配置信息
function Online.GetAwardConfig()
    return Online.tbAwards
end

--判断奖励是否全部领取
function Online.CheckAllAward()
    if not Online.tbAwards then return true end

    for i,v in pairs(Online.tbAwards) do
        if not Online.GetWeeklyAward(v.nId) and Online.GetWeeklyPoint() >= v.nPoint  then
            return false
        end
    end

    return true
end

--根据积分获取对应奖励
function Online.GetPointAwardConfig(nId)
    if not nId then return end

    local tbAwards = Online.GetAwardConfig()
    if not tbAwards then return end

    return tbAwards[nId]
end

--判断是否获得了最高点数 以此判断是否需要消耗体力
function Online.CheckGetPoint()
    return Online.GetWeeklyPoint() >= Online.GetMaxPoint()
end

--获取当前最大积分
function Online.GetMaxPoint()
    return Online.nMaxPoint
end

--判断每周的时间
function Online.CheckWeekDay(tbConf, nDate)
    if not tbConf then return end
    
    if not tbConf.tbDate then return true end
    if #tbConf.tbDate == 0 then return true end

    if not nDate then
        local tab = os.date("*t", GetTime() - 4*3600)
        nDate = tab.wday - 1
        if nDate == 0 then nDate = 7 end
    elseif nDate <= 0 or nDate > 7 then
        return
    end

    for i,v in ipairs(tbConf.tbDate) do
        if v == nDate then
            return true
        end
    end
end

--判断当前玩法是否开放
function Online.CheckOpen(tbConf, bSkip)
    if not tbConf then return false, "tip.congif_err" end

    --- 活动开放时间
    if not IsInTime(tbConf.nStartTime, tbConf.nEndTime) then
        return false, "ui.TxtLockTime"
    end

    --每周开放日
    if not Online.CheckWeekDay(tbConf) then
        return false, "ui.TxtLockTime"
    end

    --每天开放时长
    if not bSkip and #tbConf.tbOpenHour > 0 then
        local bInHour = false
        local tbNow = os.date("*t", GetTime())
        for i,v in ipairs(tbConf.tbOpenHour) do
            if type(v) == "table" and #v >= 2 then
                local nPre = tonumber(v[1])
                local nEnd = tonumber(v[2])

                if nPre > nEnd then
                    nEnd = tonumber(v[1])
                    nPre = tonumber(v[2])
                end

                if tbNow.hour >= nPre and tbNow.hour < nEnd then
                    bInHour = true
                    break
                end
            end
        end

        if not bInHour then
            return false, "ui.TxtLockTime"
        end
    end

    -- 检测限制
    local bUnLock, tbDes = Condition.Check(tbConf.tbCondition)
    if not bUnLock then
        return false, tbDes[1] or "tip.not_open"
    end

    return true
end

--获取当前开放的玩法
function Online.GetAllOpenList()
    local tbList = {}
    for k,v in pairs(Online.tbOnlineList) do
        if Online.CheckOpen(v, true) then
            table.insert(tbList, v)
        end
    end

    return tbList
end

--匹配编队角色卡
function Online.MatchCard(tbLineup, tbParam)
    if not tbLineup or not tbParam then return end

    for _, member in pairs(tbLineup:GetMembers()) do
        local card = member:GetCard()
        if card and 1 == card:Genre() and tbParam[1] == card:Detail() and tbParam[2] == card:Particular() and 1 == card:Level() then
            return {card:Genre(),card:Detail(),card:Particular(),card:Level()}
        end
    end
end

--获取其他角色编队
function Online.GetOtherLineup(nIndex)
    local tbPlayerInfo = UE4.UAccount.Find(nIndex, true)
    if not tbPlayerInfo or tbPlayerInfo:Id() == 0 then 
        return
    end

    local tbLineup = nil
    local lineupsData = tbPlayerInfo:GetLineups()
    local LineupLogic = Formation.GetLineupLogic()
    for i = 1, lineupsData:Length() do
        local pLineup = lineupsData:Get(i)
        if pLineup.Index == Online.TeamId then
            tbLineup = LineupLogic.New(pLineup)
            local MemberLogic = tbLineup:GetMemberLogic()
            tbLineup.tbMember = {}
            local memsData = tbPlayerInfo:GetLineupMembers(pLineup.Index)
            for i = 1, memsData:Length() do
                tbLineup.tbMember[i-1] =  MemberLogic.New(i-1, memsData:Get(i))
            end
            break
        end
    end

    return tbLineup
end

--获取当前房间的所有阵容
function Online.CalculatePickCard()
    local  tbConfig = Online.GetConfig(Online.GetOnlineId())
    if not tbConfig then return end

    local tbLineup = Formation.GetLineup(Online.TeamId)
    if not tbLineup then return end

    local tbLineup1 = nil
    local tbLineup2 = nil
    if tbConfig.nMaxPlayer >= 2 then
        tbLineup1 = Online.GetOtherLineup(1)
    end
    if tbConfig.nMaxPlayer >= 3 then
        tbLineup2 = Online.GetOtherLineup(2)
    end

    local findCard = function(tbLineupList, tbList, tbParam)
        if not tbLineupList or not tbList or not tbParam then return end

        for i,tbInfo in ipairs(tbLineupList) do
            local tbRet = Online.MatchCard(tbInfo, tbParam)
            if tbRet then
                table.insert(tbList, tbRet)
                return true
            end
        end
    end

    local tbAllList = {}
    local tbRoles = Online.GetWeekGainRole(tbConfig) or {}
    for _, info in ipairs(tbRoles) do
        findCard({tbLineup, tbLineup1, tbLineup2}, tbAllList, info)
    end

    Online.SetPickCard(tbAllList)
end

--计算上阵附加角色
-- function Online.CalculatePickNum()
--     local  tbConfig = Online.GetConfig(Online.GetOnlineId())
--     if not tbConfig then return end

--     local tbLineup = Formation.GetLineup(Online.TeamId)
--     if not tbLineup then return end

--     local tbRoles = Online.GetWeekGainRole(tbConfig) or {}
--     for _, info in ipairs(tbRoles) do
--         local nRet = Online.MatchCard(tbLineup, info)
--     end


--     if tbConfig.nMaxPlayer >= 2 then
-- end

----任务变量
--获取每周积分
function Online.GetWeeklyPoint()
    return me:GetAttribute(Online.GroupId, Online.WeeklyPointTask)
end

--获取每周奖励标记
function Online.GetWeeklyAward(nId)
    if not nId or nId < 0 or nId > 30 then return true end

    local nValue = me:GetAttribute(Online.GroupId, Online.WeeklyAwardTask)
    local nRet = GetBits(nValue, nId, nId)
    return nRet > 0
end

--获取房间玩法id
function Online.GetPreId()
    return me:GetAttribute(Online.GroupId, Online.PreIdTask)
end

--获取真实进入的玩法id
function Online.GetJoinId()
    return me:GetAttribute(Online.GroupId, Online.JoinIdTask)
end

--获取体力开关
function Online.GetVigorSwitch()
    return me:GetAttribute(Online.GroupId, Online.VigorTask)
end

--获取关卡id
function Online.GetLevelId()
    return me:GetAttribute(Online.GroupId, Online.LevelTask)
end

--获取进入时间戳
function Online.GetEnterTime()
    return me:GetAttribute(Online.GroupId, Online.EnterTimeTask)
end

--获取战斗次数  正常结束
function Online.GetFightNum()
    return me:GetAttribute(Online.GroupId, Online.FightNumTask)
end

--获取首次弹窗
function Online.GetFirstPop(nId)
    if not nId then return 0 end

    local nOff = math.floor(nId / 30) + Online.FirstPopTask
    if nOff > Online.FirstPopEndTask then
        return 0
    end

    local nPos = nId % 30
    local nTaskValue = me:GetAttribute(Online.GroupId, nOff)
    return GetBits(nTaskValue, nPos, nPos)
end

--获取当前关卡的掉落
function Online.GetDropAwardList()
    local tbLevel = OnlineLevel.GetConfig(Online.GetLevelId())
    Online.SetOnlineLevelId(Online.GetLevelId())
    if not tbLevel then
        return
    end

    local tbShowAward = {}
    local tbDropList = tbLevel:GetDrop() or {}
    for i,tbTemp in ipairs(tbDropList) do
        local tbTempList = {}
        for type,awardList in pairs(tbTemp or {}) do
            for _, tbInfo in ipairs(awardList or {}) do
                if next(tbInfo) ~= nil then
                    local g, d, p, l = table.unpack(tbInfo[1])
                    table.insert(tbTempList , {g, d, p, l, tbInfo[2],type})
                end
            end
        end
        table.insert(tbShowAward, tbTempList)
    end

    if #tbShowAward == 0 then
        return
    end

    return tbShowAward
end

--获取当前玩家列表
function Online.GetRecentList()
    local tbIdList = {}
    local sInfo = me:GetStrAttribute(Online.Str_GroupId, Online.RecentTask)
    if sInfo and sInfo ~= '' then
        xpcall(function()
            tbIdList = json.decode(sInfo)
            if not tbIdList then
                tbIdList = {}
            end
        end, function(err)
            tbIdList = {}
        end)
    end
    return tbIdList
end

--获取当前玩家列表
function Online.GetRecentListProfile(func)
    if Online.nRecentTime < GetTime() then
        if Online.GetRecentFightList(
            Online.GetRecentList(),
            function(tbPlayers)
                Online.tbRecentList = tbPlayers
                Online.nRecentTime = GetTime() + 600
                func(tbPlayers)
            end
        ) then
            return
        end
    end

    func(Online.tbRecentList or {})
end

--获取推荐玩家列表
function Online.GetRecommendListProfile(func)
    if Online.nRecommendTime < GetTime() then
        Friend.GetRecommend(
            10,
            function(tbPlayers)
                Online.tbRecommendList = tbPlayers
                Online.nRecommendTime = GetTime() + 30
                func(tbPlayers)
            end
        )
        return
    end

    func(Online.tbRecommendList or {})
end

---服务器通信
--创建房间 or 再次进入房间
---@param nOnlineId integer 玩法id
---@param nTeamId integer 编队id
---@param bCheck bool 检查是否发送过请求
function Online.CraeteRoom(nOnlineId, nTeamId, bCheck)
    if not nOnlineId or not nTeamId then return end
    if nOnlineId == 0 or nTeamId == 0 then return end

    if bCheck  then
        Online.nSendCreateRoom = Online.nSendCreateRoom or 0
        if GetTime() - Online.nSendCreateRoom < 5 then
            UI.ShowTip("error.417")
            return
        end

        Online.nSendCreateRoom = GetTime()
    end
    
    me:OnlineCreateRoom(nOnlineId, nTeamId)
end

--退出房间 or 踢出某个人
---@param pId integer 队员id  0默认自己 >0 其他玩家
function Online.ExitRoom(pId)
    pId = pId or 0  
    me:OnlineExitRoom(pId)
end

--队员准备 or 队长开始
---@param nFlag integer 
function Online.ReadyRoom(nFlag)
    nFlag = nFlag or 0
    if nFlag < Online.Player_State_Ready then
        Online.UpdatePlayerState(Online.Player_State_Ready)
    elseif nFlag == Online.Player_State_Ready then
        Online.UpdatePlayerState(Online.Player_State_Empty)
    end
end

--队员准备 or 队长开始
---@param nReadyFlag integer  0空闲 1换装 2准备 Player_State_x
function Online.UpdatePlayerState(nReadyFlag)
    nReadyFlag = math.floor(tonumber(nReadyFlag))
    if nReadyFlag < Online.Player_State_Empty or nReadyFlag > Online.Player_State_Ready then 
        return
    end
    
    me:OnlineRoomStart(nReadyFlag)
end

--请求更新联机编队
---@param InLineupIndex integer 编队id
function Online.UpdateLineup(InLineupIndex)
    if not InLineupIndex then return end

    me:OnlineUpdateLineup(InLineupIndex)
end

--邀请某个玩家
---@param pId integer 队员id  其他玩家
function Online.InvitePlayer(pId)
    if not pId or pId == 0 then return end

    me:OnlineInvite(pId)
end

--接受邀请
---@param pId integer 队员id  其他玩家
---@param nOnlineId integer 玩法id
function Online.AcceptInvite(pId, nOnlineId)
    if not pId or not nOnlineId then return end

    local tbConfig = Online.GetConfig(nOnlineId)
    if tbConfig and tbConfig.nConsumeVigor > 0 and Cash.GetMoneyCount(Cash.MoneyType_Vigour) < tbConfig.nConsumeVigor then
        if not UI.IsOpen("PurchaseEnergy") then
            UI.Open("PurchaseEnergy", "Energy")
        end
        return
    end

    Launch.SetType(LaunchType.ONLINE)
    me:OnlineAccept(pId, nOnlineId)
end

--开关匹配
---@param bState bool true 打开 false关闭
function Online.MatchSwitch(bState)
    if bState == nil then return end

    me:OnlineMatch(bState)
end

--开关体力消耗
---@param bState bool true 打开 false关闭
function Online.VigourSwitch(bState)
    if bState == nil then return  end

    local bOpen = Online.GetVigorSwitch() > 0
    if bState == bOpen then --已经开启 or 关闭
        return true
    end

    if bState then
        local tbConfig = Online.GetConfig(Online.GetOnlineId())
        if not tbConfig then
            UI.ShowTip("tip.not_open")
            return
        end

        --判断奖励
        if Online.CheckGetPoint() then
            UI.ShowTip("tip.online_MaxPoint")
            return
        end

        --判断体力
        if  Cash.GetMoneyCount(Cash.MoneyType_Vigour) < tbConfig.nConsumeVigor then
            UI.ShowTip("tip.online_NoVigour")
            return
        end
    end
    
    me:CallGS("Online_CostVigour", json.encode({bOpen = bState}))
    return true
end

--重连相关
---@param nState integer 0询问是否需要重连  1取消重连  2确定重连
function Online.ReconnectReq(nState)
    if not nState then return end
    
    me:OnlineReqReconnect(nState)

    print("[Online] ReconnectReq", nState)
end

--一键领取周奖励
function Online.GetAllWeeklyAward(tbList)
    if not tbList then return end

    me:CallGS("Online_WeeklyAward", json.encode(tbList))
end

--初始化编队 没有10号编队 拷贝1号编队
function Online.CheckFormation(nTeamId)
    if not nTeamId then return end

    local Lineup = Formation.GetLineup(nTeamId)
    if Lineup and Lineup:GetCaptain() then
        return
    end

    Formation.SetCurLineupIndex(10)
    local tbCards = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(tbCards)
    local tbPower = {}
    local tbFunc = function(nGetPower, pCard) 
        if not pCard then return end

        local tmpCard = {nGetPower, pCard}
        for i=1,Online.MaxTeammate do
            if not tbPower[i] then
                tbPower[i] = tmpCard
                break
            else
                local tbInfo = tbPower[i]
                if tmpCard[1] > tbInfo[1] then
                    tbPower[i] = tmpCard
                    tmpCard = tbInfo
                end
            end
        end
    end

    for key, value in pairs(tbCards:ToTable()) do
        local nGetPower = Item.Zhanli_CardTotal(value)
        tbFunc(nGetPower, value)
    end

    for i=1,Online.MaxTeammate do
        local tbInfo = tbPower[i]
        if tbInfo then
             Formation.SetLineupMember(nTeamId, i-1, tbInfo[2])
        end
    end

    for i=Online.MaxTeammate+1,3 do
        Formation.SetLineupMember(nTeamId, i-1, nil)
    end


    if Formation.GetCardByIndex(nTeamId, 0) == nil then
        return
    end

    Formation.Req_UpdateLineup(nTeamId, function() end)
end

--检测编队成员数量
function Online.CheckFormationInUI(nTeamId)
    if not nTeamId then return end

    local Lineup = Formation.GetLineup(nTeamId)
    if not Lineup then
        return
    end

    local bUp = false
    local Member = Lineup:GetMember(1)
    if Member and Online.MaxTeammate < 2 then
        Formation.SetLineupMember(nTeamId, 1, nil)
        bUp = true
    end

    Member = Lineup:GetMember(2)
    if Member and Online.MaxTeammate < 3 then
        Formation.SetLineupMember(nTeamId, 2, nil)
        bUp = true
    end

    if bUp then
        Formation.Req_UpdateLineup(nTeamId, function() end)
    end
end

--获取最新 匹配队员信息
function Online.GetRecentFightList(tbList, funcRecv)
    if not tbList then return end

    local tArray = UE4.TArray(UE4.int64);
    for i,v in pairs(tbList) do
        tArray:Add(v);
    end

    if tArray:Length() == 0 then
        return false
    end

    me:GetPlayerProfile(tArray)

    EventSystem.On(
        Event.GetPlayerProfile,
        function(pTArrayList)
            local tbPlayers = {}
            for i = 1, pTArrayList:Length() do
                table.insert(tbPlayers, Profile.Trans(pTArrayList:Get(i)))
            end
            if funcRecv then
                funcRecv(tbPlayers)
            end
        end,
        true
    )

    return true
end

-- 重连相关
--bBreak 防止一直询问
function Online.CheckReconnect(bBreak)
    --print("OnlineEvent CheckReconnect==", bBreak, Map.GetCurrentID(), Online.GetOnlineState(), debug.traceback())
     if Map.GetCurrentID() ~= 2 then --在主场景 才提示
        return false
    end

    if Online.GetOnlineState() == Online.STATUS_END then
        return false
    end

    if Online.GetJoinId() == 0 and not bBreak then --有房间id，没有战斗id，先问一下
        if Online.GetPreId() > 0 and Online.bLoginFirst then
            Online.ReconnectReq(0)
        end
        return false
    elseif Online.GetJoinId() > 0 and not bBreak then --离战斗开始时间超过限值，先问下服务器，再提示是否重连
        local nDisTime = GetTime() - Online.GetEnterTime()
        if nDisTime < 0 then --调了服务器时间？
            nDisTime = Online.Req_Reconnect_Time
        end

        if nDisTime >= Online.Req_Reconnect_Time and Online.bLoginFirst then
            Online.ReconnectReq(0)
            return false
        end
    end

    --其他情况肯定有战斗id，直接问是否重连
    if Online.GetJoinId() == 0 and Online.GetPreId() == 0 then
        return false
    end

    local sName = ""
    local tbConfig = Online.GetConfig(Online.GetJoinId())
    if  tbConfig then
        sName = Text(tbConfig.sName)
    end 

    Online.ReqReconnectState = true
    UI.Open(
                "MessageBox",
                string.format(Text("ui.TxtConnectWarnTips"),sName),
                function()
                    Online.SetOnlineId(Online.GetPreId())
                    Online.ReconnectReq(2)
                end,
                function()
                    Online.ReconnectReq(1)
                end,
                nil,
                nil,
                function()
                    Online.ReconnectReq(1)
                end
            )

    -- 机器人处理
    DSAutoTestAgent.CheckReconnect()

    return true
end

--重新进入组队界面 联机战斗后返回
function Online.CheckTeamUI()
     if Map.GetCurrentID() ~= 2 then --在主场景 才提示
        return false
    end

    --print("Online.CheckTeamUI", debug.traceback())
    if Online.bGiveUp then
        Online.bGiveUp = false
        return
    end

    if Online.GetOnlineState() ~= Online.STATUS_END then
        return
    end

    if not UI.IsOpen("Formation") then
        if UI.tbRecover and #UI.tbRecover > 0 then
           table.insert(UI.tbRecover, "dungeonsonlinelevel")
        end
        --print("CheckTeamUI==", Online.GetOnlineId(), Online.TeamId)
        Online.CraeteRoom(Online.GetOnlineId(), Online.TeamId)
    end
end

--放弃战斗
function Online.DoGiveUp()
   -- print("OnlineEvent DoGiveUp==", Map.GetCurrentID() == 2 ,Online.GetOnlineState() ~= Online.STATUS_FIGHT)
    if Map.GetCurrentID() == 2 or Online.GetOnlineState() ~= Online.STATUS_FIGHT then --在主场景
        return false
    end

    --放弃 不回编队
    UE4.UAccount.ClearOthers(1);
    Online.ClearAll()
    Online.ReconnectReq(1)
    Online.bGiveUp = true
end

--执行退出
function Online.DoRealExit()
    print("==================Online.IsSendExit == ",Online.IsSendExit)
    if Online.IsSendExit then return end

    if Online.GetPreId() > 0  and Online.GetOnlineState()  <= Online.STATUS_READY then
        Online.ExitRoom(0)
    end
end

--返回 和 回到主界面 
function Online.DoExitRoom(tbFunc, nState, bBreak)
    if Online.GetOnlineState() >= Online.STATUS_ENTER then
        UI.ShowTip("tip.online_RoomStateError")
        return
    end

    local doFunc = function(fFunc)
        Online.DoRealExit()
        Online.IsSendExit = true
        if not (DSAutoTestAgent.bOpenAutoAgent and DSAutoTestAgent.bRunNullRhi) then
            if not fFunc then
                UI.OpenMainUI()
            else
                UI.OnlineCloseAll()
            --  UI.RecoverUI()
                UI.ActiveTop()

                local tbConfig = Online.GetConfig(Online.GetOnlineId())
                if tbConfig then
                    UI.Open("DungeonsOnlineLevel", tbConfig)
                end
            end

            local sUI = UI.GetUI("OnlineInvite")
            if sUI and sUI:IsOpen() then
                sUI:CloseMatchTip()
            end
        end
        Online.IsSendExit = nil
    end

    if not bBreak and nState and nState == 1 then
        UI.Open(
                "MessageBox", Text("tip.online_ExitRoom"),
                function()
                    doFunc(tbFunc)
                end,
                function()
                    if tbFunc then tbFunc() end
                end
            )
    else
        doFunc(tbFunc)
    end
end

--战斗结束  客户端效率日志
function Online.DoPerformanceLog()
    me:CallGS("Online_ClientLog", json.encode({["LevelPerformance"] = LaunchLog.LogPerformance()}))
end

-- 战斗结束  ds调用
function Online.Settlement(pId, nIndex)
    local tbEndData = {}  --数据成就相关
    tbEndData.Score = 0 --积分
    tbEndData.ReviveCoin = 0   --复活币次数
    tbEndData.UseMachine = 0  --使用商店(购物机)次数 有购买行为
    tbEndData.ActivateMachine = 0 --激活商店次数
    tbEndData.BuyGold = 0   -- 购买增益 消耗的金币
    tbEndData.tbBuyBuff = {}   -- 购买buff(品质)的次数  {buff品质,次数}
    tbEndData.CollectCoin = 0  -- 收集的 金币
    tbEndData.KillNormal = 0   --击杀普通
    tbEndData.KillElite = 0     --击杀精英
    tbEndData.KillBoss = 0    --击杀boss

    local tbAllData = {}
    tbAllData.tbEndData = tbEndData

    local tbParam = {}
    local GameState = UE4.AGameBaseState.GetGameState()
    if GameState then
        local PlayerState = GameState:GetPlayerState(nIndex)
        if not PlayerState then
            return json.encode(tbAllData)
        end

        tbEndData.Score = PlayerState:GetMultiLevelPoint();
        tbEndData.CollectCoin = PlayerState:GetMultiLevelMoney();
        tbEndData.BuyGold = PlayerState:GetConsumeBufferMoney();

        tbParam.nScore = tbEndData.Score
        tbParam.nCoin = tbEndData.CollectCoin
        tbParam.nUseCoin = tbEndData.BuyGold

        local GameController = GameState:GetPlayerController(nIndex)
        if GameController then
            tbEndData.ReviveCoin = GameState.ReviveCount - GameController.ReviveCount
            tbParam.nResurrectTimes = tbEndData.ReviveCoin

            tbParam.GameController = GameController

            local tbArray = GameController.BoughtBufferes
            if tbArray then
                tbEndData.UseMachine = tbArray:Length()
                for i = 1, tbArray:Length() do
                    local FBoughtBufferInfo = tbArray:Get(i)
                    if FBoughtBufferInfo and FBoughtBufferInfo.Rarity  then
                        if not tbEndData.tbBuyBuff[FBoughtBufferInfo.Rarity] then
                            tbEndData.tbBuyBuff[FBoughtBufferInfo.Rarity] = FBoughtBufferInfo.BufferCount
                        else
                            tbEndData.tbBuyBuff[FBoughtBufferInfo.Rarity] = tbEndData.tbBuyBuff[FBoughtBufferInfo.Rarity] + FBoughtBufferInfo.BufferCount
                        end
                    end
                end
            end

            local tbActivedArray = GameController.ActivedBufferShopes
            if tbActivedArray then
                tbEndData.ActivateMachine = tbActivedArray:Length()
            end
        end
    end

    local TaskSubActor = UE4.ATaskSubActor.GetTaskSubActor(GameState)
    tbEndData.tbMonster = RikiLogic:GetMonsterData(TaskSubActor)
    if TaskSubActor and TaskSubActor.GetAchievementData then
        local tbKillMonster = TaskSubActor:GetAchievementData()
        local tbKey = tbKillMonster:Keys()
        for i = 1, tbKey:Length() do
            local nKey = tbKey:Get(i)
            if nKey == 1 then
                tbEndData.KillNormal = tbKillMonster:Find(tbKey:Get(i))
            elseif nKey == 2 then
                tbEndData.KillElite = tbKillMonster:Find(tbKey:Get(i))
            elseif nKey == 3 then
                tbEndData.KillBoss = tbKillMonster:Find(tbKey:Get(i))
            end
        end
    end

    local GameTaskActor = UE4.AGameTaskActor.GetGameTaskActor(GameState)
    tbParam.GameTaskActor = GameTaskActor

    --日志
    tbParam.PlayerIndex = nIndex
    tbAllData.tbLevelLog = LaunchLog.DSLevelLog(tbParam)
    tbAllData.tbFightRecont = LaunchLog.LogFightRecont(tbParam)

    return json.encode(tbAllData)
end

--联机连接异常处理
--返回 nil or false 后续不执行，界面不变     true 后续代码继续执行
function Online.OnServerError(uWorld, nFailureType, sErrorString)
    DSAutoTestAgent.OnServerError(uWorld, nFailureType, sErrorString)

    print("[Online] OnServerError", nFailureType, sErrorString, Online.GetOnlineState())

    if not UI.IsOpen("OnlineWarnTips") then
        local sUI = UI.GetUI("FullScreenTip")--全屏ui
        if sUI then
            UI.Close(sUI)
        end

        Online.ReconnectReq(1)

        local errTip = string.format("error.netfailure_"..nFailureType)
        UI.Open("OnlineWarnTips", errTip, function()
            print("[Online] OnlineWarnTips", errTip)
            if UI.IsOpen("Main") then PreviewScene.Enter(PreviewType.main) return end

            local sUI = UI.GetUI("DisConnected")--全屏ui
            if sUI then
                UI.Close(sUI)
            end

            UI.CloseTop()
            if (Map.GetCurrentID() ~= 2) then
                GoToMainLevel()
            else 
                local tbMap = Map.Class('MainMap')
                if tbMap then
                   tbMap:OnlineEvent()
                end
            end
        end)
    end
end

-- 连接丢失
function Online.OnConnectionLost(FailureType)
    print("Online.OnConnectionLost ", FailureType)
    if not Online.AllowAutoConnection then
        print("Online.OnConnectionLost AllowAutoConnection = ", Online.AllowAutoConnection)
        me:Logout()
        GoToLoginLevel()
        return
    end
    
    local sUI = UI.GetUI("DisConnected")
    if not sUI then
        UI.Open("DisConnected")
    else
        print("UI DisConnected Exist!")
    end

    local dcUI = UI.GetUI("DisConnected")
    if not UE4.UTGameEngine.IsNetworkFailure() then
        -- 自动重连
        UE4.UTGameEngine.ReConnectServer(dcUI);
    elseif dcUI then
        dcUI:OnUpdate()
    end
end

--第一次弹窗说明
function Online.CheckPopInfo(tbConfig)
    if tbConfig and tbConfig.nHelpImgId > 0 and Online.GetFirstPop(tbConfig.nId) == 0 then
        local sUI = UI.GetUI("HelpImages")
        if sUI then
            UI.Display(tbConfig.nHelpImgId)
        else
            UI.Open("HelpImages", tbConfig.nHelpImgId)
        end

        me:CallGS("Online_FirstPop", json.encode({nId = tbConfig.nId}))
    end
end

---注册结算回调 联机战斗？
s2c.Register('Online_Settlement', function(...)
    print("online settlement=====", Map.GetCurrentID())
    
   -- GoToMainLevel()
end
)

---注册结算回调
s2c.Register('Online_WeeklyAward', function(tbParam)
    print("Online_WeeklyAward")
    local sUI = UI.GetUI("DungeonsOnline")
    if sUI and sUI:IsOpen() then
        sUI:OnReceiveUpdate(tbParam)
    else
        sUI = UI.GetUI("DungeonsOnlineLevel")
        if sUI and sUI:IsOpen() then
            sUI:OnReceiveUpdate(tbParam)
        end
    end
end
)

s2c.Register('Online_CostVigour', function(...)
    print("Online_CostVigour")
    local sUI = UI.GetUI("Formation")
    if sUI then
        sUI:UpdateOnline()
    end
end
)

---服务器返回信息 nErrCode 错误码  nState c++回调类型
---nState 0 创建房间返回 nParam1(玩法id), nParam2(队伍Id), nParam2(编队Id)
---nState 1 准备或者开始游戏 返回 无
---nState 2 开/关匹配 返回 true打开  false关闭
---nState 4 退出房间 返回 无
---nState 5 房间信息修改通知 nParam1(队长信息), nParam2(准备信息), nParam3(房间匹配状态),nParam4(房间buff信息)
---nState 6 已经申请ds房间，等待下发信息
---nState 7 开始战斗了
---nState 8 战斗结束
---nState 9 邀请 返回
---nState 10 接受邀请 返回
---nState 11 被踢出的通知
---nState 12 邀请信息的通知 nParam1(邀请者名字), nParam2(TArray<uint64> 顺序:房间id,玩法id,角色id,头像,头像框,等级)
---nState 13 编队信息更新 返回
---nState 14 是否重连返回 nParam1(0 取消 1 需要重连 2 已经通知重连信息 3ds还没准备好，请等待)
---nState 15 房间or玩家状态 nParam1(匹配状态0不处理1未匹配2匹配) nParam2(玩家状态列表0不处理1未准备2准备)
EventSystem.On(Event.OnlineEvent, function(nErrCode, nState, nParam1, nParam2, nParam3, nParam4)
    print("[Online] OnlineEvent====", nErrCode, nState, nParam1)
    Online.bLoginFirst = false
    if nState and nState == 0 then
        Online.nSendCreateRoom = 0
    end

    if not nErrCode then
        print("Event.OnlineEvent Error Param!!!")
        return
    end

    DSAutoTestAgent.OnReceiveOnlineEvent(nErrCode, nState, nParam1, nParam2, nParam3, nParam4)

    if nErrCode > 0 then
        if nState ~= 9 then --单方面邀请,不提示邀请失败的错误
            UI.ShowError(nErrCode)
        end

        if nState == 10 then
            local sUI = UI.GetUI("OnlineInvite")
            if sUI then
                sUI:ShowNext()
            end
        end
        return
    end

    if nState == 0 then
        Online.DoEevent0(nState, nParam1, nParam2, nParam3, nParam4)
    elseif nState == 1 then
        Online.DoEevent1(nState, nParam1, nParam2, nParam3, nParam4)
    elseif nState == 4 then
        Online.DoEevent4(nState, nParam1, nParam2, nParam3, nParam4)
    elseif nState == 6 then
        Online.DoEevent6(nState, nParam1, nParam2, nParam3, nParam4)
    elseif nState == 7 then
        Online.DoEevent7(nState, nParam1, nParam2, nParam3, nParam4)
    elseif nState == 10 then
        Online.DoEevent10(nState, nParam1, nParam2, nParam3, nParam4)
    elseif nState == 11 then
        Online.DoEevent11(nState, nParam1, nParam2, nParam3, nParam4)
    elseif nState == 12 then
        Online.DoEevent12(nState, nParam1, nParam2, nParam3, nParam4)
    elseif nState == 14 then
        Online.DoEevent14(nState, nParam1, nParam2, nParam3, nParam4)
    else -- 2,5,15
        Online.DoEeventAll(nState, nParam1, nParam2, nParam3, nParam4)
    end
end)

function Online.DoEevent0(nState, nParam1, nParam2, nParam3, nParam4)
    if Map.GetCurrentID() ~= 2 then --在主场景
        return
    end

    Online.bGiveUp = false
    Online.ClearPlayerState()

    if Online.GetPreId() > 0 then
        Online.SetOnlineId(Online.GetPreId())
    end
    Online.SetMatchState(false)
    Online.SetOnlineState(Online.STATUS_OPEN)
    Online.SetWeekBuff(nParam4)

    if Online.GetOnlineState() <= Online.STATUS_ENTER then
        Online.CalculatePickCard()
    end
    
    UI.OnlineCloseAll()
    UI.Open("Formation", nParam1,  true)
end

function Online.DoEevent1(nState, nParam1, nParam2, nParam3, nParam4)
    if nParam1 and nParam1 == Online.Player_State_Ready then
        Online.SetOnlineState(Online.STATUS_READY)
    elseif nParam1 and nParam1 < Online.Player_State_Ready then
        Online.SetOnlineState(Online.STATUS_OPEN)
    end
end

function Online.DoEevent4(nState, nParam1, nParam2, nParam3, nParam4)
    if not nParam1 or nParam1 ~= 0 then
        return
    end

    local nOldId = Online.GetOnlineId()
    UE4.UAccount.ClearOthers(1);
    Online.ClearAll()

    if UI.IsOpen("DungeonsOnlineLevel") then--回退界面
        if Launch.GetType()  ~= LaunchType.ONLINE then
            Launch.SetType(LaunchType.ONLINE)
        end

        if Online.GetOnlineId() ~= nOldId then
            Online.SetOnlineId(nOldId)
        end
    end
end

function Online.DoEevent6(nState, nParam1, nParam2, nParam3, nParam4)
    if Online.GetPreId() == 0 then
        return
    end

   if nParam1 == 0 then
        Online.SetOnlineState(Online.STATUS_ENTER)
        local sUI = UI.GetUI("Formation")
        if sUI then
            sUI:UpdateOnline(nState, false)
        end

        local sUI = UI.GetUI("FullScreenTip") --全屏ui
        if sUI then
            sUI:ShowEnterTip("tip.online_ReStart")
        else
            UI.Open("FullScreenTip", 1,  "tip.online_Starting")
        end
    else ---开始失败了
        UI.ShowTip("tip.online_ReStart")
        local sUI = UI.GetUI("Formation")
        if sUI then
            sUI:UpdateOnline(nState)
        end

        local sUI = UI.GetUI("FullScreenTip") --全屏ui
        if sUI then
            UI.Close(sUI)
        end
        Online.SetOnlineState(Online.STATUS_OPEN)
    end

    Online.SetReadyTime(0)
    Online.ClearInviteInfo()
end

function Online.DoEevent7(nState, nParam1, nParam2, nParam3, nParam4)
    if Online.GetPreId() == 0 then
        return
    end

    if nParam1 == 1 then --BrowseFailure (HandleTravelFailure)
        local sUI = UI.GetUI("FullScreenTip") --全屏ui
        if sUI then
            UI.Close(sUI)
        end

        Online.CheckReconnect(true)
        return
    end

    Online.SetReadyTime(0)
    Online.SetOnlineState(Online.STATUS_FIGHT)
    UI.SnapShoot({"dungeonsonlinelevel", "formation"})
    PreviewScene.Reset()
    Online.ClearInviteInfo()
    Online.DoChangeDropList()
    Online.nRecentTime = 0

    ---保存经验值信息 用于结算的动态变化
    local tbteam = Formation.GetCurrentLineup()
    Launch.SaveExpData(tbteam)

    local tbMap = Map.Class('MainMap')
    if tbMap then
       tbMap:OnlineEvent(true)
    end

    local tbLevel = OnlineLevel.GetConfig(Online.GetLevelId())
    if tbLevel then 
        UE4.UCrashEyeHelper.CrashEyeLeaveBreadcrumb("open map:" .. tbLevel.nMapID);
    end
    ---退后台超时处理
    if not Online.willDeactivateHandle then
        Online.willDeactivateHandle = EventSystem.On(Event.AppWillDeactivate, function() 
            print("[Online] App Will Deactivate")
            Online.EnterBackgroundTime = GetTime()
        end)
    end
    if not Online.hasReactivatedHandle then
        Online.hasReactivatedHandle = EventSystem.On(Event.AppHasReactivated, function() 
            print("[Online] App Will Reactivate")
            if (Online.EnterBackgroundTime > 0) then
                local nNow = GetTime()
                --- 退后台超过45s，需要重连
                if (nNow - Online.EnterBackgroundTime) >= 45 then
                    print("[Online] Deactivated greater then 45s")
                    local FightUI = UI.GetUI("Fight")
                    -- 自动重连
                    UE4.UTGameEngine.ReConnectServer(FightUI);
                end
                Online.EnterBackgroundTime = 0
            end
        end)
    end
end
function Online.DoEevent10(nState, nParam1, nParam2, nParam3, nParam4)
    Online.ClearInviteInfo()
    local sUI = UI.GetUI("Formation")
    if not sUI or not sUI:IsOpen() or not sUI.bOnline or Online.GetPreId() == 0 then
        local tbConfig = Online.GetConfig(nParam1)
        if tbConfig then
            Online.SetOnlineId(nParam1)
            Online.SetOnlineState(Online.STATUS_OPEN)
            Online.SetMatchState(false)

            --邀请进去的 防止界面错乱
            UI.OnlineCloseAll()
            UI.Open("Formation", nParam1,  true)
        end
    else
        sUI:UpdateOnline(nState, nParam1, nParam2, nParam3)
    end
end
function Online.DoEevent11(nState, nParam1, nParam2, nParam3, nParam4)
    local sUI = UI.GetUI("Formation")
    if not sUI then
        return
    end

    UE4.UAccount.ClearOthers(1);
    Online.ClearAll()
   -- sUI:DoKickOut(true)
    Online.DoExitRoom( function() end, 0, true)

    UI.ShowTip("tip.kickout")
end
function Online.DoEevent12(nState, nParam1, nParam2, nParam3, nParam4)
    if Map.GetCurrentID() ~= 2 then --在主场景 才提示
        return
    end
    
    if not UI.IsOpen("OnlineInvite") then
        UI.Open("OnlineInvite", {nParam1, nParam2})
    else
        Online.AddNewInfo({nParam1, nParam2})
    end
end

function Online.DoEevent14(nState, nParam1, nParam2, nParam3, nParam4)
    if nParam1 == 1  then
        Online.CheckReconnect(true)
        return
    end

    if nParam1 == 0 and Online.ReqReconnectState then
        Online.ReqReconnectState = false
        if Map.GetCurrentID() == 2 then
            if UI.IsOpen("Formation") then
                UI.Open("OnlineWarnTips", nil, function() UE4.Timer.Add(0.1, function()
                        Online.DoExitRoom( function() end, 0, true)         
                    end)   
                end)--游戏已经结束
            else
                UI.Open("OnlineWarnTips")--游戏已经结束
            end
        end
    end

    if nParam1 == 2 then
        Launch.SetType(LaunchType.ONLINE)
        Online.DoChangeDropList()
    elseif nParam1 == 3 then
        Launch.SetType(LaunchType.ONLINE)
        Online.DoChangeDropList()
        local sUI = UI.GetUI("FullScreenTip") --全屏ui
        if sUI and sUI:IsOpen() then
            sUI:ShowEnterTip("tip.online_ReStart")
        else
            UI.Open("FullScreenTip", 1,  "tip.online_Starting")
        end
    else
        UE4.UAccount.ClearOthers(1);
        Online.ClearAll()
    end 
end

function Online.DoEeventAll(nState, nParam1, nParam2, nParam3, nParam4)
    if Online.GetPreId() == 0 then
        return
    end

    if nState == 5 and Online.GetOnlineState() <= Online.STATUS_ENTER then
        Online.CalculatePickCard()
    end

    local sUI = UI.GetUI("Formation")
    if sUI then
        sUI:UpdateOnline(nState, nParam1, nParam2, nParam3, nParam4)
    end

    if nState  == 15 then --准备
        if Online.CheckMemberAllReady() then
            Online.SetReadyTime(GetTime())
        else
            Online.SetReadyTime(0)
        end
    end

    local sUI = UI.GetUI("OnlineInvite")
    if sUI and nState == 5 and Online.CheckRoomPlayer() then
        sUI:ShowNext()
    end
end

--登陆清空
function Online.DoLoginClean()
    Online.AllowAutoConnection = true
    Online.tbInviteList = {}
    Online.nRecentTime = 0 
    Online.nRecommendTime = 0

    if me and Online.LastLoginId ~= me:Id() then
        Online.ClearInviteInfo()
    end

    if me and me:Id() > 0 then
        Online.LastLoginId = me:Id()
    end
end

---这里3种状态(首次登陆  重连   重连失败等退到主界面的重登录)
EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    --print("Online Logined", Online.bLoginFirst, bReconnected, bNeedRename)
    Online.DoLoginClean()
    if Online.bLoginFirst == nil then --首次登陆
        Online.bLoginFirst = true
    elseif Online.bLoginFirst ~= nil and not bReconnected then
        if UI.IsOpen("OnlineInvite") then
            UI.Close("OnlineInvite")
        end
    elseif bReconnected  then --在组队界面重连成功
        if Map.GetCurrentID() ~= 2 then
            return
        end
        
        if Online.GetOnlineState() == Online.STATUS_FIGHT or Online.GetOnlineState() == Online.STATUS_ENTER then
            Online.CheckReconnect(true)
        elseif  Online.GetPreId() > 0 then
            if Online.GetOnlineState() >= Online.STATUS_READY then
                Online.ReconnectReq(0)
            end
            Online.DoExitRoom( function() end, 0, true)
        end
    end
end)

Online.tbCacheReviveData = {}

EventSystem.On(Event.NotifyTeammateDeathBegin, function(Index, Actor)
    local ui_fight = UI.GetUI("Fight")
    ---战斗UI存在，就不缓存
    if ui_fight then 
        ui_fight:NotifyTeammateDeathBegin(Index, Actor)
    else
        Online.tbCacheReviveData[Index] = Actor
    end
end)

EventSystem.On(Event.NotifyTeammateDeathEnd, function(Index)
    local ui_fight = UI.GetUI("Fight")
    if ui_fight then
        ui_fight:NotifyTeammateDeathEnd(Index)
    end
    ---有缓存，就清除
    if Online.tbCacheReviveData[Index] then
        table.remove(Online.tbCacheReviveData, Index)
    end
end)

function Online.ClearReviveCacheData()
    Online.tbCacheReviveData = {}
end

Online.Init()
