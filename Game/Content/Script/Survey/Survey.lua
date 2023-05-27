-- ========================================================
-- @File    : Survey.lua
-- @Brief   : 评分引导
-- @Author  :
-- @Date    : 2022-07-28 
-- ========================================================

Survey = Survey or { }

Survey.GroupID = 104

-- 上次弹出时间
Survey.LAST_POPUP_TIME = 1

-- 不成功次数
Survey.FAIL_COUNT  = 2

-- 记录标识位
Survey.TASK_FLAG = 3

-- 记录总次数
Survey.SUM_COUNT = 4 

Survey.TASK_RBREAK = 0
Survey.TASK_ONLINE = 1

Survey.SWITCH  = false

-- 意见提交的URL
Survey.SURVEY_URL= 'https://kefu.xoyo.com/?r=comform&id=434&game_id=52&service_id=1190'

-- App Store评分URL
Survey.APPSTORE_URL = "https://www.apple.com/"

Survey.CHAPTER = "Chapter"
Survey.GACHA = "Gacha"
Survey.RBREAK = "RBreak"
Survey.ONLINE = "Online"

Survey.PRE_SURVEY_EVENT= 'PreSurvey'
Survey.POST_SURVEY_EVENT= 'PostSurvey'

Survey.INTERVAL_TIME = 3600

Survey.MAX_FAIL_COUNT = 2

Survey.GOTO_APPSTORE = false
Survey.OPEN_APPSTORE_TIME = 0


Survey.LOG_CLOSE = 1
Survey.LOG_KEFU = 2
Survey.LOG_APPSTORE = 3


-- 评分逻辑
SurveyLogic = SurveyLogic or { tbClasses = {} }

function SurveyLogic.__GetFlag(nIdx)
    print("SurveyLogic.__GetFlag", nIdx)
    return GetBits(me:GetAttribute(Survey.GroupID, Survey.TASK_FLAG), nIdx, nIdx);
end

-- 获得上次弹出时间
function SurveyLogic.GetLastSurveyTime()
    return me:GetAttribute(Survey.GroupID, Survey.LAST_POPUP_TIME)
end

-- 获得已经评分不成功的次数
function SurveyLogic.GetFailedCount()
    return me:GetAttribute(Survey.GroupID, Survey.FAIL_COUNT)
end

function SurveyLogic.AddFailedCount(nValue)
    local nCurrent = me:GetAttribute(Survey.GroupID, Survey.FAIL_COUNT)
    return me:SetAttribute(Survey.GroupID, Survey.FAIL_COUNT, nCurrent + nValue)
end

function SurveyLogic.AddSumCount(nValue)
    local nCurrent = me:GetAttribute(Survey.GroupID, Survey.SUM_COUNT)
    return me:SetAttribute(Survey.GroupID, Survey.SUM_COUNT, nCurrent + nValue)
end

-- 获得触发的总的次数
function SurveyLogic.GetSumCount()
    return me:GetAttribute(Survey.GroupID, Survey.SUM_COUNT)
end

-- 是否开启天启2
function SurveyLogic.HavedRBreakL()
    return SurveyLogic.__GetFlag(Survey.TASK_RBREAK)
end

-- 是否联机
function SurveyLogic.HavedOnline()
    return SurveyLogic.__GetFlag(Survey.TASK_ONLINE)
end

function SurveyLogic.SetRBreakL()
    local v = me:GetAttribute(Survey.GroupID, Survey.TASK_FLAG)
    SetBits(v, 1, Survey.TASK_RBREAK, Survey.TASK_RBREAK);
end

function SurveyLogic.SetOnline()
    local v = me:GetAttribute(Survey.GroupID, Survey.TASK_FLAG)
    SetBits(v, 1, Survey.TASK_ONLINE, Survey.TASK_ONLINE);
end

function SurveyLogic.ResetFailedCount()
    me:SetAttribute(Survey.GroupID, Survey.FAIL_COUNT, 0)
end

function SurveyLogic.ResetTaskFlag()
    me:SetAttribute(Survey.GroupID, Survey.TASK_FLAG, 0)
end

function SurveyLogic.ResetLastTime()
    me:SetAttribute(Survey.GroupID, Survey.LAST_POPUP_TIME, 0)
end


local tbTemplateLogic = {
    bNeedOpen = false,
    -- 条件检查
    checkCondition = function(self, ...)
        return false;
    end,
    OnEnd = function(self, ...)
    end,
    -- pre
    OnPreSurvey = function(self, ...)
        print("Survey OnPreSurvey ", self.StrType);
        if not Survey.SWITCH then
            return;
        end
        -- 评分不成功超过最大次数
        if SurveyLogic.GetFailedCount() >= Survey.MAX_FAIL_COUNT then
            print("Survey OnPreSurvey failed count limit")
            -- 删除触发事件，功能不再触发
            Survey:RemoveTrigger()
            return;
        end
        local nNowTime = GetTime()
        -- 间隔时间没到
        if nNowTime - SurveyLogic.GetLastSurveyTime() < Survey.INTERVAL_TIME then
            print("Survey OnPreSurvey time limit")
            return;
        end
        if self:checkCondition(...) then
            print("Survey OnPreSurvey need open")
            self.bNeedOpen = true;
        end
    end,
    -- post
    OnPostSurvey = function(self, ...)
        print("Survey OnPostSurvey ", self.StrType);
        if self.bNeedOpen then
            local nNowTime = GetTime()
            -- 打开评分界面
            print("Survey open UI", nNowTime)
            --记录评分时间
            me:SetAttribute(Survey.GroupID, Survey.LAST_POPUP_TIME, nNowTime)
            self:OnEnd();
            UI.Open("SurveyGrade", self.StrType)
            SurveyLogic.AddSumCount(1)
        end
        self.bNeedOpen = false;
    end,
}

function SurveyLogic.Class(StrType)
    if StrType == nil then return tbTemplateLogic end
    if SurveyLogic.tbClasses[StrType] then return SurveyLogic.tbClasses[StrType] end;
    local tbLogic = Inherit(tbTemplateLogic);
    tbLogic.StrType = StrType;
    SurveyLogic.tbClasses[StrType] = tbLogic;
    return tbLogic;
end

-- 章节评分
local tbChapterClass = SurveyLogic.Class(Survey.CHAPTER)
function tbChapterClass:checkCondition(PassTime, nDiffiCulty, nChapterID, nLevelID)
    -- print("Survey tbChapterClass:checkCondition", PassTime, nDiffiCulty, nChapterID, nLevelID)
    -- 首次
    if PassTime > 1 then
        return false
    end
    -- 难度、章节ID、LevelID
    local tbChapter = Survey.tbCfg[Survey.CHAPTER] or {};
    for _, tbInfo in pairs(tbChapter) do
        local D, C, L = table.unpack(tbInfo.Param);
        -- print("Survey tbChapterClass:checkCondition cfg", D, C, L)
        if tonumber(D) == nDiffiCulty and tonumber(C) == nChapterID and tonumber(L) == nLevelID then
            return true
        end
    end
    return false
end

-- 扭蛋评分
local tbGachaClass = SurveyLogic.Class(Survey.GACHA)
function tbGachaClass:checkCondition(tbAwards, tbTrigger)
    --print("[Survey] Gacha checkCondition tbTrigger=", tbTrigger)
    --print("[Survey] Gacha checkCondition tbAwards=", tbAwards)
    -- 品质，GDPL
    local tbGacha = Survey.tbCfg[Survey.GACHA] or {}
    for i = 1, #tbAwards do
        local GDPL = tbAwards[i]
        local bTrigger = false
        if tbTrigger then
            bTrigger = tbTrigger[i]
            --print("Survey tbGachaClass:checkCondition bTrigger ", i, tbTrigger[i])
        end
        --非保底触发的才能弹
        if not bTrigger then
            local g, d, p, l = table.unpack(GDPL)
            --print("Survey tbGachaClass:checkCondition", g, d, p, l)
            for k, tbInfo in pairs(tbGacha) do
                -- print("Survey tbGachaClass:checkCondition cfg", tbInfo.Param[1], tbInfo.Param[2], tbInfo.Param[3], tbInfo.Param[4])
                if tonumber(tbInfo.Param[1]) == g and tonumber(tbInfo.Param[2]) == d and tonumber(tbInfo.Param[3]) == p and tonumber(tbInfo.Param[4]) == l then
                    return true
                end
            end
        end
    end
    return false;
end

-- 联机评分
local tbOnlineClass = SurveyLogic.Class(Survey.ONLINE)
function tbOnlineClass:checkCondition(LevelID)
    -- LevelID
    -- print("Survey tbOnlineClass:checkCondition", LevelID)
    if SurveyLogic.HavedOnline() == 0 then
        return true
    end
    return false
end

function tbOnlineClass:OnEnd()
    SurveyLogic.SetOnline();
end

-- 天启评分
local tbRBreakClass = SurveyLogic.Class(Survey.RBREAK)
function tbRBreakClass:checkCondition(nLevel, nBreakLevel)
    -- LEVEL、NBreakLevel
    -- print("Survey tbRBreakClass:checkCondition", nLevel, nBreakLevel)
    if SurveyLogic.HavedRBreakL() == 1 then
        return false
    end
    if nLevel / nBreakLevel  == 1 then
        return true
    end
    return false
end

function tbRBreakClass:OnEnd()
    SurveyLogic.SetRBreakL();
end

function Survey:LoadConfig()
    local tbFile = LoadCsv('survey/survey.txt', 1)
    self.tbCfg = {} -- 总配置表 类型 {}
    for _, tbLine in ipairs(tbFile) do
        local Id = tonumber(tbLine.ID) or 0
        local StrType = tostring(tbLine.Type) or ""
        local Param = Eval(tbLine.Param)
        local tbInfo = {Id = Id, Type = StrType, Param = Param}

        if not self.tbCfg[StrType] then
            self.tbCfg[StrType] = {}
        end
        table.insert(self.tbCfg[StrType], tbInfo)
    end

    print('Load settings/survey/survey.txt')
end

function Survey:RemoveTrigger()
    print("Survey Remove Trigger")
    if Survey.preEventHandle then
        EventSystem.Remove(Survey.preEventHandle)
        Survey.preEventHandle = nil;
    end
    if Survey.postEventHandle then
        EventSystem.Remove(Survey.postEventHandle);
        Survey.postEventHandle = nil;
    end
    if Survey.willDeactivateHandle then
        EventSystem.Remove(Survey.willDeactivateHandle)
        Survey.willDeactivateHandle = nil
    end
    if Survey.hasReactivatedHandle then
        EventSystem.Remove(Survey.hasReactivatedHandle)
        Survey.hasReactivatedHandle = nil
    end
end

function Survey:RegisterTrigger()
    print("Survey Register Trigger")
    if not Survey.preEventHandle then
        Survey.preEventHandle = EventSystem.OnTarget(Survey, Survey.PRE_SURVEY_EVENT, 
            function(self, InType, ...)
                SurveyLogic.Class(InType):OnPreSurvey(...)
            end
        )
    end
    if not Survey.postEventHandle then
        Survey.postEventHandle = EventSystem.OnTarget(Survey, Survey.POST_SURVEY_EVENT, 
            function(self, InType, ...)
                SurveyLogic.Class(InType):OnPostSurvey(...)
            end
        )
    end
    if not Survey.willDeactivateHandle then
        Survey.willDeactivateHandle = EventSystem.On(Event.AppWillDeactivate, function() 
            print("Survey Will Deactivate")
            if Survey.GOTO_APPSTORE then
                Survey.OPEN_APPSTORE_TIME = GetTime()
            end
        end)
    end
    if not Survey.hasReactivatedHandle then
        Survey.hasReactivatedHandle = EventSystem.On(Event.AppHasReactivated, function()
            print("Survey Has Reactivated")
            Survey:Reactivated()
        end)
    end
end

function Survey:Reactivated()
    if Survey.GOTO_APPSTORE then
        Survey.GOTO_APPSTORE = false
        local nNow = GetTime();
        -- 10秒内回来，评分不成功
        if nNow <= (Survey.OPEN_APPSTORE_TIME + 10) then
            print("[Survey] Deactivated less then 10s", Survey.OPEN_APPSTORE_TIME, nNow)
            SurveyLogic.AddFailedCount(1)
        end
        Survey.OPEN_APPSTORE_TIME = 0
    end
end

function Survey:Init()
    Survey:LoadConfig()
    -- 开关没开，功能不启动
    if not Survey.SWITCH then
        return
    end
    Survey:RegisterTrigger()
end

Survey:Init()

---登录拉取配置
EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    if not me or bReconnected then return end
    local sContentServer = Login.GetContent()
    if #sContentServer == 0 then return end
    local PlatformName = UE4.UGameplayStatics.GetPlatformName();
    local strReqUrl = string.format('%sgetgradeconf?platform=%s&channel=%s&subchannel=%s', sContentServer, PlatformName, me:Channel(), me:SubChannel())
    print("Survey Req ", strReqUrl)
    Download(strReqUrl, function(_, sData)
        print('Survey Login Response', sData)
        --local tbRes = json.decode("{\"switch\":0, \"submitUrl\":\"https://www.xoyo.com/\", \"appstoreUrl\":\"https://www.apple.com/\"}") or {}
        local tbRes = json.decode(sData) or {}
        local bSwitch = tbRes["switch"] == 1 or false
        -- 根据开关处理事件注册or删除事件
        if Survey.SWITCH and not bSwitch then
            Survey:RemoveTrigger()
        elseif not Survey.SWITCH and bSwitch then
            Survey:RegisterTrigger()
        end
        Survey.SWITCH = bSwitch
        Survey.APPSTORE_URL = tbRes["appstoreUrl"] or "https://www.xoyo.com/"
        Survey.SURVEY_URL = tbRes["submitUrl"] or "https://kefu.xoyo.com/?r=comform&id=434&game_id=52&service_id=1190"
    end)
end)

                    