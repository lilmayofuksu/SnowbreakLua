-- ========================================================
-- @File	: Achievement/Achievement_point.lua
-- @Brief	: 成就点数系统
-- ========================================================

---成就点数系统
---@class AchievementPoint
AchievementPoint = AchievementPoint or {
    tbAwards = {}
}

---自定义属性变量组
AchievementPoint.GID = 8;
AchievementPoint.SID_DAILY_POINT        = 1;    -- 日常任务点数记录
AchievementPoint.SID_WEEK_POINT         = 2;    -- 周常任务点数记录
AchievementPoint.SID_DAILY_REWARD_START = 10;   -- 日常任务点数的奖励领取标记起始
AchievementPoint.SID_DAILY_REWARD_END   = 19;   -- 日常任务点数的奖励领取标记终止
AchievementPoint.SID_WEEK_REWARD_START  = 20;   -- 周常任务点数的奖励领取标记起始
AchievementPoint.SID_WEEK_REWARD_END    = 29;   -- 周常任务点数的奖励领取标记终止

---得到对应Attribute子ID
---@param nGroup integer 对应成就任务点数配置的组ID
---@param nIndex integer 点数奖励下标
---@return integer 返回计算出的Attrbute子ID,错误则返回空
function AchievementPoint.GetSid(nGroup, nIndex)
    if nGroup == Achievement.GROUP_DAILY then
        local nSid = AchievementPoint.SID_DAILY_REWARD_START + nIndex - 1;
        if nSid > AchievementPoint.SID_DAILY_REWARD_END then
            return nil;
        else
            return nSid;
        end
    elseif nGroup == Achievement.GROUP_WEEK then
        local nSid = AchievementPoint.SID_WEEK_REWARD_START + nIndex - 1;
        if nSid > AchievementPoint.SID_WEEK_REWARD_END then
            return nil;
        else
            return nSid;
        end
    end
end

---加载任务点数奖励配置
function AchievementPoint.LoadConfig()
    local tbFile = LoadCsv('achievement/point_reward.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nGroup = tonumber(tbLine.Group) or 0;
        local tbInfo = {
            nPoint      = tonumber(tbLine.AchievementPoint) or 0,
            tbRewards   = Eval(tbLine.Rewards),
            nIcon       = tonumber(tbLine.Icon),
            nSec        = tonumber(tbLine.Sec) or 3,
        }

        AchievementPoint.tbAwards[nGroup] = AchievementPoint.tbAwards[nGroup] or {};
        table.insert(AchievementPoint.tbAwards[nGroup], tbInfo);
    end

    for _, tbGroup in pairs(AchievementPoint.tbAwards) do
        table.sort(tbGroup, function (l, r) return l.nPoint < r.nPoint; end);
    end

    print('Load Settings/achievement/point_reward.txt')
end

---得到日常点数
function AchievementPoint.GetDailyPoint()
    return me:GetAttribute(AchievementPoint.GID, AchievementPoint.SID_DAILY_POINT);
end

---得到周常点数
function AchievementPoint.GetWeekPoint()
    return me:GetAttribute(AchievementPoint.GID, AchievementPoint.SID_WEEK_POINT);
end

---得到一组奖励列表
---@param nGroup number 组ID，1-日常，2-周常
---@return tbRewards table 日常或周常的奖励列表，错误返回空
function AchievementPoint.GetRewards(nGroup)
    return AchievementPoint.tbAwards[nGroup]
end

---检查任务点数奖励领取情况
---@param nGroup number 组ID，1-日常，2-周常
---@param nIndex number 领取第几个任务点数奖励
---@return number o未达成 1完成未领取 2已领取
function AchievementPoint.CheckPointReward(nGroup, nIndex)
    if AchievementPoint.tbAwards[nGroup] and AchievementPoint.tbAwards[nGroup][nIndex] then
        local cfg = AchievementPoint.tbAwards[nGroup][nIndex]
        if AchievementPoint.GetPoint(nGroup) >= cfg.nPoint then
            local nSid = AchievementPoint.GetSid(nGroup, nIndex)
            if nSid then
                if me:GetAttribute(AchievementPoint.GID, nSid) > 0 then
                    return 2
                else
                    return 1
                end
            end
        end
    end
    return 0
end

---检查是否有奖励未领取
---@return boolean 是否有奖励可以领取
function AchievementPoint.IsGroupHaveReceive(tbCfg, nGroup)
    if not tbCfg or not nGroup then return end

    local nHavePoint = AchievementPoint.GetPoint(nGroup)
    for nIndex, cfg in pairs(tbCfg) do
        if nHavePoint >= cfg.nPoint then
            local nSid = AchievementPoint.GetSid(nGroup, nIndex)
            if nSid and me:GetAttribute(AchievementPoint.GID, nSid) <= 0 then
                return true
            end
        end
    end
end

---检查是否有奖励未领取
---@return boolean 是否有奖励可以领取
function AchievementPoint.IsHaveReceive(nCheckGroup)
    for nGroup, tbCfg in pairs(AchievementPoint.tbAwards) do
        if not nCheckGroup or nCheckGroup == nGroup then
            if AchievementPoint.IsGroupHaveReceive(tbCfg, nGroup) then
                return true
            elseif nCheckGroup and nCheckGroup == nGroup then
                return false
            end
        end
    end
    return false
end

---领取奖励
---@param nGroup number 组ID，1-日常，2-周常
---@param nIndex number 领取第几个任务点数奖励,非法则报错
function AchievementPoint.GetReward(nGroup, nIndex)
    if (not nIndex) or nIndex <= 0 then
        return UI.ShowMessage("error.BadParam");
    end

    Achievement.DoLevelUpCacheLevel()

    me:CallGS('AchievementPoint_GetReward', json.encode({nGroup = nGroup, nIndex = nIndex}));
end

---得到日常\周常点数
---@param nGroup number 组ID，1-日常，2-周常
function AchievementPoint.GetPoint(nGroup)
        local pointnum = 0
        if nGroup == Achievement.GROUP_DAILY then
            pointnum = AchievementPoint.GetDailyPoint()
        elseif nGroup == Achievement.GROUP_WEEK then
            pointnum = AchievementPoint.GetWeekPoint()
        end

        return pointnum
end

---得到日常\周常点数
---@param nGroup number 组ID，1-日常，2-周常
function AchievementPoint.GetMaxPoint(nGroup)
    local tbConfig = AchievementPoint.GetRewards(nGroup)
    if not tbConfig then
        return
    end

    local nLen = #tbConfig
    if nLen == 0 then
        return
    end

    return tbConfig[nLen].nPoint
end

---得到可一键 领取和未领取的列表
function AchievementPoint.GetQuickRewardList(nGroup)
    local tbConfig = AchievementPoint.GetRewards(nGroup)
    if not tbConfig then
        return
    end

    local tbPointList = {}
    for i, v in ipairs(tbConfig) do
        local state = AchievementPoint.CheckPointReward(nGroup, i)
        local showItem = v.tbRewards[1]
        if showItem and state ~= 2 then
           table.insert(tbPointList, i)
        end
    end

    return tbPointList
end

s2c.Register('AchievementPoint_GetReward',function(tbParam)
    local sUI = UI.GetUI("Achievement")
    if sUI then
        sUI:OnReceiveUpdate(tbParam)
    end

    Achievement.DoLevelUpShowUI()
end);

AchievementPoint.LoadConfig();