-- ========================================================
-- @File    : BattlePass/BattlePass.lua
-- @Brief   : 战场通行证
-- ========================================================
BattlePass = BattlePass or {}

--task
BattlePass.nGroupId 	= 25 	--
BattlePass.nCurID 		= 1	--当前期数
BattlePass.nBPStatus	= 2	--通行证购买状态 0、未购买，1、购买初级，2、购买高级
BattlePass.nExp 		= 3	--当前期总经验值
BattlePass.nDailyTaskGetExp	= 4	--每日任务获得经验值  每天清零
BattlePass.nWeeklyTaskGetExp	= 5	--每周任务获得经验值  每周清零
BattlePass.nFirstOpen                        = 11        --每期活动首次打开
BattlePass.NormalAward_Task        = 100        --普通领奖标记-- 当前已领取的等级
BattlePass.AdvanceAward_Task        = 200        --进阶领奖标记-- 当前已领取的等级

--通行证标记
BattlePass.PASS_NONE = 0  --没有
BattlePass.PASS_LEVEL1 = 1  --低级
BattlePass.PASS_LEVEL2 = 2  --高级

--ui显示类型
BattlePass.SHOW_AWARD = 1
BattlePass.SHOW_DAILY = 2
BattlePass.SHOW_WEEKLY = 3
BattlePass.SHOW_NORMAL = 4

--刷新请求CD
BattlePass.Refresh_CD = 30  --秒

--配置表
function BattlePass.LoadConfig()
	BattlePass.LoadTimeListConfig()
	BattlePass.LoadLevelListConfig()
end

--战斗通行证 配置表
function BattlePass.LoadTimeListConfig()
    BattlePass.tbTimeList = {};
    local tbFile = LoadCsv('battlepass/timelist.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID)
        local nCoverage = tonumber(tbLine.Coverage)
        if nId and CheckCoverage(nCoverage) then
            local tb = {}
            tb.nId = nId
            tb.nStartTime = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), tb, "nStartTime")
            tb.nEndTime = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), tb, "nEndTime")
            tb.nBuyStartTime = ParseTime(string.sub(tbLine.BuyStartTime or '', 2, -2), tb, "nBuyStartTime")
            tb.nBuyEndTime = ParseTime(string.sub(tbLine.BuyEndTime or '', 2, -2), tb, "nBuyEndTime")
            tb.tbCondition         = Eval(tbLine.Condition) or {}
            tb.nExpStep = tonumber(tbLine.ExpStep or 0)
            tb.nMaxExPerWeek = tonumber(tbLine.MaxExPerWeek or 0)
            tb.tbMoney = Eval(tbLine.Money) or {}
            tb.tbDaily = Eval(tbLine.Daily) or {}
            tb.tbWeekly = Eval(tbLine.Weekly) or {}
            tb.tbNormal = Eval(tbLine.Normal) or {}
            tb.nPopADImg = tonumber(tbLine.PopADImg) or 0
            tb.sIntro = tbLine.Intro
            tb.tbGiftInfo = Eval(tbLine.GiftInfo) or {}
            tb.tbNpcImgItem = Eval(tbLine.NpcImgItem) or {}
            tb.nBannerName = tonumber(tbLine.BannerName)
            tb.sBannerInfo = tbLine.BannerInfo
            tb.nCoverage = nCoverage

            BattlePass.tbTimeList[tb.nId] = tb
        end
    end
end

function BattlePass.LoadLevelListConfig()
    BattlePass.tbLevelList = {};
    BattlePass.tbMaxLevel = {}
    local tbFile = LoadCsv('battlepass/levellist.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID)
        local nCoverage = tonumber(tbLine.Coverage)
        if nId and CheckCoverage(nCoverage) then
            local tb = {}
            tb.nId = nId
            tb.nLevel = tonumber(tbLine.Level) or 0
            tb.tbNormalAward = Eval(tbLine.NormalAward) or {}
            tb.nNormalSp = tonumber(tbLine.NormalSp) or 0  --特殊展示标记
            tb.tbAdvanceAward = Eval(tbLine.AdvanceAward) or {}
            tb.nAdvanceSp = tonumber(tbLine.AdvanceSp) or 0  --特殊展示标记
            tb.nCoverage = nCoverage

            local tbTempList = BattlePass.tbLevelList[tb.nId];
            if not tbTempList then
                BattlePass.tbLevelList[tb.nId] = {}
                tbTempList = BattlePass.tbLevelList[tb.nId];
            end

            local nTempLevel = BattlePass.tbMaxLevel[tb.nId];
            if not nTempLevel then
                BattlePass.tbMaxLevel[tb.nId] = tb.nLevel
            elseif tb.nLevel > nTempLevel then
                BattlePass.tbMaxLevel[tb.nId] = tb.nLevel
            end

            tbTempList[tb.nLevel] = tb;
        end
    end
end

-- 得到某期配置
function BattlePass.GetConfig(nId)
	if not nId or not BattlePass.tbTimeList[nId] then return end

	return BattlePass.tbTimeList[nId];
end

function BattlePass.IsOpen(tbParam)
    local tbConfig = nil
    if type(tbParam) == "table" then
        tbConfig = tbParam
    elseif type(tbParam) == "number" then
        tbConfig = BattlePass.GetConfig(tbParam)
    end

    if not tbConfig then return  end

    -- 检测限制
    local bUnLock = Condition.Check(tbConfig.tbCondition)
    if not bUnLock then
        return
    end

    -- 检测时间
    if not IsInTime(tbConfig.nStartTime, tbConfig.nEndTime) then
        return
    end

    return tbConfig;
end

-- 得到开启的配置
function BattlePass.GetCurTimeConfig()
    if not BattlePass.tbTimeList then return  end

    local nTime = GetTime();
    for k,v in pairs(BattlePass.tbTimeList) do
        if BattlePass.IsOpen(v) then
            return v
        end
    end
end

-- 得到当前开启的期数
function BattlePass.GetCurTimeId()
    local tbConfig = BattlePass.GetCurTimeConfig();
    if tbConfig then
        return tbConfig.nId
    end
end

--获取最大等级
function BattlePass.GetMaxLevel(nId)
	if not nId or not BattlePass.tbMaxLevel[nId] then
		return 0
	end

	return BattlePass.tbMaxLevel[nId] or 0
end

-- 得到me的配置 bCheck 判断是否当前期
function BattlePass.GetMeConfig()
	local nId = BattlePass.GetPassId()
	if BattlePass.GetCurTimeId() ~= nId then
		BattlePass.DoRefresh()
		return
	end
	
	return BattlePass.GetConfig(nId)
end

--获取当前期数的奖励配置表
function BattlePass.GetLevelAward(nId)
	local tbTimeConfig = nil
	if nId then
		tbTimeConfig = BattlePass.GetConfig(nId)
	else
		tbTimeConfig = BattlePass.GetMeConfig()
	end

	if not tbTimeConfig then return end

	return BattlePass.tbLevelList[tbTimeConfig.nId]
end

--获取对应期数对应等级的配置
function BattlePass.GetLevelConfig(nLevel, nId)
	local tbTempList = BattlePass.GetLevelAward(nId)
	if not tbTempList then
		return
	end

	return tbTempList[nLevel]
end

--获取对应的任务列表
function BattlePass.GetMissionList(nType)
	local tbConfig = BattlePass.GetMeConfig()
	if not tbConfig then return end

	if nType == BattlePass.SHOW_DAILY then
		return tbConfig.tbDaily
	elseif nType == BattlePass.SHOW_WEEKLY then
		return tbConfig.tbWeekly
	elseif nType == BattlePass.SHOW_NORMAL then
		return tbConfig.tbNormal
	end
end

--获取当前期数
function BattlePass.GetPassId()
	return me:GetAttribute(BattlePass.nGroupId, BattlePass.nCurID)
end

--通行证标记
function BattlePass.GetPassFlag()
	return me:GetAttribute(BattlePass.nGroupId, BattlePass.nBPStatus)
end

--是否有通行证
function BattlePass.CheckPass()
	if not me then return end

	local nCurId = BattlePass.GetCurTimeId() or 0;
	if nCurId > 0 and BattlePass.GetPassFlag() > BattlePass.PASS_NONE then
		return true
	end
end

--获取当前经验
function BattlePass.GetCurExp()
    return me:GetAttribute(BattlePass.nGroupId, BattlePass.nExp)
end

--获取当前等级
function BattlePass.GetCurLevel()
	local nCurExp = BattlePass:GetCurExp();
	local tbConfig = BattlePass:GetMeConfig();
	if not tbConfig then return end
	if  tbConfig.nExpStep <= 0 then return end

	local nLevel = math.floor(nCurExp / tbConfig.nExpStep)
	local nLeftExp = nCurExp - nLevel * tbConfig.nExpStep
	if nLeftExp < 0 then
		nLeftExp = 0
	end 

	return math.floor(nCurExp / tbConfig.nExpStep), nLeftExp
end

--获取当周经验
function BattlePass.GetWeeklyExp()
    return me:GetAttribute(BattlePass.nGroupId, BattlePass.nWeeklyTaskGetExp)
end

--获取是否首次打开
function BattlePass.IsFirstOpen()
	return me:GetAttribute(BattlePass.nGroupId, BattlePass.nFirstOpen) == 0
end

--获取 普通 等级奖励
function BattlePass.GetNormalAwardFlag()
	return me:GetAttribute(BattlePass.nGroupId, BattlePass.NormalAward_Task)
end

--获取 高级 等级奖励
function BattlePass.GetAdvanceAwardFlag()
	return me:GetAttribute(BattlePass.nGroupId, BattlePass.AdvanceAward_Task)
end


---检测是否有奖励未领取
function BattlePass.CheckHaveLevelAward()
	local nCurLevel = BattlePass.GetCurLevel() or 0
	if nCurLevel > BattlePass.GetNormalAwardFlag() then
		return true
	elseif BattlePass.CheckPass() and nCurLevel > BattlePass.GetAdvanceAwardFlag() then
		return true
	end

	return false
end

---检测是否有任务未领取
function BattlePass.CheckHaveMissionAward(nType)
	local tbShowList = BattlePass.GetMissionList(nType)
	if not tbShowList then return false end

    for _, nMissionId in ipairs(tbShowList) do
    	local tbMission = Achievement.GetQuestConfig(nMissionId)
        if tbMission and Achievement.IsPreFinished(tbMission) then
            local situation = Achievement.CheckAchievementReward(tbMission)
            if situation == Achievement.STATUS_CAN then
            	return true
            end
        end
    end

	return false
end

--ui检测
function BattlePass.CheckHaveRed(nType)
	if nType == BattlePass.SHOW_AWARD then
		return BattlePass.CheckHaveLevelAward()
	else
		return BattlePass.CheckHaveMissionAward(nType)
	end
end

--检测是否有红点
function BattlePass.CheckMainRed()
	if BattlePass.CheckHaveLevelAward() then
		return true
	end

	for i=BattlePass.SHOW_DAILY,BattlePass.SHOW_NORMAL do
		if BattlePass.CheckHaveMissionAward(i) then
			return true
		end
	end
    return false
end

--检测当周是否已经满经验
function BattlePass.CheckWeeklyExp(tbInfo)
	local tbConfig = tbInfo or BattlePass.GetMeConfig()
	if not tbConfig then return end

	return BattlePass.GetWeeklyExp()  >= tbConfig.nMaxExPerWeek
end

--检测是否有可领取的任务
function BattlePass.CheckGetMissionList(nType)
	local tbList = BattlePass.GetMissionList(nType)
	if not tbList then return end

	local tbCanList = {}
	for i,v in ipairs(tbList) do
		if Achievement.CheckAchievementReward(v, true) == Achievement.STATUS_CAN then
			table.insert(tbCanList, v)
		end
	end

	return tbCanList
end

--打开界面
function BattlePass.OpenUI()
	local openFunc = function()
		local tbConfig = BattlePass.GetMeConfig()
		if not tbConfig then
			UI.ShowTip("tip.BattlePass_Config_error")
			return
		end

		if tbConfig.nPopADImg > 0 and BattlePass.IsFirstOpen() then
			UI.Open("ActivityBP", tbConfig.nPopADImg)
		else
			UI.Open("BPMain")
		end
	end

	FunctionRouter.CheckEx(FunctionType.BattlePass, openFunc)
end

--获取时间格式化  bMin最低取分钟 默认秒
function BattlePass.SecToDay(nTime, bMin)
	nTime = tonumber(nTime)
	if not nTime then return 0,0,0,0 end

    local day  = nTime // 86400
    local hour = (nTime % 86400) // 3600
    local min  = (nTime % 3600) // 60
    local sec  = (nTime % 3600) % 60
    if not bMin then
    	return math.floor(day), math.floor(hour), math.floor(min), math.floor(sec)
    end

    if sec > 0 then
    	min = min + 1
    end

    if min >= 60 then
    	hour = hour + 1
    	min = min - 60
    end

    if hour >= 24 then
    	day = day + 1
    	hour = hour - 24
    end
    return math.floor(day), math.floor(hour), math.floor(min), math.floor(sec)
end

--获取倒计时格式
function BattlePass.GetFormatTime(nTime)
	local nDay, nHour, nMin = BattlePass.SecToDay(nTime, true)
	if nDay >= 7 then
		return string.format("%d%s", math.floor(nDay / 7), Text("ui.TxtTimeWeek"))
	elseif nDay > 0 then
		return string.format("%d%s", nDay, Text("ui.TxtTimeDay2"))
	end

	return string.format(Text("ui.TxtTimeFormat1"), nHour, nMin)
end

--检查任务id是否活动期任务
function BattlePass.CheckQuest(nQuestId)
	local tbConfig = BattlePass.GetMeConfig()
	if not tbConfig then return end

	if not nQuestId then return true end

	for i,v in ipairs(tbConfig.tbDaily) do
		if v == nQuestId then return true end
	end

	for i,v in ipairs(tbConfig.tbWeekly) do
		if v == nQuestId then return true end
	end

	for i,v in ipairs(tbConfig.tbNormal) do
		if v == nQuestId then return true end
	end
end

--判定是否运行购买等级
function BattlePass.CheckBuyLevel(tbConfig)
	tbConfig = tbConfig or BattlePass.GetMeConfig()
	if not tbConfig then 
		return false, "ui.BattlePass_Level_Error"
	end

	-- 尚未获得通行证
    if BattlePass.GetPassFlag() == BattlePass.PASS_NONE then
        return false, "ui.BattlePass_NotGet_BP"
    end

	if BattlePass.GetCurLevel() >= BattlePass.GetMaxLevel(tbConfig.nId) then
        return false, "ui.BattlePass_Level_Max"
    end

    -- 检测时间 提取1个小时不允许购买等级
    if not IsInTime(tbConfig.nStartTime, tbConfig.nEndTime - 3600) then
        return false, "ui.BattlePass_Level_Error"
    end

    return true
end

--获取当前期售卖的bp道具
--按低 高 精英排序
function BattlePass.GetCurBPItemList()
	local tbList = IBLogic.GetBPList(BattlePass.GetPassId())
    if not tbList or #tbList == 0 then return end

    local tbItems = {}
    for i,v in pairs(tbList) do
    	if v.tbParam and #v.tbParam >=2 and v.tbParam[1] == BattlePass.GetPassId() and v.tbParam[2] > 0 then
    		tbItems[v.tbParam[2]] = v
    	end
    end

    return tbItems
end

--获取当前需要显示的奖励等级
function BattlePass.GetAwardShowLevel(tbConfig)
	local nShowLevel = BattlePass.GetNormalAwardFlag()
	tbConfig = tbConfig or BattlePass.GetMeConfig()
	if not tbConfig then return 1 end

	if nShowLevel >= BattlePass.GetMaxLevel(tbConfig.nId) then
		nShowLevel = BattlePass.GetMaxLevel(tbConfig.nId)
		nShowLevel = nShowLevel - 1
	end

	return nShowLevel, bMax
end

--获取下一个特殊奖励
function BattlePass.GetNextSP(tbLevelConfig, tbConfig, bAdv)
	if not tbLevelConfig or not tbConfig then return end

    local doMakeParam = function(tbConfig, nIdx, bAdv) 
        if not tbConfig then return {} end
        nIdx = nIdx or 0
        local tbAward = tbConfig.tbNormalAward
        if bAdv then
            tbAward = tbConfig.tbAdvanceAward
        end

        local tbParam = {G = tbAward[1],D = tbAward[2],P = tbAward[3],L = tbAward[4],N =tbAward[5] or 1}
        tbParam.nLevel = nIdx
        tbParam.bNoLimit = true
        tbParam.bAdv = bAdv
        if bAdv then
            tbParam.bGeted = (nIdx <= BattlePass.GetAdvanceAwardFlag())
            tbParam.bLock = not BattlePass.CheckPass()
        else
            tbParam.bGeted = (nIdx <= BattlePass.GetNormalAwardFlag())
        end

        tbParam.nNormalSp = 0
        tbParam.nAdvanceSp = 0
        if bAdv then
            tbParam.nAdvanceSp = tbConfig.nAdvanceSp
        else
            tbParam.nNormalSp = tbConfig.nNormalSp
        end
        return tbParam
    end

	local tbRet = tbConfig
	for i=tbConfig.nLevel+1,#tbLevelConfig do
		local tbInfo = tbLevelConfig[i]
		if tbInfo.nNormalSp > 0 and not bAdv then
			tbRet = doMakeParam(tbInfo, i)
			break
		elseif tbInfo.nAdvanceSp > 0 and bAdv then
			tbRet = doMakeParam(tbInfo, i, bAdv)
			break
		end
	end

	return tbRet
end

--------------------call gs
--请求领奖
function BattlePass.DoFirstOpen()
	me:CallGS("BattlePassLogic_FirstOpen")
end

--请求刷新
function BattlePass.DoRefresh()
	if BattlePass.RefreshTime then
		if BattlePass.RefreshTime > GetTime() then
			return
		end
	end

	me:CallGS("BattlePassLogic_ClientRefresh")
	BattlePass.RefreshTime = GetTime() + BattlePass.Refresh_CD
end

--请求领奖
function BattlePass.DoGetAward()
	me:CallGS("BattlePassLogic_GetPassAward")
end

--请求领取任务奖励
function BattlePass.DoGetMission(nType, tbList)
	if not tbList then return end

	local tbParam = {
		nType = nType,
		tbIdList = tbList
	}
	me:CallGS("BattlePassLogic_QuickGetReward", json.encode(tbParam))
end

--请求购买等级
function BattlePass.DoBuyLevel(nLevel)
	if not nLevel or nLevel <= 0 then return end

	local tbParam = {
		nLevel = nLevel
	}
	me:CallGS("BattlePassLogic_BuyLevel", json.encode(tbParam))
end

--------------------注册回调
-- 当前期第一次打开
s2c.Register('BattlePassLogic_FirstOpen',function(tbParam)
	local sUI = UI.GetUI("BPMain")
    if not sUI or not sUI:IsOpen() then
        return
    end

    sUI:OnReceiveUpdate(tbParam)
end)

-- 刷新
s2c.Register('BattlePassLogic_ClientRefresh',function(tbParam)
	local sUI = UI.GetUI("BPMain")
    if not sUI or not sUI:IsOpen() then
        return
    end

    sUI:OnReceiveUpdate(tbParam)
end)

-- 领奖
s2c.Register('BattlePassLogic_GetPassAward',function(tbParam)
	local sUI = UI.GetUI("BPMain")
    if not sUI or not sUI:IsOpen() then
        return
    end

    sUI:OnReceiveUpdate(tbParam)
end)

-- 任务奖励
s2c.Register('BattlePassLogic_QuickGetReward',function(tbParam)
	local sUI = UI.GetUI("BPMain")
    if not sUI or not sUI:IsOpen() then
        return
    end

    sUI:OnReceiveUpdate(tbParam)
end)

-- 购买等级
s2c.Register('BattlePassLogic_BuyLevel',function(tbParam)
	local sUI = UI.GetUI("BPMain")
    if not sUI or not sUI:IsOpen() then
        return
    end

    sUI:OnReceiveUpdate(tbParam)
end)

BattlePass.LoadConfig()
