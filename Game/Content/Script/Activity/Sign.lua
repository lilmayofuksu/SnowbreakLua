-- ========================================================
-- @File    : Sign.lua
-- @Brief   : 签到活动相关接口
-- ========================================================

---@class Sign 活动数据管理
Sign = Sign or{}

--目前签到活动只能顺序签到
--活动自定义数据存储信息
--1号位 存储当前签到活动 签到第几天
Sign.SignTag_TaskId = 1
--2号位  当日签到标记   0未签到 1服务器发送物品 2客户端已展示
Sign.SignDay_TaskId = 2

Sign.AWARD_TYPE_DAY             = 1         --- 每日签到
Sign.AWARD_TYPE_AMOUNT          = 2         --- 短签

Sign.tbShrotUI = {
    [1002] = "ShortSign",
    [1006] = "WeekSign1",
    [1008] = "WeekSign2",
    [1014] = "WeekSign3",
}

--加载配置表
--- 加载日签奖励
function Sign.LoadSignDaysConfig()
    Sign.tbRewardDays = {}
    local tbFile = LoadCsv('activity/sign/signday.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nActivityId = tonumber(tbLine.ActivityId) or 0
        if nActivityId > 0 then
            local tbReward={
                nDayId        = tonumber(tbLine.DayId) or 0,
                tbReward   = Eval(tbLine.SignReward) or {},
            }

            Sign.tbRewardDays[nActivityId] = Sign.tbRewardDays[nActivityId] or {}
            Sign.tbRewardDays[nActivityId][tbReward.nDayId] = tbReward
        end
    end

    print('Load ../activity/sign/signday.txt');
end

-- 短签奖励
function Sign.LoadShortSignReward()
    Sign.tbSignShortReward = {}
    local tbFile = LoadCsv('activity/sign/signshort.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nActivityId = tonumber(tbLine.ActivityId) or 0
        if nActivityId > 0 then
            local tbReward={
                nDayId = tonumber(tbLine.DayId) or 0,
                nSpe = tonumber(tbLine.Special or nil) ,
                sCol = tbLine.Color or nil,
                tbpData = Eval(tbLine.SignReward) or {},
                sTips = tbLine.Notice,
                param1 = tonumber(tbLine.Param1),
                param2 = tonumber(tbLine.Param2)
            }

            Sign.tbSignShortReward[nActivityId] = Sign.tbSignShortReward[nActivityId] or {}
            Sign.tbSignShortReward[nActivityId][tbReward.nDayId] = tbReward
         end
    end

    print('Load ../activity/sign/signshort.txt')
end

--获取签到奖励
---@param nId integer 奖励id
---@return table 配置列表
function Sign.GetSignConfig(nId)
    if not nId then return end

    return Sign.tbRewardDays[nId]
end

--获取短签奖励
---@param nId integer 奖励id
---@return table 配置列表
function Sign.GetShortSignConfig(nId)
    if not nId then return end

    return Sign.tbSignShortReward[nId]
end

--获取奖励配置
function Sign.GetRewardConfig(nId)
    if not nId then return end

    local tbReward = Sign.GetSignConfig(nId)
    if tbReward then
        return tbReward
    end

    return Sign.GetShortSignConfig(nId)
end

--获取当前月份的天数
function Sign.GetMonthDayNum()
    local nTime = GetTime() - 14400 --减去四个小时
    local year,month = os.date("%Y", nTime), os.date("%m",nTime)+1 -- 正常是获取服务器给的时间来算
    local dayAmount = os.date("%d", os.time({year=year, month=month, day=0})) -- 获取当月天数
    return tonumber(dayAmount)
end

--获取签到类型当前开放的活动列表
---@param bShort bool 是否短签
---@return table 活动配置列表
function Sign.GetSignConfigList(bShort)
    local tbList = {}
    local tbReward = nil
    if bShort then
        tbReward = Sign.tbSignShortReward
    else
        tbReward = Sign.tbRewardDays
    end

    if not tbReward then return tbList end

    for nId,_ in pairs(tbReward) do
        if Activity.IsOpen(nId) then
            table.insert(tbList, nId)
        end
    end

    return tbList
end

--- 获取签到天数
---@param nId integer 活动ID
---@return  integer 活动签到天数
function Sign.GetSginTag(nId)
    local tbConfig = Activity.GetActivityConfig(nId)
    if not tbConfig then return 0 end

   return Activity.GetDiyData(tbConfig.nId, Sign.SignTag_TaskId)
end

--- 检查当日签到状态
---@param nId integer 活动ID
---@return  integer 活动id
function Sign.GetSginDayStatus(nId)
    local tbConfig = Activity.GetActivityConfig(nId)
    if not tbConfig then return 0 end

   return Activity.GetDiyData(tbConfig.nId, Sign.SignDay_TaskId)
end

--检查签到是否已经完成
function Sign.CheckEnd(tbConfig)
    if not tbConfig then return false, 'tip.congig_reward_err' end

    ---检查奖励
    local tbReward = Sign.GetRewardConfig(tbConfig.nId)
    if not tbReward then
        return false, 'tip.congig_reward_err'
    end

    local nDay = Sign.GetSginTag(tbConfig.nId) or 0
    if Sign.GetSginDayStatus(tbConfig.nId) == 0 or Sign.GetSginDayStatus(tbConfig.nId) == 3 then
        nDay = nDay + 1
    end

    --已经完成所有签到
    if tbReward[nDay] then
        return true
    end

    if nDay > #tbReward then
        return false
    end

    return false, 'tip.congig_reward_err'
end

-- 检查是否会有弹出界面 (日签，短签)
---@param bOpen bool 是否打开界面
function Sign.CheckOpen(bOpen)
    Sign.tbSignState = Sign.tbSignState or {}
    local function GetSignTag(sSignTye, sParam)
        return string.format('%s%s%s', me and me:Id() or 0, sSignTye, sParam)
    end


    --签到
    local tbSignList = Sign.GetSignConfigList()
    if tbSignList and #tbSignList > 0 then
        for i,v in ipairs(tbSignList) do
            local nRet = Sign.GetSginDayStatus(v)
            local tbConfig = Activity.GetActivityConfig(v)
            --print("CheckOpen", v, Sign.GetSginDayStatus(v) , bOpen, nRet)
            if tbConfig and not Sign.CheckEnd(tbConfig) then
                nRet = 2
            end

            if nRet == 0 then
                if tbConfig then
                    Activity.Quest_Refresh(tbConfig)
                end
            end
            
            --客户端缓存ui打开状态  优化弱网状态重复弹窗
            local sTag = GetSignTag(Event.SignDay, v)
            if Sign.tbSignState[sTag] then
                nRet = 2
            end

            if nRet < 2 then --服务器活动已开启    
                if bOpen then
                    EventSystem.Trigger(Event.SignDay, v)
                    Sign.tbSignState[sTag] = true
                end
                return true
            end
        end
    end

    --短签
    tbSignList = Sign.GetSignConfigList(true)
    if tbSignList and #tbSignList > 0 then
        for i,v in ipairs(tbSignList) do
            local nRet = Sign.GetSginDayStatus(v)
            local tbConfig = Activity.GetActivityConfig(v)
           --print("CheckOpen22", v, Sign.GetSginDayStatus(v) , bOpen, nRet)
            if tbConfig and not Sign.CheckEnd(tbConfig) then
                nRet = 2
            end

            if nRet == 0 then
                if tbConfig then
                    Activity.Quest_Refresh(tbConfig)
                end
            end

            --客户端缓存ui打开状态  优化弱网状态重复弹窗
            local sTag = GetSignTag(Event.ShortSign, v)
            if Sign.tbSignState[sTag] then
                nRet = 2
            end

            if nRet < 2 then
                if bOpen then
                    EventSystem.Trigger(Event.ShortSign, v)
                    Sign.tbSignState[sTag] = true
                end
                return true
            end
        end
    end

    return false
end

--- 日签到请求
Sign.DaySignCallBack = nil
---@param InCallBack  function 回调函数
function Sign.Req_SignDay(InParam,InCallBack)
    local tbConfig = Activity.GetActivityConfig(InParam.Id)
    --print("InParam.Id", InParam.Id, tbConfig)
    if not Activity.ClickLockTip(tbConfig) then
        return
    end

    ---检查奖励
    local nRet,szMsg = Sign.CheckEnd(tbConfig)
    local tbReward = Sign.GetSignConfig(tbConfig.nId)
    if not nRet then
        if szMsg then
            UI.ShowTip(szMsg)
        end
        return 
    end

    --- 检查当前是否已经签到
    if Sign.GetSginDayStatus(InParam.Id) > 1 then
        return UI.ShowTip('tip.today_alreaded_signed')
    end

    --活动没开始
    if Activity.GetOpenTime(tbConfig.nId) == 0 then
        Activity.Quest_Refresh(tbConfig)
        return
    end

    ---GId:活动Id(=1:签到)
    local cmd = {
        nId            = InParam.Id,
        nType       = Sign.AWARD_TYPE_DAY,        -- 活动类型
    }
    -- Dump(cmd)
    Sign.DaySignCallBack = InCallBack

    Activity.Quest_GetAward(cmd)
end

s2c.Register(
    "DaySign",
    function(tbParam)
        if not UI.IsOpen("SignDay") then
            return
        end

        if Sign.DaySignCallBack then
            Sign.DaySignCallBack()
            Sign.DaySignCallBack = nil
        end
        if tbParam.tbRewards then
            Item.Gain(tbParam.tbRewards)
        end
    end
)

--- 短签请求
Sign.ShortSignCallback = nil
function Sign.Req_ShortSign(InParam,InCallBack)
    if InParam.Id < 1 then
        return UI.ShowTip(Text('ui.TxtFinishSign'))
    end

    -- 检查活动
    local tbConfig = Activity.GetActivityConfig(InParam.Id)
    if not Activity.ClickLockTip(tbConfig) then
        return
    end
    
    --- 检查模板
    local TId = tbConfig.nModeId
    if not TId then
        return UI.ShowTip('tip.congig_modeid_err')
    end

    ---检查奖励
    local tbReward = Sign.GetShortSignConfig(tbConfig.nId)
    if not tbReward or not tbReward[Sign.GetSginTag(tbConfig.nId)]  then
        return UI.ShowTip('tip.congig_reward_err')
    end

        ---检查奖励
    local nRet,szMsg = Sign.CheckEnd(tbConfig)
    if not nRet then
        if szMsg then
            UI.ShowTip(szMsg)
        end
        return 
    end

    --- 检查是否重复签到
    if Sign.GetSginDayStatus(InParam.Id) > 1 then
        return UI.ShowTip('tip.re_sign')
    end

    --活动没开始
    if Activity.GetOpenTime(tbConfig.nId) == 0 then
        Activity.Quest_Refresh(tbConfig)
        return
    end

    local cmd = {
        nId            = InParam.Id,
        nType       = InParam.Type,         -- 活动类型
    }
    Sign.ShortSignCallback = InCallBack
    Activity.Quest_GetAward(cmd)
end

s2c.Register(
    "ShortSign",
    function(InParam)
        local nActivityId = InParam and InParam.nId or 0
        local sUI = "ShortSign"
        local _,nTemplateID = Activity.GetTemplateByActivityId(nActivityId)
        if nTemplateID and Sign.tbShrotUI[nTemplateID] then
            sUI = Sign.tbShrotUI[nTemplateID]
        end
        if not UI.IsOpen(sUI) then
            return
        end

        if Sign.ShortSignCallback then
            Sign.ShortSignCallback(InParam)
            Sign.ShortSignCallback = nil
        end
    end
)

--- 公告是否弹出
Sign.MarkActivityTipCallback = nil
function Sign.Req_MarkActivityTip(InMarkSubId,InCallBack)
    local cmd={
        nGId        = Sign.MarkTipGId,
        nSubId      = InMarkSubId,
    }
    Sign.MarkActivityTipCallback = InCallBack
    me:CallGS("Activity_MarkTip",json.encode(cmd))
end

s2c.Register(
    "Activity_MarkTip",
    function()
        if Sign.MarkActivityTipCallback then
            Sign.MarkActivityTipCallback()
            Sign.MarkActivityTipCallback = nil
        end
    end
)

s2c.Register(
    "Activity_Open",
    function(InParam)
        if Sign.ActivityIsOpenHandle then
            Sign.ActivityIsOpenHandle(InParam)
            Sign.ActivityIsOpenHandle = nil
        end
    end
)

--- main 弹窗
function Sign._OnInit()
    Sign.LoadSignDaysConfig()
    Sign.LoadShortSignReward()

    EventSystem.On(
        Event.ActivityNotice,
        function()
            UI.Open("Notice")
        end)

    EventSystem.On(
        Event.SignDay,
        function(nActiveId)
            UI.Open("SignDay", {nActivityId = nActiveId})
        end)

    EventSystem.On(
        Event.ShortSign,
        function(nActiveId)
            local sUI = "ShortSign"
            local _,nTemplateID = Activity.GetTemplateByActivityId(nActiveId)
            if nTemplateID and Sign.tbShrotUI[nTemplateID] then
                sUI = Sign.tbShrotUI[nTemplateID]
            end
            UI.Open(sUI, {nActivityId = nActiveId})
        end)
end

EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    Sign.tbSignState = {}
end)

Sign._OnInit()
return Sign