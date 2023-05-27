-- ========================================================
-- @File    : Achievement/Achievement_DLC.lua
-- @Brief   : DLC任务成就系统
-- ========================================================

-- 任务成就系统
---@class AchievementDLC
AchievementDLC = AchievementDLC or {}

--- 自定义属性变量组
AchievementDLC.GroupID    = 14         --任务系统GID

--构建新id 唯一性
AchievementDLC.MAKE_ID_PARAM = 100;

---加载配置
function AchievementDLC.LoadConfig()
    AchievementDLC.LoadConf()
end


---加载DLC活动成就配置
function AchievementDLC.LoadConf()
    AchievementDLC.tbConfig = {}
    AchievementDLC.tbGroupConfig = {}
    local tbFile = LoadCsv('dlc/dlc_mission.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.MissionID)
        local nCoverage = tonumber(tbLine.Coverage) or 0
        if nId and CheckCoverage(nCoverage) then
            local cfg = {
                nGroupId            = AchievementDLC.GroupID,
                nId                 = nId,
                nGroup              = tonumber(tbLine.GroupID),
                sGroupDes           = tbLine.GroupDes,
                sName               = tbLine.Name,
                sDescribe           = tbLine.Describe,
                nIcon               = tonumber(tbLine.Icon),
                nPriority           = tonumber(tbLine.Priority or 0),
                tbCondition         = Eval(tbLine.Condition) or {},
                nPreId              = tonumber(tbLine.PreID),
                nReceivedShow       = tonumber(tbLine.ReceivedShow or 0),
                nType               = tonumber(tbLine.Type),
                nCheckValue         = tonumber(tbLine.CheckValue or 1),
                tbParam             = Eval(tbLine.Param) or {},
                nFinishLimit        = tonumber(tbLine.FinishLimit),
                tbRewards           = Eval(tbLine.Rewards) or {},
                nFunctionID         = tonumber(tbLine.FunctionID) or 0,
                sGotoUI             = tbLine.GotoUI,
                tbUIParam           = Eval(tbLine.tbParam) or {},
                sConditionGoto      = tbLine.ConditionGoto,
                tbActivityId        = Eval(tbLine.ActivityID) or {},
                nAchievementPoint   = tonumber(tbLine.AchievementPoint) or 0,

                nRefreshRule        = tonumber(tbLine.RefreshRule) or 0,
                tbSelectRule        = Eval(tbLine.SelectRule) or {},
                nWeight             = tonumber(tbLine.Weight) or 0,
                nCoverage          = nCoverage,
            }

            cfg.nStartTime      = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), cfg, "nStartTime")
            cfg.nEndTime        = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), cfg, "nEndTime")

            local MakeId = nId * AchievementDLC.MAKE_ID_PARAM + AchievementDLC.GroupID
            AchievementDLC.tbConfig[MakeId] = cfg;

            if cfg.nGroup then
                AchievementDLC.tbGroupConfig[cfg.nGroup] = AchievementDLC.tbGroupConfig[cfg.nGroup] or {}
                table.insert(AchievementDLC.tbGroupConfig[cfg.nGroup], cfg)
            end
        end
    end
end

---得到某个任务配置
---@param nId integer 任务ID
---@return table 返回对应的配置，未找到或不满足条件则返回空
function AchievementDLC.GetConfig(nId)
    if not nId then return end

    local nMakdId = nId * AchievementDLC.MAKE_ID_PARAM + AchievementDLC.GroupID
    local tbConfig = AchievementDLC.tbConfig[nMakdId];
    if not tbConfig then return end

    return tbConfig;
end

function AchievementDLC.GetGroupConf(groupId)
    return AchievementDLC.tbGroupConfig[groupId]
end

---奖励领取情况
---@param tbCfg integer or table 任务ID or 配置表table
---@return integer 0未达成STATUS_NOT 1完成未领取STATUS_CAN  2已领取STATUS_GOT
function AchievementDLC.CheckAchievementReward(tbCfg)
    local tbConfig = nil
    if type(tbCfg) == "table" then
        tbConfig = tbCfg
    elseif type(tbCfg) == "number" then
        tbConfig = AchievementDLC.GetConfig(tbCfg)
    end

    if not tbConfig then return Achievement.STATUS_NOT end

    if Achievement.IsReceive(tbConfig) then
        return Achievement.STATUS_GOT
    end
    if Achievement.IsFinished(tbConfig) then
        return Achievement.STATUS_CAN
    end
    return Achievement.STATUS_NOT
end

---得到任务的进度和总进度
---@param tbCfg integer or table 任务ID or 配置表table
---@return integer 进度的分子，错误返回空
---@return integer 进度的分母
function AchievementDLC.GetProgresAndSum(tbCfg)
    local tbConfig = nil
    if type(tbCfg) == "table" then
        tbConfig = tbCfg
    elseif type(tbCfg) == "number" then
        tbConfig = AchievementDLC.GetConfig(tbCfg)
    end

    if not tbConfig then return 0, 0 end

    local v = Achievement.GetProgres(tbConfig.nGroupId, tbConfig.nId)
    if v > tbConfig.nCheckValue then
        v = tbConfig.nCheckValue
    end
    return v, tbConfig.nCheckValue
end

---跳转到目标界面
---@param tbCfg integer or table 任务ID or 配置表table
function AchievementDLC.GoToUI(tbCfg)
    local tbConfig = nil
    if type(tbCfg) == "table" then
        tbConfig = tbCfg
    elseif type(tbCfg) == "number" then
        tbConfig = AchievementDLC.GetConfig(tbCfg)
    end

    if not tbConfig then return end

    if tbConfig.nFunctionID > 0 then
        local bUnlock, tbTip = FunctionRouter.IsOpenById(tbConfig.nFunctionID)
        if not bUnlock then return UI.ShowTip(Text(tbTip[1] or '')) end

        if tbConfig.nFunctionID == 1 and #tbConfig.tbUIParam >= 3 then --关卡 暂时都是主线
            local tbLevelCfg = Chapter.GetChapterCfg(true, tbConfig.tbUIParam[2], tbConfig.tbUIParam[3])
            if not tbLevelCfg then
                UI.ShowTip("tip.Level_Lock")
                return false
            end

            local bUnLock, tbDes = Condition.Check(tbLevelCfg.tbCondition)
            if not bUnLock then
                UI.ShowTip("tip.Level_Lock")
                return false
            end
        end
    end

    if tbConfig.sGotoUI then
        UI.Open(tbConfig.sGotoUI, table.unpack(tbConfig.tbUIParam))
    elseif tbConfig.sConditionGoto then
        local fun = Eval(tbConfig.sConditionGoto)
        if fun then fun(table.unpack(tbConfig.tbUIParam)) end
    end
end

---领取任务奖励
---@param nId integer 任务id
function AchievementDLC.GetReward(nId, pCallBack)
    if (not nId) or nId <= 0 then
        return UI.ShowMessage('error.BadParam');
    end

    local tbConfig = AchievementDLC.GetConfig(nId);
    if not tbConfig then return UI.ShowMessage('error.BadParam'); end

    -- 检查是否已领取
    if Achievement.IsReceive(tbConfig) then
        return UI.ShowMessage('achievement.RewardGeted');
    end

    -- 检查是否已经完成
    if not Achievement.IsFinished(tbConfig) then
        return UI.ShowMessage('achievement.NotFinished');
    end

    Achievement.DoLevelUpCacheLevel()
    AchievementDLC.pRewardCallBack = pCallBack

    -- 领取奖励
    me:CallGS("AchievementDLC_GetReward", json.encode({nId = nId}))
end

function AchievementDLC.QuickGetReward(tbId, pCallBack)
    local tbGetId = {}
    for _, nId in ipairs(tbId) do
        local tbConfig = AchievementDLC.GetConfig(nId)
        if tbConfig and not Achievement.IsReceive(tbConfig) and Achievement.IsFinished(tbConfig) then
            table.insert(tbGetId, nId)
        end
    end
    AchievementDLC.pQuickCallBack = pCallBack

    -- 领取奖励
    me:CallGS("AchievementDLC_QuickGetReward", json.encode({tbIdList = tbGetId}))
end

--------------------注册回调
-- 领取奖励后供服务端调用的回调
s2c.Register('AchievementDLC_GetReward',function(tbParam)
    if AchievementDLC.pRewardCallBack then
        AchievementDLC.pRewardCallBack(tbParam)
        AchievementDLC.pRewardCallBack = nil
    end
end)

-- 领取奖励后供服务端调用的回调
s2c.Register('AchievementDLC_QuickGetReward',function(tbParam)
    --整合奖励
    local tbAllAward = {}
    if tbParam and tbParam.tbRewards then
        for i,v in ipairs(tbParam.tbRewards) do
            for k,tbInfo in ipairs(v) do
                table.insert(tbAllAward, tbInfo)
            end
        end
    end

    tbParam.tbRewards = tbAllAward
    if AchievementDLC.pQuickCallBack then
        AchievementDLC.pQuickCallBack(tbParam)
        AchievementDLC.pQuickCallBack = nil
    end
end)

AchievementDLC.LoadConfig()