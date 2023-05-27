-- ========================================================
-- @File    : Activity.lua
-- @Brief   : 活动相关接口
-- ========================================================

---@class Activity 活动数据管理
---@field tbConfig table 活动总表
---@field tbTemplate table 活动模板表
---@field tbModelGroup table 模板层级
Activity = Activity or{
    tbConfig            = {},
    tbTemplate          = {},
    tbModelGroup           = {},
}

--弹窗顺序 也是类别
Activity.POP_DAILYSIGN          = 1         --- 日签
Activity.POP_SHORTSIGN       = 2         --- 短签
Activity.POP_ACTIVITYFACE    = 3         --- 打脸图
Activity.POP_NOTICE          = 4         --- 公告


--属性 group   0-9被空出来了
Activity.nGroupId = 50
 --每个活动预留10个属性id   活动id 最大 6550
 --activities.txt里面的id * 10 + 0 - 9
 --0号位 固定 存储活动当前开启时间   如果时间不一致会认为是新活动 重置所有相关变量
 --1号位 固定 标记位 (0位new标记 1位红点标记 )
 --2号位 预留  整体性变量
 --3号位--9号位  每个活动自定义数据
Activity.MinIdPos = 0
Activity.MaxIdPos = 9
Activity.IdPosStep = 10

--客户端主动询问服务器列表
Activity.tbRefreshList = {}

--记录当前打开的标签
Activity.OpenUI_Id = nil

--客户端主动询问服务器领奖cd
Activity.tbAwardCDList = {}


--获取对应活动id的记录数据id
---@param nId integer 活动ID
---@param nPos integer 预留数据位置(0-9)
function Activity.GetBaseTaskId(nId, nPos)
    if not nId or not nPos or nPos < Activity.MinIdPos or nPos > Activity.MaxIdPos then
        error('GetBaseTaskId nId or nPos Error');
        return
    end

    local nRealId = nId * Activity.IdPosStep + nPos
    if nRealId > 65535 then
        error('GetBaseTaskId nRealId Max');
        return
    end

    return nRealId
end

--获取对应活动id的记录数据
---@param nId integer 活动ID
---@param nPos integer 预留数据位置(0-9)
function Activity.GetBaseTaskValue(nId, nPos)
    local nRealId = Activity.GetBaseTaskId(nId, nPos)
    if not nRealId  then
        error('GetBaseTaskValue nRealId Error');
        return 0
    end

    return me:GetAttribute(Activity.nGroupId, nRealId)
end

--获取当前活动开始时间
---@param nId integer 活动ID
---@return integer  活动开始时间 时间戳 如果配置表开始时间是-1 这里存的是1
function Activity.GetOpenTime(nId)
    return Activity.GetBaseTaskValue(nId, 0)
end

--获取红点标记 默认是0 有红点  标记后为1
---@param nId integer 活动ID
 ---@return bool true 红点  false没有
function Activity.IsRedFlag(nId)
    local nValue = Activity.GetBaseTaskValue(nId, 1)
    return GetBits(nValue, 0, 0) == 0
end

--获取New标记 默认是0 有  标记后为1
---@param nId integer 活动ID
 ---@return bool true 有  false没有
function Activity.IsNewFlag(nId)
    local nValue = Activity.GetBaseTaskValue(nId, 1)
    return GetBits(nValue, 1, 1) == 0
end

--获取对应活动id的DIY记录数据id
---@param nId integer 活动ID
---@param nPos integer 预留数据位置(1-7)
function Activity.GetDiyTaskId(nId, nPos)
    if not nId or not nPos or nPos <= Activity.MinIdPos or nPos > Activity.MaxIdPos-2 then
        error('GetDiyTaskId nId or nPos Error');
        return
    end

    local nRealId = nId * Activity.IdPosStep + nPos+2
    if nRealId > 65535 then
        error('GetBaseTaskId nRealId Max');
        return
    end

    return nRealId
end

--获取活动自定义数据
---@param nId integer 活动ID
---@param nPos integer 预留数据位置(1-7)
function Activity.GetDiyData(nId, nPos)
    local nRealId = Activity.GetDiyTaskId(nId, nPos)
    if not nRealId then
        error('GetDiyData nRealId Max');
        return 0
    end

    return me:GetAttribute(Activity.nGroupId, nRealId)
end

--- 获取组别下的条目
---@param InGroup integer 组别
---@return table 活动case
function Activity.GetTemplateCase(InGroup)
    return Activity.tbModelGroup[InGroup]
end

---判断是否开放
---@param nId integer 活动ID
function Activity.IsOpen(nId)
    local tbConf = Activity.GetActivityConfig(nId)
    if not tbConf then
        return false, {'ui.TxtNotOpen'}
    end

    --- 活动开放时间
    if not IsInTime(tbConf.nStartTime, tbConf.nEndTime) then
        return false, GetTime() > tbConf.nEndTime and {'ui.TxtDLC1Over'} or {'ui.TxtNotOpen'}
    end

    -- 检测限制
    local bUnLock, tbMsg = Condition.Check(tbConf.tbCondition)
    if not bUnLock then
        return false, tbMsg
    end

    --服务器是否已开启
    if  Activity.Quest_Refresh(tbConf) then
        return false, {'ui.TxtNotOpen'}
    end

    return true
end

-- 检查主界面是否会有弹出界面
--弹出顺序(日签，短签，打脸图，公告(暂时不管))
function Activity.IsHaveOpen()
    if not FunctionRouter.IsOpenById(FunctionType.Activity) then
        return false
    end

    --签到
    if Sign.CheckOpen() then
        return true
    end

    --打脸图
    if Activityface.CheckOpen() then
        return true
    end

    --公告
    if Notice.CheckOpen() then
        return true
    end

    return false
end

--- 登录进入签到界面
---@param InParent Widget 父控件
function Activity.OnOpen(InFrom)
    ZoneTime.CheckReqTime()
    if not FunctionRouter.IsOpenById(FunctionType.Activity) then
        return
    end

    --签到
    if Sign.CheckOpen(true) then
        return
    end

    --打脸图
    if Activityface.CheckOpen(true) then
        return
    end

    --联机
    if Online.CheckReconnect() then
        return
    end

    --弹出邀请界面
    Online.CheckAndShowInviteUI()

    ---所有弹出界面结束后检测主界面指引
    local sUI = UI.GetUI("Main")
    if sUI then
        sUI:RefreshRedInfo(FunctionType.Activity)
        if sUI:IsOpen() and not UI.IsOpen("Notice") then
            GuideLogic.CheckGuide("main")
        end
    end
end

---判断是否开放
---@param nId integer 活动ID
function Activity.ClickLockTip(tbConf)
    if not tbConf then
        UI.ShowTip('tip.not_activity')
        return false
    end

    --- 活动开放时间
    if not IsInTime(tbConf.nStartTime, tbConf.nEndTime) then
        UI.ShowTip('tip.not_open')
        return false
    end

    -- 检测限制
    local bUnLock, tbDes = Condition.Check(tbConf.tbCondition)
    if not bUnLock then
        UI.ShowTip(tbDes[1] or '')
        return false
    end

    return true
end

--当前活动是否需要服务器更新红点
function Activity.CheckQuestRed(nId)
    if not nId then return false end

    if not Activity.IsOpen(nId)  then
        return false
    end

    local tbConf = Activity.GetActivityConfig(nId)
    if not tbConf then
        return false
    end

    if tbConf.sClass == "signin_monthly" then --签到
        return false
    elseif tbConf.sClass == "activity_quest" then --任务类
        return  true
    else  --默认 第一次有红点
        return true
    end
end

--将此当前活动是否有红点
--是否有红点
--是否task红点
function Activity.CheckActivityRed(tbConf)
    if not tbConf then return false end

    if not Activity.CheckLifelong(tbConf) then return false end

    --print("CheckActivityRed==", tbConf.nId, tbConf.sClass, Activity.IsRedFlag(tbConf.nId))

    if tbConf.sClass == "signin_monthly" then --签到 都是自动 默认没有
        return false
    elseif tbConf.sClass == "activity_quest" then --任务类 有奖励 就有红点
        if Activity.IsRedFlag(tbConf.nId) then
            return true
        end

        for i,v in ipairs(tbConf.tbDaily) do
            if Achievement.CheckAchievementReward(v, true) == Achievement.STATUS_CAN then
                return true
            end
        end

        for i,v in ipairs(tbConf.tbWeekly) do
            if Achievement.CheckAchievementReward(v, true) == Achievement.STATUS_CAN then
                return true
            end
        end

        for i,v in ipairs(tbConf.tbNormal) do
            local nRet = Activity.CheckUnlockDailyQuest(tbConf, v)
            if nRet == 0  or nRet == 2 then
                if Achievement.CheckAchievementReward(v, true) == Achievement.STATUS_CAN then
                    return true
                end
            end
        end
    elseif tbConf.sClass == "vigour_supply" then --两餐体力 可领取时有红点
        return VigourSupply:CheckReceive()
    elseif tbConf.sClass == "first_recharge" then --首充返利
        return Activity.CheckFirstRechargeAward(tbConf.nId)
    else  --默认 第一次有红点
        return Activity.IsRedFlag(tbConf.nId)
    end
end

--检测是否有整体红点
function Activity.CheckMainRed()
    for k,v in pairs(Activity.tbConfig) do
        if Activity.IsOpen(v.nId) and v.nHide == 0 then
            if Activity.CheckActivityRed(v) then
                return true
            end
        end
    end

    return false
end

--检测当前主标签是否有红点
function Activity.CheckAllCaseRed(tbCaseList)
    if not tbCaseList then return false end

    for i,v in pairs(tbCaseList) do
        if Activity.IsOpen(v.nId) and v.nHide == 0 then
            if Activity.CheckActivityRed(v) then
                return true
            end
        end
    end
end

---判断终身模式，是否需要显示 (针对短签,返利)
---@param tbConf table 活动配置
function Activity.CheckLifelong(tbConf)
    if not tbConf then
        return true
    end

    --获取所有奖励前 是否展示
    if tbConf.sClass == "recharge" then
        return RechargeLogic.CheckShow(tbConf)
    end

    --终身模式 始终显示 0始终显示 1有奖励 显示/无 隐藏
    if tbConf.nLifelong == 0 then
        return true
    end

    --获取所有奖励后
    if tbConf.sClass == "signin_monthly" then
        return Sign.CheckEnd(tbConf)  --true 有奖励
    elseif tbConf.sClass == "first_recharge" then
        return Activity.CheckFirstRechargeAward(tbConf.nId)
    end

    return true
end

-- 进入指定id活动界面
function Activity.OpenActicity(nId, ...)
    local conf = Activity.GetActivityConfig(nId)
    if Activity.ClickLockTip(conf) then
        if conf.nModeId == 1011 then
            local tb = GachaTry.GetConfig(nId)
            if tb and tb.sUI and tb.sUI ~= '' then
                UI.Open(tb.sUI, {nActivityId = nId}, ...)
            end
        else
            UI.Open('Activity', nId, ...)
        end
    end
end

-- 首充返利 是否有奖励可以领取
---@param nId integer 活动id
function Activity.CheckFirstRechargeAward(nId)
    if not nId then return false end

    return (me:Charged() > 0 and Activity.GetDiyData(nId, 1) == 0)
end

-----------------------加载配置-------------------------
--- 加载活动配置
function Activity.LoadActivitiesConfig()
    Activity.tbConfig = {}
    Activity.tbClassConfig = {}
    Activity.tbModelGroup = {}
    local tbFile = LoadCsv('activity/activities.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nId       = tonumber(tbLine.Id) or 0;
        local nCoverage = tonumber(tbLine.Coverage)
        if nId > 0 and nId <= 6550 and CheckCoverage(nCoverage) then
            local tbInfo    = {
                nId         = nId,
                nIndex     = tonumber(tbLine.Index) or 9999,
                sClass      = tbLine.Class or "activity_base",
                tbCondition         = Eval(tbLine.Condition) or {},
                nModeId     = tonumber(tbLine.ModeId) or 0,
                nGroupId    = tonumber(tbLine.GroupId) or 0,
                nBg         = tonumber(tbLine.BG) or 0,
                nTitleIcon  = tonumber(tbLine.TitleIcon) or 0,
                sTitleDes   = tbLine.TitleDes,
                tbDaily   = Eval(tbLine.Daily) or {},
                tbWeekly   = Eval(tbLine.Weekly) or {},
                tbNormal   = Eval(tbLine.Normal) or {},
                tbCashId   = Eval(tbLine.CashID) or {},
                tbCustomData = Eval(tbLine.CustomData) or {},
                sGotoUI             = tbLine.GotoUI,
                tbUIParam           = Eval(tbLine.tbParam) or {},
                nTitle  = tonumber(tbLine.TitleImg) or 0,
                nImgPic = tonumber(tbLine.ImgPic) or 0,
                tbDes   = Split(tbLine.ContentDes, ","),
                nHide   = tonumber(tbLine.Hide) or 0,
                tbUnlockDaily   = Eval(tbLine.UnlockDaily) or {},
                nLifelong   = tonumber(tbLine.Lifelong) or 0,
                nCoverage = nCoverage,
            };

            tbInfo.nStartTime  = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), tbInfo, "nStartTime")
            tbInfo.nEndTime    = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), tbInfo, "nEndTime")

            Activity.tbConfig[nId] = tbInfo;

            if tbInfo.sClass then
                Activity.tbClassConfig[tbInfo.sClass] = tbInfo;
            end

            if tbInfo.nGroupId > 0 and tbInfo.nHide == 0 then --不显示的不加入组别
                Activity.tbModelGroup[tbInfo.nGroupId] = Activity.tbModelGroup[tbInfo.nGroupId] or {}
                table.insert(Activity.tbModelGroup[tbInfo.nGroupId], tbInfo)
            end
        end
    end
    print('Load ../settings/activity/activities.txt');
end

--获取活动列表
---@param nId integer 活动id
---@return table 活动配置表
function Activity.GetActivityConfig(nId)
    if not nId then return end

    return Activity.tbConfig[nId]
end

--获取同类的所有活动
---@param sClass string 活动类名
---@return table 活动配置列表
function Activity.GetConfigByClassName(sClass)
    if not sClass then return end

    return Activity.tbClassConfig[sClass]
end

--- 获取所有组别
function Activity.GetAllGroup()
    return Activity.tbModelGroup
end

-- 检查是否按日解锁任务
-- return 0错误 1 锁定 2解锁
function Activity.CheckUnlockDailyQuest(tbConfig, nQuestId)
    if not tbConfig or not nQuestId then return 0 end

    if #tbConfig.tbUnlockDaily == 0 then
        return 0
    end

    local timestr = string.format("%s0400", os.date("%Y%m%d", tbConfig.nStartTime))
    local nStartTime = ParseTime(timestr)
    local nNowTime = GetTime()
    local nUnlock = math.floor((GetTime() - nStartTime) / 86400)

    for _,tbInfo in ipairs(tbConfig.tbUnlockDaily) do
        local nDisDay = 0
        for i,v in ipairs(tbInfo) do
            if i == 1 then
                nDisDay = v
            elseif i > 1 and v == nQuestId and nDisDay > 0 then
                if nNowTime < (nStartTime + (nDisDay - 1) * 86400) then
                    return 1, nDisDay-nUnlock
                else
                    return 2
                end
            end
        end
    end

    return 0
end

--- 获取排序后的组别
function Activity.GetSortAllGroup()
    if not Activity.tbModelGroup then return {} end

    local tbSort = {}
    for key, tbConfigList in pairs(Activity.tbModelGroup) do
        local tbGetInfo = {0,0}
        for j,v in ipairs(tbConfigList) do
            if Activity.IsOpen(v.nId) and Activity.CheckLifelong(v) then
                if tbGetInfo[1] == 0 then
                    tbGetInfo = {v.nGroupId, v.nIndex}
                elseif v.nIndex < tbGetInfo[2] then
                    tbGetInfo = {v.nGroupId, v.nIndex}
                elseif v.nIndex == tbGetInfo[2] and v.nGroupId < tbGetInfo[1] then
                    tbGetInfo = {v.nGroupId, v.nIndex}
                end
            end
        end

        if tbGetInfo[1] > 0 then
            table.insert(tbSort, tbGetInfo)
        end
    end

    table.sort(tbSort, function(a, b)
        if a[2] == b[2] then
            return a[1] < b[1]
        end
        return a[2] < b[2]
    end)

    return tbSort
end

--- 获取组别下的条目
---@param InGroup integer 组别
---@return table 活动case
function Activity.GetCaseByGroup(nGroup)
    if not nGroup then return end
    local tbAll = Activity.tbModelGroup[nGroup]
    if not tbAll then return tbAll end

    local tbSort = {}
    for key, value in ipairs(tbAll) do
        if Activity.IsOpen(value.nId) and Activity.CheckLifelong(value) then
            table.insert(tbSort, value)
        end
    end

    table.sort(tbSort, function(a, b)
        if a.nIndex == b.nIndex then
            return a.nId < b.nId
        end
        return a.nIndex < b.nIndex
    end)
    return tbSort
end

--- 多条目模板获取子条目状态
---@param InGroup integer 组
---@param InId integer 子Id
---@return table 条目状态
function Activity.GetCase(nGroup, nId)
    if not nGroup or nId then return end

    for key, value in pairs(Activity.tbModelGroup[nGroup]) do
        if value.nId == nId then
            return value
        end
    end
end

---按每日未完成 -》按每周未完成 -》一次性未完成-》未解锁(可能有)-》每日完成->>每周完成->>一次性完成
---@param nActivityId integer 活动id
---@return boolean 返回是否完成
function Activity.GetQuestList(nActivityId)
    local tbConfig = Activity.GetActivityConfig(nActivityId)
    if not tbConfig then
        return
    end

    local tbAllList = {}
    local tbFinished = {}
    local tbReceived = {}
    local tbLocked = {}
    for i, questId in ipairs(tbConfig.tbDaily) do --每日任务
        local tbQuest = Achievement.CheckConfig(questId, true)
        if tbQuest and Achievement.IsPreFinished(tbQuest) then
            if Achievement.IsReceive(tbQuest) then
                table.insert(tbReceived, {1, tbQuest})
            elseif Achievement.IsFinished(tbQuest) then
                table.insert(tbFinished, 1, {1, tbQuest})
            else
                table.insert(tbAllList, {1, tbQuest})
            end
        end
    end

    for i, questId in ipairs(tbConfig.tbWeekly) do --每周任务
        local tbQuest = Achievement.CheckConfig(questId, true)
        if tbQuest and Achievement.IsPreFinished(tbQuest) then
            if Achievement.IsReceive(tbQuest) then
                table.insert(tbReceived, {2, tbQuest})
            elseif Achievement.IsFinished(tbQuest) then
                table.insert(tbFinished, 1, {2, tbQuest})
            else
                table.insert(tbAllList, {2, tbQuest})
            end
        end
    end

    for i, questId in ipairs(tbConfig.tbNormal) do --一次性任务
        local tbQuest = Achievement.CheckConfig(questId, true)
        if tbQuest and Achievement.IsPreFinished(tbQuest) then
            local nRet, nLockDay = Activity.CheckUnlockDailyQuest(tbConfig, questId)
            if nRet == 1 then --锁定 按 日开放
                table.insert(tbLocked, {3, tbQuest, nLockDay})
            elseif Achievement.IsReceive(tbQuest) then
                table.insert(tbReceived, {3, tbQuest})
            elseif Achievement.IsFinished(tbQuest) then
                table.insert(tbFinished, 1, {3, tbQuest})
            else
                table.insert(tbAllList, {3, tbQuest})
            end
        end
    end

    for i,v in ipairs(tbFinished) do
        table.insert(tbAllList, 1, v)
    end

    for i,v in ipairs(tbLocked) do
        table.insert(tbAllList, v)
    end

    for i,v in ipairs(tbReceived) do
        table.insert(tbAllList, v)
    end

    return tbAllList
end

--获取代币id列表
---@param nActivityId integer 活动id
function Activity.GetCashList(nActivityId)
    if not nActivityId then return end

    local tbConfig = Activity.GetActivityConfig(nActivityId)
    if not tbConfig then return end

    return tbConfig.tbCashId
end

--- 加载活动模板配置
function Activity.LoadTemplateConfig()
    local tbFile = LoadCsv('activity/activitytemplate.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nId       = tonumber(tbLine.ModeId) or 0;
        if nId > 0 then
            local tbInfo    = {
                 nId     = nId,
                sPath   = tbLine.Path,
                nBg     = tonumber(tbLine.BG) or 0,
            };
            Activity.tbTemplate[nId] = tbInfo;
        end
    end

    print('Load ../settings/activity/activitytemplate.txt');
end

--获取tbTemplate配置信息
---@param nModeId integer 模板id
function Activity.GetTemplate(nModeId)
    if not nModeId then return end

    return Activity.tbTemplate[nModeId]
end

--获取tbTemplate配置信息
---@param nActivityId integer 活动id
function Activity.GetTemplateByActivityId(nActivityId)
    if not nActivityId then return end
    local tbConfig = Activity.GetActivityConfig(nActivityId)
    if not tbConfig then return end

    return Activity.tbTemplate[tbConfig.nModeId], tbConfig.nModeId
end

-- 创建Items
function Activity.LoadCaseItem(InPath)
    if not InPath then return end
    local Widget= LoadUI(UE4.UKismetSystemLibrary.MakeSoftClassPath(InPath))
    if not Widget then
        print(string.format("check->%s",InPath))
    end
    return Widget
end

--- 加载活动介绍图配置
function Activity.LoadHelpImagesConfig()
    Activity.tbHelpImages = {}
    local tbFile = LoadCsv('activity/helpimages.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID)
        if nID then
            local temp = Activity.tbHelpImages[nID] or {}
            temp.bShowPage = temp.bShowPage or tonumber(tbLine.ShowPage or 0) > 0
            temp.bLoop = temp.bLoop or tonumber(tbLine.Loop or 0) > 0
            temp.nChangeMode = temp.nChangeMode or tonumber(tbLine.ChangeMode) or 0
            temp.tbPage = temp.tbPage or {}
            local page = {Path = tonumber(tbLine.Path) or 0, Title = tbLine.Title, Caption = tbLine.Caption, tbCondition = Eval(tbLine.Condition) or {}}
            table.insert(temp.tbPage, page)
            Activity.tbHelpImages[nID] = temp
        end
    end
    print('Load activity/helpimages.txt');
end
---检查介绍图界面是否能打开
---@param id integer 配置ID
function Activity.CheckOpen(id)
    local tbcfg = Activity.tbHelpImages[id]
    if not tbcfg or not tbcfg.tbPage then return false end

    local tbPage = {}
    for _, Page in pairs(tbcfg.tbPage) do
        if Condition.Check(Page.tbCondition) then
            table.insert(tbPage, Page)
        end
    end
    return #tbPage > 0
end

----活动相关
--遍历所有没有开放的列表
function Activity.DoCheckOpenList()
    for nId,_ in pairs(Activity.tbConfig) do
        Activity.IsOpen(nId)
    end
end

--查问服务器活动是否开启，以及相应处理
--本地时间已经开启了 判断服务器记录时间是否开启
--如果服务器记录未开启，请求开启
function Activity.Quest_Refresh(tbConf)
    if not tbConf then return true end

    local nSendTime = Activity.tbRefreshList[tbConf.nId] or GetTime()
    if nSendTime > GetTime() then return true end --已经询问到服务器还没返回

    if tbConf.nStartTime == -1 and Activity.GetOpenTime(tbConf.nId) == 1  then
        return
    elseif Activity.GetOpenTime(tbConf.nId) == tbConf.nStartTime then
        return
    end

    Activity.tbRefreshList[tbConf.nId] = GetTime() + 30 --防止一直询问 30秒一次
    me:CallGS("Activity_Refresh", json.encode({nId = tbConf.nId}))
    return true
end

--获取活动任务奖励
---@param tbParam table {nId(活动id 必须),nType(每个活动内部类型 非必须 目前签到分1和2), nQuestId(成就任务类型 任务id)}
function Activity.Quest_GetAward(tbParam, bCDCheck)
    if not tbParam then return end

    if bCDCheck and tbParam.nId then
        local nSendTime = Activity.tbAwardCDList[tbParam.nId] or GetTime()
        if nSendTime > GetTime() then return end --已经询问到服务器还没返回

        Activity.tbAwardCDList[tbParam.nId] = GetTime() + 30 --防止一直询问 30秒一次
    end

    me:CallGS("Activity_GetAward", json.encode(tbParam))
end

--更新红点
---@param nId integer (活动id 必须)
---@param nType integer(nil or 0红点 默认 1new标记)
function Activity.Quest_Flag(nId, nType)
   -- print("Quest_Flag--", nId, nType, Activity.CheckQuestRed(nId))
    if not nId then return end

    if not Activity.CheckQuestRed(nId) then
        return
    end

    local tbParam = {nId = nId, nType = nType or 0}
    me:CallGS("Activity_Flag", json.encode(tbParam))
end

---开启活动
function Activity.DoOpenActivity(tbParam)
    if not tbParam then return end

    local nActivityId = tonumber(tbParam.nId)
    if not nActivityId then return end

    local tbConf = Activity.GetActivityConfig(nActivityId)
    if not tbConf then return end

    for k,v in pairs(tbParam) do
        if tbConf[k] then
            tbConf[k] = v
        end
    end

    if type(tbParam.nStartTime) == "string" then
        local nStartTime  = ParseTime(tbParam.nStartTime)
        if nStartTime > 0 then
            tbConf.nStartTime = nStartTime
        end
    end

    if type(tbParam.nEndTime) == "string" then
        local nEndTime    = ParseTime(tbParam.nEndTime)
        if nEndTime > 0 then
            tbConf.nEndTime = nEndTime
        end
    end
end

s2c.Register('ActivityQuest_Refresh',function(tbParam)
    if tbParam and tbParam.nId and Activity.tbRefreshList then
        Activity.tbRefreshList[tbParam.nId] = nil
    end
end);

s2c.Register('ActivityQuest_GetReward',function(tbParam)
    if tbParam and tbParam.nId and Activity.tbAwardCDList then
        Activity.tbAwardCDList[tbParam.nId] = nil
    end

    local sUI = UI.GetUI("Activity")
    if sUI then
        sUI:OnReceiveUpdate(tbParam)
    end
end);

s2c.Register('ActivityQuest_Flag',function(tbParam)
    local sUI = UI.GetUI("Activity")
    if sUI then
        sUI:OnReceiveUpdate(tbParam)
    end
end);

s2c.Register('ActivityQuest_Open',function(tbParam)
    Activity.DoOpenActivity(tbParam)
end);

----初始化
function Activity._OnInit()
    Activity.LoadActivitiesConfig()
    Activity.LoadTemplateConfig()
    Activity.LoadHelpImagesConfig()

    EventSystem.On(Event.CustomAttr, function(gid, sid, value)
        if gid ~= ChapterLevel.GID then --主线通关后
            return
        end

        Activity.DoCheckOpenList()
    end)

    EventSystem.On(Event.LevelUp, function(nNewLevel, nOldLevel);
        Activity.DoCheckOpenList()
    end)
end

Activity._OnInit()
return Activity