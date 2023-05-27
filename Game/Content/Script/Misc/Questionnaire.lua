-- ========================================================
-- @File	: Misc/Questionnaire.lua
-- @Brief	: 问卷系统
-- ========================================================

Questionnaire = Questionnaire or {};

---自定义属性组GroupID
Questionnaire.GROUPID   =   57
---Attribute_subID
Questionnaire.SUBID_CURRENT =   0
---问卷数值Key
Questionnaire.KEY   =   935740674

---变量
Questionnaire.CurID = 0
--客户端当前完成问卷临时变量, 应对服务器获取发奖延迟的问题.
Questionnaire.FinishedID = 0
--当前回调地址
Questionnaire.CurCallback = ''

---加载问卷配置
function Questionnaire.LoadConf()
    Questionnaire.tbConfig = {}
    local tbFile = LoadCsv("questionnaire/questionnaire.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.QuestID)
        if nId then
            local cfg = {
                nQuestId    = nId,
                nPriority   = tonumber(tbLine.Priority) or 0,
                nMutexId    = tonumber(tbLine.MutexID) or 0,
                sLink       = tbLine.Link or "",
                sIndex      = tbLine.Index or "",
                sKey        = tbLine.SecretKey or "",
                sCallback   = tbLine.Callback or "",
                tbCondition = Eval(tbLine.Condition),
                tbRewards   = Eval(tbLine.Rewards) or {},
                sTittle     = tbLine.Tittle,
                sContent    = tbLine.Content,
                sSender     = tbLine.Sender,
                nLife       = tonumber(tbLine.Life),
                tbAreaLimit  = Eval(tbLine.AreaLimit),
                tbChannelLimit   = Eval(tbLine.ChannelLimit),
                tbLanguageLimit  = Eval(tbLine.LanguageLimit),
            }

            cfg.nStartTime  = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), cfg, "nStartTime")
            cfg.nEndTime    = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), cfg, "nEndTime")

            Questionnaire.tbConfig[nId] = cfg
        end
    end
    --Dump(Questionnaire.tbConfig)
end

function Questionnaire.Reset()
    Questionnaire.CurID = 0
    Questionnaire.FinishedID = 0
    Questionnaire.CurCallback = ''
end


function Questionnaire.RefreshQuestionnaire()
    if Player.tbSetting and Player.tbSetting['Questionnaire'] == 1 then return end --服务器端屏蔽问卷
    local nLevelID = Chapter.GetProceedNotPlot()
    if nLevelID ~= nil then
        --西瓜问卷接口
        --UE4.UGameLibrary.RefreshQuestionaire(nLevelID)
        Questionnaire.Refresh()
    end
end

--- 打开主界面问卷
function Questionnaire.OpenQuestionnaire()
    if not Questionnaire.tbConfig then return end
    if Questionnaire.CurID > 0 then
        local tbCurConfig = Questionnaire.tbConfig[Questionnaire.CurID]
        local slink = tbCurConfig.sLink
        slink = string.gsub(slink, '^http://', 'https://')
        if tbCurConfig.sKey and tbCurConfig.sKey ~= '' then
            --- 拼接带API的地址
            local secret = tbCurConfig.sKey
            -- local callback = 'https://' .. Login.GetServer().sAddr .. ':1234/dcpcollect' --临时拼游戏服务器回调地址
            local info = {
                callback = tbCurConfig.sCallback, --配置表回调地址
                survey = tbCurConfig.sIndex,
                uid = me:GetAreaID() .. '-' .. me:Id(),
                questid = tbCurConfig.nQuestId
            }

            local sJoint = 'callback=' .. info.callback
            sJoint = sJoint .. '|questid=' .. info.questid
            sJoint = sJoint .. '|survey=' .. info.survey
            sJoint = sJoint .. '|uid=' .. info.uid
            sJoint = sJoint .. '|' .. secret
            
            info.sign = string.lower(UE4.UGameLibrary.MD5String(sJoint))
            slink = slink .. '?'
            for k, v in pairs(info) do
                slink = slink .. k .. '=' .. v .. '&'
            end
            slink = string.sub(slink, 1, -2) 
        else
            slink = slink .. '?uid=' .. me:GetAreaID() .. '-' .. me:Id()
        end
        print("Questionnaire slink", slink)
        UI.Open("Survey", slink) -- 内嵌浏览器打开
        --临时方案:外接浏览器问卷
        --Questionnaire.OpenQuestionnaireOutSide(slink, Questionnaire.CurID)
    end
end

--临时接口 打开外部浏览器
function Questionnaire.OpenQuestionnaireOutSide(sUrl, qid)
    UE4.UKismetSystemLibrary.LaunchURL(sUrl)
end

--客户端检查到完成问卷
function Questionnaire.OnClientFinish()
    --print("Questionnaire.OnClientFinish")
    local sUI = UI.GetUI("Survey")
    if sUI then
        sUI:Close()
    end
    Questionnaire.FinishedID = Questionnaire.CurID
    local cfg = Questionnaire.tbConfig[Questionnaire.FinishedID]
    if not cfg or Questionnaire.GetRecord(cfg.nMutexId) == 1 then return false end
    --通知
    local nTime = GetTime()
    local encryptedNum  = Questionnaire.Encrypt(Questionnaire.FinishedID, nTime)
    me:CallGS("Questionnaire_Finish", json.encode({nId = Questionnaire.FinishedID, nTime = nTime, nSecret = encryptedNum}))
    --刷新
    Questionnaire.Refresh()
end

--临时接口:完成指定ID问卷
function Questionnaire.OnFinishQuestID( questid )
    --print("Questionnaire.OnFinishQuestID", questid)
    if questid ~= Questionnaire.CurID then return false end 
    Questionnaire.FinishedID = Questionnaire.CurID
    local cfg = Questionnaire.tbConfig[Questionnaire.FinishedID]
    if not cfg or Questionnaire.GetRecord(cfg.nMutexId) == 1 then return false end
    local sUI = UI.GetUI("Survey")
    if sUI then
        sUI:Close()
    end
    --通知
    local nTime = GetTime()
    local encryptedNum  = Questionnaire.Encrypt(Questionnaire.FinishedID, nTime)
    me:CallGS("Questionnaire_Finish", json.encode({nId = Questionnaire.FinishedID, nTime = nTime, nSecret = encryptedNum}))
    --刷新
    Questionnaire.Refresh()
end

function Questionnaire.Encrypt(finishedID, timestamp)
    local encryptedNum = (timestamp + finishedID + me:Id()) ~ Questionnaire.KEY
    return encryptedNum
end

---刷新问卷
function Questionnaire.Refresh()
    if not me or me:Id() == 0 then return end
    if not Questionnaire.tbConfig then return end
    --print('Questionnaire Refresh')
    local nQuestId = 0
    --todo 获得当前问卷
    local tbLst = {}
    local maxpriority = -1
    for _, iConf in pairs(Questionnaire.tbConfig) do
        local bValid = Questionnaire.CheckValid(iConf)
        --print("Questionnaire CheckAvaild", iConf.nQuestId, bValid)
        if bValid then
            table.insert(tbLst, iConf)
            if iConf.nPriority>maxpriority then 
                maxpriority = iConf.nPriority
                nQuestId = iConf.nQuestId
            end
        end
    end
    Questionnaire.OnRefreshQuestion(nQuestId)
end

---判断问卷是否有效
function Questionnaire.CheckValid(tbConf)
    local areaid = me:GetAreaID()
    local channel = me:Channel()
    local lan = Localization.sLanguage
    if tbConf.nPriority < 0 then return false end
    if not IsInTime(tbConf.nStartTime, tbConf.nEndTime) then return false  end
    if Questionnaire.tbConfig[Questionnaire.FinishedID] and tbConf.nMutexId == Questionnaire.tbConfig[Questionnaire.FinishedID].nMutexId then return false end
    if Questionnaire.GetRecord(tbConf.nMutexId) == 1 then return false end
    if tbConf.tbAreaLimit and not Contains(tbConf.tbAreaLimit, areaid) then return false end
    if tbConf.tbChannelLimit and not Contains(tbConf.tbChannelLimit, channel) then return false end
    if tbConf.tbLanguageLimit and not Contains(tbConf.tbLanguageLimit, lan) then return false end
    return Condition.Check(tbConf.tbCondition)
end

-- 得到问卷后回调
function Questionnaire.OnRefreshQuestion(nId)
    --记录得到的问卷
    Questionnaire.CurID = nId
    me:SetAttribute(Questionnaire.GROUPID, Questionnaire.SUBID_CURRENT, nId)
    ---触发问卷按钮event
    if nId > 0 then
        Questionnaire.CurCallback = Questionnaire.tbConfig[nId].sCallback
        EventSystem.Trigger(Event.ShowQuestionaire, true)
    else
        Questionnaire.CurCallback = ''
        EventSystem.Trigger(Event.ShowQuestionaire, false)
    end
end

---查询问卷回答记录
---@param nId integer 问卷ID
---@return integer 该问卷是否回答:0否1是
function Questionnaire.GetRecord(nId)
    if nId<1 or nId>320000 then return -1 end
    local subid = math.ceil(nId/32)
    local bit = nId % 32
    local nValue = me:GetAttribute(Questionnaire.GROUPID, subid)
    return GetBits(nValue, bit, bit)
end

---查询问卷点击
---comment
---@param nId integer 问卷ID, 缺省为当前问卷ID
---@return boolean 是否点击
function Questionnaire.isClickBefore(nId)
    local qId = nId or Questionnaire.CurID
    if qId > 0 and Questionnaire.tbConfig then 
        local cfg = Questionnaire.tbConfig[qId]
        if not cfg then return false end
        local subid = math.ceil(cfg.nMutexId / 32)
        local bit = cfg.nMutexId % 32
        local nValue = UE4.UUserSetting.GetInt(string.format("QuestionnaireClick_%d", subid), 0)
        --print('Questionnaire getInt mutexid, subid, bit, value', cfg.nMutexId, subid, bit, nValue)
        return GetBits(nValue, bit, bit)==1
    else
        return false
    end
end

---存储点击
function Questionnaire.Clicking(nId)
    local qId = nId or Questionnaire.CurID
    if qId > 0 and Questionnaire.tbConfig then 
        local cfg = Questionnaire.tbConfig[qId]
        if not cfg then return end
        local subid = math.ceil(cfg.nMutexId / 32)
        local bit = cfg.nMutexId % 32
        local nValue = UE4.UUserSetting.GetInt(string.format("QuestionnaireClick_%d", subid), 0)
        if GetBits(nValue, bit, bit)==1 then return end
        nValue = SetBits(nValue, 1, bit, bit)
        --print('Questionnaire setInt mutexid, subid, bit, value', cfg.nMutexId, subid, bit, nValue)
        UE4.UUserSetting.SetInt(string.format("QuestionnaireClick_%d", subid), nValue)
        UE4.UUserSetting.Save()
    else 
        return
    end
end


---初始化
Questionnaire.LoadConf()

---需要刷新问卷的事件
EventSystem.On(Event.LanguageChange, Questionnaire.Refresh)
EventSystem.On(Event.Kickout, Questionnaire.Reset)
---注册服务器完成问卷回调
s2c.Register("Questionnaire_Finish", function(tbRewards)
    EventSystem.Trigger(Event.GetBoxItem, tbRewards)
    Item.Gain(tbRewards)
    Questionnaire.Refresh()
end)