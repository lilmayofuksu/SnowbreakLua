-- ========================================================
-- @File    : Achievement/Achievement.lua
-- @Brief   : 任务成就系统
-- ========================================================

-- 任务成就系统
---@class Achievement
Achievement = Achievement or {
    -- tbConfig        = {},
    -- tbPointAwards   = {},
    -- tbGroupConfig   = {}
}

--- 自定义属性变量组
Achievement.GroupID         = 2         --任务系统GID
Achievement.GroupID_Quest         = 7    --活动使用的成就GID

--- 常量定义
Achievement.GROUP_DAILY  = 1; -- 日常任务
Achievement.GROUP_WEEK   = 2; -- 周常任务
Achievement.GROUP_TARGET = 3; -- 成就
Achievement.GROUP_BranchLine    = 4; -- 支线任务
Achievement.GROUP_ExtraReward   = 5; -- 支线任务额外奖励

--构建新id 唯一性
Achievement.MAKE_ID_PARAM = 100;

--奖励状态
Achievement.STATUS_NOT = 0 --未完成 不能领取
Achievement.STATUS_CAN = 1 --完成  可以领取
Achievement.STATUS_GOT = 2 --已领取

---测试输出
Achievement.Debug_Print = true

---执行度物品
Achievement.DegreeItem = {4,1,3,1}

--活动成就类型
Achievement.Quest_Type_Activity = 1
Achievement.Quest_Type_BattlePass = 2

--特殊处理 类型成就
Achievement.tbSpecialList = {93}

------------------------------------外部接口-------------------------------------------
--- 怪物结算刷新任务进度  改为结算 更新
--- @param array UE4.TArray 怪物击杀数量 array[1]:普通怪数量,array[2]:精英怪数量,array[3]:Boss怪数量
function Achievement.OnMonsterSettlement(array)
    -- if not array then return end
    -- local data = {}
    -- local issend = false
    -- for i = 1, 3 do
    --     local num = array:Get(i)
    --     if num and num > 0 then
    --         issend = true
    --         data[i] = num
    --     end
    -- end
    -- if issend then
    --   me:CallGS("Achievement_OnMonsterSettlement", json.encode(data))
    -- end
end

--- 闯关失败刷新任务进度 改为结算 更新
function Achievement.OnLevelFailed()
   -- me:CallGS("Achievement_OnLevelFailed")
end
-------------------------------------------------------------------------------------
---加载任务配置
function Achievement.LoadConf()
    -- 加载任务表配置
    Achievement.tbCfgByType = {}
    Achievement.tbConfig = {}
    Achievement.tbGroupConfig = {}
    Achievement.tbChapterList = {}
    local tbFile = LoadCsv('achievement/achievement.txt', 1);
    for _,tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID)
        if nId then
            local cfg = {
                nGroupId      = Achievement.GroupID,
                nId                 = nId,
                sName               = tbLine.Name,
                sDescribe           = tbLine.Describe,
                nIcon               = tonumber(tbLine.Icon),
                nGroup              = tonumber(tbLine.Group),
                nChapterGroup       = tonumber(tbLine.ChapterGroup),
                nChapterIcon     = tonumber(tbLine.ChapterIcon),
                nPriority           = tonumber(tbLine.Priority or 0),
                tbCondition         = Eval(tbLine.Condition) or {},
                nPreId              = tonumber(tbLine.PreID),
                nReceivedShow       = tonumber(tbLine.ReceivedShow or 0),
                nType               = tonumber(tbLine.Type),
                nCheckValue         = tonumber(tbLine.CheckValue or 1),
                tbParam             = Eval(tbLine.Param) or {},
                nFinishLimit        = tonumber(tbLine.FinishLimit),
                tbRewards           = Eval(tbLine.Rewards) or {},
                nFunctionID      = tonumber(tbLine.FunctionID) or 0,
                sGotoUI             = tbLine.GotoUI,
                tbUIParam           = Eval(tbLine.tbParam) or {},
                sConditionGoto      = tbLine.ConditionGoto,
                nAchievementPoint   = tonumber(tbLine.AchievementPoint) or 0,
            }

            cfg.nStartTime      = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), cfg, "nStartTime")
            cfg.nEndTime        = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), cfg, "nEndTime")

            local MakeId = nId * Achievement.MAKE_ID_PARAM + Achievement.GroupID
            Achievement.tbConfig[MakeId] = cfg;

            if cfg.nType and Achievement.CheckInSpecialList(cfg.nType) then
                Achievement.tbCfgByType[cfg.nType] = Achievement.tbCfgByType[cfg.nType] or {}
                table.insert(Achievement.tbCfgByType[cfg.nType], cfg)
            end

            if cfg.nGroup then
                Achievement.tbGroupConfig[cfg.nGroup] = Achievement.tbGroupConfig[cfg.nGroup] or {}
                table.insert(Achievement.tbGroupConfig[cfg.nGroup], cfg)
            end

            if cfg.nChapterGroup and cfg.nGroup == Achievement.GROUP_ExtraReward then
                table.insert(Achievement.tbChapterList,  cfg)
            end
        end
    end

    Achievement.LoadQuestConf()
end

---加载活动成就配置
function Achievement.LoadQuestConf()
    local tbFile = LoadCsv('achievement/activity_quest.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID)
        local nCoverage = tonumber(tbLine.Coverage) or 0
        if nId and CheckCoverage(nCoverage) then
            local cfg = {
                nGroupId      = Achievement.GroupID_Quest,
                nId                 = nId,
                sName               = tbLine.Name,
                sDescribe           = tbLine.Describe,
                nIcon               = tonumber(tbLine.Icon),
                nGroup              = tonumber(tbLine.Group),
                nChapterGroup       = tonumber(tbLine.ChapterGroup),
                nPriority           = tonumber(tbLine.Priority or 0),
                tbCondition         = Eval(tbLine.Condition) or {},
                nPreId              = tonumber(tbLine.PreID),
                nReceivedShow       = tonumber(tbLine.ReceivedShow or 0),
                nType               = tonumber(tbLine.Type),
                nCheckValue         = tonumber(tbLine.CheckValue or 1),
                tbParam             = Eval(tbLine.Param) or {},
                nFinishLimit        = tonumber(tbLine.FinishLimit),
                tbRewards           = Eval(tbLine.Rewards) or {},
                nFunctionID      = tonumber(tbLine.FunctionID) or 0,
                sGotoUI             = tbLine.GotoUI,
                tbUIParam           = Eval(tbLine.tbParam) or {},
                sConditionGoto      = tbLine.ConditionGoto,
                tbActivityId         = Eval(tbLine.ActivityID) or {},
                nAchievementPoint   = tonumber(tbLine.AchievementPoint) or 0,
                nCoverage           = nCoverage,
            }

            cfg.nStartTime      = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), cfg, "nStartTime")
            cfg.nEndTime       = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), cfg, "nEndTime")

            local MakeId = nId * Achievement.MAKE_ID_PARAM + Achievement.GroupID_Quest
            Achievement.tbConfig[MakeId] = cfg;

            if cfg.nType and Achievement.CheckInSpecialList(cfg.nType) then
                Achievement.tbCfgByType[cfg.nType] = Achievement.tbCfgByType[cfg.nType] or {}
                table.insert(Achievement.tbCfgByType[cfg.nType], cfg)
            end
        end
    end
end

---得到某个任务配置
---@param nId integer 任务ID
---@return table 返回对应的配置，未找到或不满足条件则返回空
function Achievement.GetConfig(nId)  
    if not nId then return end

    local nMakdId = nId * Achievement.MAKE_ID_PARAM + Achievement.GroupID
    local tbConfig = Achievement.tbConfig[nMakdId];
    if not tbConfig then return end

    return tbConfig;
end

---得到某个任务配置
---@param nId integer 任务ID
---@return table 返回对应的配置，未找到或不满足条件则返回空
function Achievement.GetQuestConfig(nId)  
    if not nId then return end

    local nMakdId = nId * Achievement.MAKE_ID_PARAM + Achievement.GroupID_Quest
    local tbConfig = Achievement.tbConfig[nMakdId];
    if not tbConfig then return end

    return tbConfig;
end

--检测是否特殊类型
function Achievement.CheckInSpecialList(nType)
    if not nType then return end

    for k,v in ipairs(Achievement.tbSpecialList) do
        if v == nType then return true end
    end
end

---得到某个类型所有开放的任务配置 用于刷新进度
---@param nType string 任务类型
---@return table 返回对应的所有配置
function Achievement.GetCfgByType(nType)
    local allcfg = Achievement.tbCfgByType[nType] or {}
    local data = {}
    for _, v in ipairs(allcfg) do
        if not Achievement.IsFinished(v) then
            table.insert(data, v)
        end
    end
    return data
end

function Achievement.ShowDebug(szFunc)
    if Achievement.Debug_Print then
        if szFunc then
            print(szFunc, debug.traceback())
        else
            print("ShowDebug", debug.traceback())
        end
    end
end

---主界面任务按钮是否显示红点
function Achievement.IsShowRedDot()
    --任务、成就
    for i=Achievement.GROUP_DAILY,Achievement.GROUP_BranchLine do
        local _, nFunctionId = Achievement.GetTypeName(i)
        if Achievement.IsGroupHaveReceive(i) and FunctionRouter.IsOpenById(nFunctionId or 0) then
            return true
        end
    end

    return false
end

---得到任务描述
function Achievement.GeDescribe(tbConfig)
    if not tbConfig then return "" end

    local describe = ""
    if tbConfig.nType and tbConfig.nType == 2 then
        if tbConfig.tbParam and #tbConfig.tbParam ~= 0 then
            local chapterConf = Chapter.GetChapterCfgByLevelID(tbConfig.tbParam[1])
            local levelConf = ChapterLevel.Get(tbConfig.tbParam[1], true)
            if chapterConf and levelConf then
                local sKey = string.format("%s_%d", tbConfig.sDescribe, chapterConf.nDifficult)
                return Text(sKey, GetLevelName(levelConf))
            end
        end
        describe = Text(tbConfig.sDescribe, tbConfig.nCheckValue)
    elseif tbConfig.sDescribe then
        describe = Text(tbConfig.sDescribe, tbConfig.nCheckValue)
    end
    return describe
end

---得到某个任务配置
---@param tbCfg integer or table 任务ID or 配置表table
---@param bQuest boolean 普通成就(默认) 还是 活动成就
---@return table 返回对应的配置，未找到或不满足条件则返回空
function Achievement.CheckConfig(tbCfg, bQuest)
    local tbConfig = nil    
    if type(tbCfg) == "table" then
        tbConfig = tbCfg
    elseif type(tbCfg) == "number" then
        if bQuest then
            tbConfig = Achievement.GetQuestConfig(tbCfg)
        else
            tbConfig = Achievement.GetConfig(tbCfg)
        end
    end

    if not tbConfig then return nil end;

    -- 检测限制
    local bUnLock = Condition.Check(tbConfig.tbCondition)
    if not bUnLock then
        return nil
    end

    -- 检测时间
    if not IsInTime(tbConfig.nStartTime, tbConfig.nEndTime) then
        return nil;
    end

    --强关联时 活动检测
    if tbConfig.tbActivityId and #tbConfig.tbActivityId > 0 then
        if tbConfig.tbActivityId[1] == Achievement.Quest_Type_Activity and not Activity.AchievementCheck(tbConfig.tbActivityId[2]) then
            return
        elseif tbConfig.tbActivityId[1] == Achievement.Quest_Type_BattlePass and not BattlePass.CheckQuest(tbConfig.tbActivityId[2]) then
            return
        else
            return
        end
    end

    return tbConfig;
end

---跳转到目标界面
---@param tbCfg integer or table 任务ID or 配置表table
---@param bQuest boolean 普通成就(默认) 还是 活动成就
function Achievement.GoToUI(tbCfg, bQuest)
    local tbConfig = nil    
    if type(tbCfg) == "table" then
        tbConfig = tbCfg
    elseif type(tbCfg) == "number" then
        if bQuest then
            tbConfig = Achievement.GetQuestConfig(tbCfg)
        else
            tbConfig = Achievement.GetConfig(tbCfg)
        end
    end

    if not tbConfig then
        return
    end

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
        local tbParam = Copy(tbConfig.tbUIParam)
        if tbConfig.sGotoUI == "Level" and tbParam and #tbParam >= 4 and tbParam[1] == true then
            local nLevelId = tbParam[4].levelId or 0
            local tbLevelConfig = ChapterLevel.Get(nLevelId, true)
            if not tbLevelConfig or not Condition.Check(tbLevelConfig.tbCondition) then
                if tonumber(tbParam[2]) == 1 then
                    nLevelId = Chapter.GetProceedLevel(tonumber(tbParam[3]), CHAPTER_LEVEL.EASY)
                elseif tonumber(tbParam[2]) == 2 then
                    nLevelId = Chapter.GetProceedLevel(tonumber(tbParam[3]), CHAPTER_LEVEL.NORMAL)
                else
                    nLevelId = nil
                end

                if tbParam[4].levelId and nLevelId then
                    tbParam[4].levelId = nLevelId
                end
            end
        elseif tbConfig.sGotoUI == "Level" then
            local bMain = type(tbParam) == "table" and tbParam[1] or true
            local nDifficult = type(tbParam) == "table" and tbParam[2] or 1
            local nChapterID = type(tbParam) == "table" and tbParam[3] or Chapter.GetProceedChapter()
            if nChapterID then
                tbParam = {bMain, nDifficult, nChapterID}
            end
        end
      
        UI.Open(tbConfig.sGotoUI, table.unpack(tbParam))
    elseif tbConfig.sConditionGoto then
        local fun = Eval(tbConfig.sConditionGoto)
        if fun then fun(table.unpack(tbConfig.tbUIParam)) end
    end
end

---得到某个类型开放的所有任务配置
---@param ngroup integer 任务类型
---@return table 返回对应类型的所有任务配置
function Achievement.GetTbConfigByGroup(ngroup)
    local allcfg = Achievement.tbGroupConfig[ngroup] or {}
    return allcfg
end

---获取当前进行的支线任务章节
---@return integer 当前进行的支线任务章节
function Achievement.GetChapter()
    local nAllNum = 0
    for _, v in ipairs(Achievement.tbChapterList) do
        if v and not Achievement.IsReceive(v) then
            return v.nChapterGroup
        else 
            nAllNum = nAllNum + 1
        end
    end

    if nAllNum > 0 and nAllNum == Achievement.GetMaxChapter() then
        return nAllNum
    end

    return 1
end

---获取支线任务章节大小
---@return integer 当前进行的支线任务章节
function Achievement.GetMaxChapter()
    return #Achievement.tbChapterList
end

---得到对应章节支线任务额外奖励配置
---@param nChapter integer 章节 为空返回当前进行的章节
---@return table 返回支线任务额外奖励配置
function Achievement.GetExtraRewardCfg(nChapter)
    local chapter = nChapter or Achievement.GetChapter()
    local allcfg = Achievement.GetTbConfigByGroup(Achievement.GROUP_ExtraReward)
    for _, v in pairs(allcfg) do
        if v.nChapterGroup == chapter then
            return v
        end
    end
    return nil
end

---得到某个章节的所有支线任务配置
---@param nChapter integer 章节
---@return table 返回某个章节的所有支线任务配置
function Achievement.GetAllBranchLine(nChapter)
    local chapter = nChapter or Achievement.GetChapter()
    local allBranchLine = Achievement.GetTbConfigByGroup(Achievement.GROUP_BranchLine)
    local data = {}
    for _, v in ipairs(allBranchLine) do
        if v.nChapterGroup and v.nChapterGroup == chapter then
            table.insert(data, v)
        end
    end
    return data
end

---得到某个章节的所有支线任务完成情况
---@param id integer 主线任务id
---@return integer 任务完成数量
---@return integer 任务总数量
function Achievement.GetCompletion(id)
    local tbConfig = Achievement.GetConfig(id)
    if not tbConfig or not tbConfig.nChapterGroup then return 0,0 end

    local tbcfg = Achievement.GetAllBranchLine(tbConfig.nChapterGroup)
    local finishnum = 0
    if not tbcfg or #tbcfg == 0 then
        return 0, 1
    end

    for _, v in pairs(tbcfg) do
        if Achievement.CheckAchievementReward(v) == Achievement.STATUS_GOT then
            finishnum = finishnum + 1
        end
    end
    return finishnum, #tbcfg
end

---检查任务是否完成
---@param tbConfig table 成就配置表
---@return boolean 返回是否完成
function Achievement.IsFinished(tbConfig)
    if not tbConfig then return false end
    return Achievement.GetProgres(tbConfig.nGroupId, tbConfig.nId) >= tbConfig.nCheckValue
end

---判断某个任务的前置任务是否完成 完成是否领取奖励
---@param tbConfig table 任务id
---@return boolean 前置任务完成并领取奖励或没有前置任务返回True,前置任务未完成或未领奖返回false
function Achievement.IsPreFinished(tbConfig)
    if tbConfig then
        local tbPrev = Achievement.CheckConfig(tbConfig.nPreId, tbConfig.nGroupId == Achievement.GroupID_Quest)
        if tbPrev then
            return Achievement.CheckAchievementReward(tbPrev) == Achievement.STATUS_GOT
        else
            return true
        end
    else
        return false
    end
end

---得到任务首次达成时间 成就完成后，进度变成完成时间
---@param nId integer 任务id
---@return integer 返回首次达成时间
function Achievement.GetFirstTime(nId, bQuest)
    if not nId then
        Achievement.ShowDebug("GetFirstTime")
        return 0, 0
    end

    local tbConfig = nil
    if bQuest then
        tbConfig = Achievement.GetQuestConfig(nId)
    else
        tbConfig = Achievement.GetConfig(nId)
    end

    if not tbConfig then return end

    return Achievement.GetProgres(tbConfig.nGroupId, tbConfig.nId)
end

---得到任务存储的进度值
---@param nId integer 任务id
---@return integer 返回当前进度
function Achievement.GetProgres(nGroupId, nId)
    if not nGroupId or not nId then
        Achievement.ShowDebug("GetProgres")
        return 0
    end
    
    local nTaskValue = me:GetAttribute(nGroupId, nId)
    local nRet = GetBits(nTaskValue, 1, 31)
    return nRet
end

---得到任务的进度和总进度
---@param tbCfg integer or table 任务ID or 配置表table
---@param bQuest boolean 普通成就(默认) 还是 活动成就
---@return integer 进度的分子，错误返回空
---@return integer 进度的分母
function Achievement.GetProgresAndSum(tbCfg, bQuest)
    if type(tbCfg) == "table" then
        tbConfig = tbCfg
    elseif type(tbCfg) == "number" then
        if bQuest then
            tbConfig = Achievement.GetQuestConfig(tbCfg)
        else
            tbConfig = Achievement.GetConfig(tbCfg)
        end
    end
    
    if not tbConfig then return 0, 0 end

    local v = Achievement.GetProgres(tbConfig.nGroupId, tbConfig.nId)
    if v > tbConfig.nCheckValue then
        v = tbConfig.nCheckValue
    end
    return v, tbConfig.nCheckValue
end

---检查任务的奖励是否被领取
---@param tbConfig table 成就配置信息
---@return boolean 返回奖励是否被领取
function Achievement.IsReceive(tbConfig)
    if not tbConfig then return false end

    local nTaskValue = me:GetAttribute(tbConfig.nGroupId, tbConfig.nId)
    local nRet = GetBits(nTaskValue, 0, 0)
    return nRet > 0
end

---领取完成所以支线任务后的额外奖励
---@param nId integer 额外奖励任务id
function Achievement.GetExtraReward(nId)
    if (not nId) or nId <= 0 then
        return UI.ShowMessage('error.BadParam');
    end

    local tbConfig = Achievement.CheckConfig(nId);
    if not tbConfig or not tbConfig.nChapterGroup or tbConfig.nGroup ~= Achievement.GROUP_ExtraReward then
        return UI.ShowMessage('error.BadParam')
    end

    -- 检查是否已领取
    if Achievement.IsReceive(tbConfig) then
        return UI.ShowMessage('achievement.RewardGeted');
    end

    -- 检查支线任务是否全部完成
    for _, v in pairs(Achievement.GetAllBranchLine(tbConfig.nChapterGroup)) do
        if not Achievement.IsReceive(v) then
            return UI.ShowMessage('achievement.NotFinished');
        end
    end

    Achievement.DoLevelUpCacheLevel()

    UI.ShowConnection()
    -- 领取奖励
    me:CallGS("Achievement_GetReward", json.encode({nId = nId}))
end

---领取任务奖励
---@param nId integer 任务id
function Achievement.GetReward(nId)
    if (not nId) or nId <= 0 then
        return UI.ShowMessage('error.BadParam');
    end

    local tbConfig = Achievement.GetConfig(nId);
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

    UI.ShowConnection()
    -- 领取奖励
    me:CallGS("Achievement_GetReward", json.encode({nId = nId}))
end

---一键领取任务奖励
---@param nGroup integer 任务类型
function Achievement.QuickGetReward(nGroup)
    if not nGroup or nGroup <= 0 or nGroup > Achievement.GROUP_BranchLine then
        return UI.ShowMessage('error.BadParam');
    end
    
    --获取可领取的列表
    local tbIdList = {}
    local tbcfg = Achievement.GetTbConfigByGroup(nGroup)
    local nCurChapter = Achievement.GetChapter()
    for _, cfg in pairs(tbcfg) do
        if Achievement.CheckAchievementReward(cfg) == Achievement.STATUS_CAN then
            if nGroup == Achievement.GROUP_BranchLine then
                if cfg.nChapterGroup and cfg.nChapterGroup == nCurChapter then
                    table.insert(tbIdList, cfg.nId)
                end
            else
                table.insert(tbIdList, cfg.nId)
            end
        end
    end

    local tbParam = {tbIdList = tbIdList, nType = nGroup}
    --获取执行度领奖标记
    if nGroup == Achievement.GROUP_DAILY or nGroup == Achievement.GROUP_WEEK then
        local tbPointList = AchievementPoint.GetQuickRewardList(nGroup)
        if tbPointList and #tbPointList > 0 then
            tbParam.tbPointList = tbPointList
        end
    elseif nGroup == Achievement.GROUP_BranchLine then
        local extraRewardCfg = Achievement.GetExtraRewardCfg(Achievement.GetChapter())
        if extraRewardCfg then
            table.insert(tbIdList, extraRewardCfg.nId)
        end
    end

    Achievement.DoLevelUpCacheLevel()

    -- 领取奖励
    me:CallGS("Achievement_QuickGetReward", json.encode(tbParam))
end

---奖励领取情况
---@param tbCfg integer or table 任务ID or 配置表table
---@param bQuest boolean 普通成就(默认) 还是 活动成就
---@return integer o未达成STATUS_NOT 1完成未领取STATUS_CAN  2已领取STATUS_GOT
function Achievement.CheckAchievementReward(tbCfg, bQuest)
    local tbConfig = nil
    if type(tbCfg) == "table" then
        tbConfig = tbCfg
    elseif type(tbCfg) == "number" then
        if bQuest then
            tbConfig = Achievement.GetQuestConfig(tbCfg)
        else
            tbConfig = Achievement.GetConfig(tbCfg)
        end
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

---是否有可领取奖励的任务 主要显示黄点
---@param type integer 任务类型
---@return boolean 是否有可领取奖励的任务
function Achievement.IsHaveReceive(type)
    local tbcfg = Achievement.GetTbConfigByGroup(type)
    local nCurChapter = Achievement.GetChapter()
    for _, cfg in pairs(tbcfg) do
        if Achievement.CheckAchievementReward(cfg) == Achievement.STATUS_CAN then
            if type == Achievement.GROUP_BranchLine then
                if cfg.nChapterGroup and cfg.nChapterGroup == nCurChapter then
                    return true
                end
            else
                return true
            end
        end
    end
    return false
end

---是否有可领取奖励的额外任务 主要显示黄点
---@param type integer 任务类型
---@return boolean 是否有可领取奖励的任务
function Achievement.IsHaveExtraReceive(type)
    local tbcfg = Achievement.GetTbConfigByGroup(type)
    local nCurChapter = Achievement.GetChapter()
    for _, cfg in pairs(tbcfg) do
        if cfg.nChapterGroup and cfg.nChapterGroup == nCurChapter and Achievement.CheckAchievementReward(cfg) < Achievement.STATUS_GOT then
            local finishnum, num = Achievement.GetCompletion(cfg.nId)
            if finishnum >= num then
                return true
            end
        end
    end
    return false
end

---是否有可领取奖励的任务 主要显示红点
---@param type integer 任务类型
---@return boolean 是否有可领取奖励的任务
function Achievement.IsGroupHaveReceive(type)
    if type == Achievement.GROUP_DAILY or type == Achievement.GROUP_WEEK then
        local nRet = AchievementPoint.IsHaveReceive(type)
        if not nRet then -- 如果没有奖励了，是否已经达到最大值 未领取的日常周常不提示 红点
            if AchievementPoint.GetPoint(type) >= AchievementPoint.GetMaxPoint(type) then
                return false
            end
        else
            return nRet
        end
    end

    if Achievement.IsHaveReceive(type) then
        return true
    end

    if type == Achievement.GROUP_BranchLine then
        if Achievement.IsHaveExtraReceive(Achievement.GROUP_ExtraReward) then
            return true
        end
    end

    return false
end

---各个类型可领取奖励的任务数量
---@param type integer 任务类型
---@return integer 可领取奖励的任务数量
function Achievement.GetReceiveNum(type)
    local num = 0
    local tbcfg = Achievement.GetTbConfigByGroup(type)
    for _, v in pairs(tbcfg) do
        if Achievement.CheckAchievementReward(v) == Achievement.STATUS_CAN then
            num = num + 1
        end
    end
    return num
end

---各个类型的任务是否开放
---@param type integer 任务类型
---@return boolean 是否开放
function Achievement.AchievementIsOpen(type)
    if type == Achievement.GROUP_DAILY then  --日常
        return true
    elseif type == Achievement.GROUP_WEEK then  --周常
        return true
    elseif type == Achievement.GROUP_TARGET then  --成就
        return true
    elseif type == Achievement.GROUP_BranchLine then  --支线
        return true
    end
    return false
end

---得到任务的类型名 和 解锁条件id
---@param type integer 任务类型
---@return string 类型名, integer解锁条件id
function Achievement.GetTypeName(type)
    if type == Achievement.GROUP_DAILY then  --日常
        return Text("achievement.type1"), FunctionType.TaskDaily
    elseif type == Achievement.GROUP_WEEK then  --周常
        return Text("achievement.type2"),FunctionType.TaskWeekly
    elseif type == Achievement.GROUP_TARGET then  --成就
        return Text("achievement.type3"), FunctionType.TaskTarget
    elseif type == Achievement.GROUP_BranchLine then  --支线
        return Text("chapter.type_1_2"), FunctionType.TaskBranch
    end
    return Text("achievement.type" .. type),0
end

--特殊处理升级行为 缓存需要显示的等级
function Achievement.DoLevelUpCacheLevel()
    Achievement.nOldLevel = me:Level()
    Achievement.nNewLevel = me:Level()
    if Achievement.nLevelUpHandle then
        return
    end

    Achievement.nLevelUpHandle = EventSystem.On(Event.LevelUp, function(nNewLevel, nOldLevel)
            if nOldLevel < Achievement.nOldLevel then
                Achievement.nOldLevel = nOldLevel 
            end

            if nNewLevel > Achievement.nNewLevel then
                Achievement.nNewLevel = nNewLevel
            end
        end)
end

--特殊处理升级行为 显示UI
function Achievement.DoLevelUpShowUI()
    if Achievement.nNewLevel > Achievement.nOldLevel then
        UE4.Timer.Add(0.1, function()
                FunctionRouter.ShowLevelUpTip(Achievement.nNewLevel, Achievement.nOldLevel, true)
        end)
    end
end


---获取主界面显示任务条目
function Achievement.GetMainMapShowUI()
    local tbConfig = Achievement.GetAllBranchLine(Achievement.GetChapter())
    local tbfinished = {}      --已完成未领取
    local tbnotFinished = {}   --进行中
    local tbreceived = {}      --已领取
    for _, config in ipairs(tbConfig) do
        if Achievement.IsPreFinished(config) then
            local situation = Achievement.CheckAchievementReward(config)
            if situation == Achievement.STATUS_GOT then
               table.insert(tbreceived, config)
            elseif situation == Achievement.STATUS_CAN then
                table.insert(tbfinished, config)
            else
                table.insert(tbnotFinished, config)
            end
        end
    end

    local getConfig = nil
    local funcBranch = function(tbList)
        if getConfig then return end
        
        if #tbList > 0 then
            getConfig = tbList[1]
        end
    end

    funcBranch(tbfinished)--获取主线故事
    funcBranch(tbnotFinished)--获取主线故事

    if #tbreceived == #tbConfig then --全部完成
        getConfig = Achievement.GetExtraRewardCfg(Achievement.GetChapter())
        local situation = Achievement.CheckAchievementReward(getConfig)
        if situation == Achievement.STATUS_GOT then
            getConfig = nil
        end
    end

    -- if getConfig then
    --     print("getConfig===", getConfig.nGroup, getConfig.nId, Text(getConfig.sName), Achievement.GeDescribe(getConfig))
    -- end

    return getConfig
end

--------------------注册回调
-- 领取奖励后供服务端调用的回调
s2c.Register('Achievement_GetReward',function(tbParam)
    UI.CloseConnection()
    local sUI = UI.GetUI("Achievement")
    if sUI then
        sUI:OnReceiveUpdate(tbParam)
    end

    Achievement.DoLevelUpShowUI()
end)

-- 领取奖励后供服务端调用的回调
s2c.Register('Achievement_QuickGetReward',function(tbParam)
    local sUI = UI.GetUI("Achievement")
    if not sUI or not sUI:IsOpen() then
        return
    end

    --整合奖励
    local tbAllAward = {}
    if tbParam and tbParam.tbRewards then
        for i,v in ipairs(tbParam.tbRewards) do
            for k,tbInfo in ipairs(v) do
                table.insert(tbAllAward, tbInfo)
            end
        end
    end

    if tbAllAward and #tbAllAward > 0 then
        sUI:OnReceiveUpdate({tbRewards = tbAllAward})
    else
        sUI:OnReceiveUpdate()
    end

    Achievement.DoLevelUpShowUI()
end)


----初始化
function Achievement._OnInit()
    Achievement.LoadConf()

    --添加好友
    EventSystem.On(Event.OnSendFriendReq, function()
        if not me then return end

        local tbList = Achievement.GetCfgByType(93)
        if #tbList == 0 then
            return
        end

        me:CallGS("Achievement_OnAddSomeOne", json.encode({nType = 93}))
    end)
end

Achievement._OnInit()

