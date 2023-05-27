-- ========================================================
-- @File    : SevenDay.lua
-- @Brief   : 活动相关接口
-- ========================================================

SevenDay = SevenDay or {};
local tbClass = SevenDay;

tbClass.ActTypeDef = {
    GuideSevenDay = 1,--新人七天乐
}

function tbClass:Init()
    self.tbConfig = {}--key:ActId value: {TB:key:DayId,value:tbAchievement}

    local tbFile = LoadCsv("activity/seven_day/seven_day_achievements.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local actId = tonumber(tbLine.ActId or 0)
        if not self.tbConfig[actId] then
            self.tbConfig[actId] = {}
        end
        local dayId = tonumber(tbLine.DayId or 0)
        local tbAchievement = Eval(tbLine.AchieveId)
        self.tbConfig[actId][dayId] = tbAchievement;
    end

    self.exAwardCfg = {}--key:ActId value:{TB: key:AwardId,value:{needPoint,tbAward}}
    self.infoCfg = {}--存放一些客户端需要的配置:说明,美宣图啥的
    local tbFile2 = LoadCsv("activity/seven_day/seven_day_awards.txt", 1)
    for _, tbLine in ipairs(tbFile2) do
        local actId = tonumber(tbLine.ActId or 0)
        local awardId = tonumber(tbLine.AwardId or 0)
        local needPoint = tonumber(tbLine.NeedPoint or 0)
        if not self.exAwardCfg[actId] then
            self.exAwardCfg[actId] = {}
        end
        local tbAward = Eval(tbLine.TbAward)
        self.exAwardCfg[actId][awardId] = {};
        self.exAwardCfg[actId][awardId].needPoint = needPoint;
        self.exAwardCfg[actId][awardId].tbAward = tbAward;
        self.exAwardCfg[actId][awardId].itemAward = Eval(tbLine.ItemAward);
        if not self.infoCfg[actId] then
            self.infoCfg[actId] = {}
        end
        if needPoint > (self.infoCfg[actId].maxPoint or 0) then
            self.infoCfg[actId].maxPoint = needPoint
        end
    end

    self.SevenDayType = {}

    local tbFile3 = LoadCsv("activity/seven_day/seven_day_info.txt", 1)
    for _,tbLine in ipairs(tbFile3) do
        local actId = tonumber(tbLine.ActId or 0)
        local ActType = tonumber(tbLine.ActType or 0)
        if ActType ~= 0 then
            self.SevenDayType[ActType] = actId;
        end

        local ImgPath = tbLine.Img or ''
        local Intro = tbLine.Intro or ''
        if not self.infoCfg[actId] then
            self.infoCfg[actId] = {}
        end
        self.infoCfg[actId].imgPath = tonumber(ImgPath or 0);
        self.infoCfg[actId].intro = Intro;
        self.infoCfg[actId].SpineResKey = tbLine.SpineResKey or '芙提雅';
    end
end

--nType:ActTypeDef
function tbClass:GetSevenDayCfg(nType)
    if not nType or type(nType) ~= 'number' then
        return;
    end
    local actId = self.SevenDayType[self.ActTypeDef.GuideSevenDay]
    return self.tbConfig[actId]
end

function tbClass:GetSevenDayInfo(actId)
    return self.infoCfg and self.infoCfg[actId]
end

function tbClass:GetSevenDayExAwardCfg(actId)
    return self.exAwardCfg and self.exAwardCfg[actId]
end

function tbClass:GetNowSevenDayIndex(actId)
    if not actId then return end;
    return Activity.GetDiyData(actId,1)
end

function tbClass:GetNowOpenSevenDayCfg(nType)
    if not FunctionRouter.IsOpenById(FunctionType.SevenDay) then
        return
    end
    for actType,actId in pairs(self.SevenDayType) do
        if Activity.IsOpen(actId) then
            if actType == nType then--如果是新人七天乐就要判断是否领取全部奖励,领取完了就不显示入口了
                if actType == self.ActTypeDef.GuideSevenDay and not self:CheckGetAllReward(actId) then
                    return self.tbConfig[actId],actId
                end
            end
        end
    end
end

function tbClass:CheckGetAllReward(actId)
    local nowUnlockIndex = Activity.GetDiyData(actId,2)
    local actMaxIndex = self.exAwardCfg[actId] and #self.exAwardCfg[actId] or 0;
    for i=1,actMaxIndex do
        if GetBits(nowUnlockIndex,i,i) == 0 then
            return false;
        end
    end
    return true;
end

function tbClass:CheckHasAwardCanGet(actId)
    local cfg = self.tbConfig and self.tbConfig[actId]
    if not cfg then
        return
    end
    local nowIndexAward = Activity.GetDiyData(actId,2)
    local nowUnlockDay = Activity.GetDiyData(actId,1)
    --检测阶段奖励
    local tbCash = Activity.GetCashList(actId);
    local nowPoint = 0
    if #tbCash > 0 then
        nowPoint = Cash.GetMoneyCount(tbCash[1])
    end
    local exAwardCfg = self.exAwardCfg and self.exAwardCfg[actId]
    if exAwardCfg then
        for i,v in ipairs(exAwardCfg) do
            if v.needPoint <= nowPoint and GetBits(nowIndexAward,i,i) == 0 then
                return true;
            end
        end
    end

    --检测成就
    for dayId,tbAchievement in pairs(cfg) do
        if dayId <= nowUnlockDay then
            for k,v in pairs(tbAchievement) do
                local state = Achievement.CheckAchievementReward(v,true)
                if state == 1 then
                    return true
                end
            end
        end
    end
    return false;
end

function tbClass:CheckHasNewAchieveAward(actId,dayId)
    local cfg = self.tbConfig and self.tbConfig[actId]
    if not cfg then
        return
    end
    local nowIndexAward = Activity.GetDiyData(actId,2)
    local nowUnlockDay = Activity.GetDiyData(actId,1)

    --检测成就
        local tbAchievement = cfg[dayId]
        if tbAchievement and dayId <= nowUnlockDay then
            for k,v in pairs(tbAchievement) do
                local state = Achievement.CheckAchievementReward(v,true)
                if state == 1 then
                    return true
                end
            end
        end

    return false;
end
--检测某一天是否有未完成的成就
function tbClass:CheckHasUnCompletedAchieve(actId,dayId)
    local cfg = self.tbConfig and self.tbConfig[actId]
    if not cfg then
        return
    end
    local nowIndexAward = Activity.GetDiyData(actId,2)
    local nowUnlockDay = Activity.GetDiyData(actId,1)

    --检测成就
    local tbAchievement = cfg[dayId]
    if tbAchievement and dayId <= nowUnlockDay then
        for k,v in pairs(tbAchievement) do
            local state = Achievement.CheckAchievementReward(v,true)
            if state == 0 then
                return true
            end
        end
    end

    return false;
end

--检测新手七天乐
function tbClass:CheckAndShowSevenDayBtn(btnTrans,redPoint)
    if not btnTrans then
        return
    end

    local cfg,actId = self:GetNowOpenSevenDayCfg(self.ActTypeDef.GuideSevenDay)

    btnTrans.OnClicked:Clear()
    if cfg then
        WidgetUtils.Visible(btnTrans);
        BtnAddEvent(btnTrans,function ()
            UI.Open('NewTask',cfg,actId)
        end)

        if self:CheckHasAwardCanGet(actId) then 
            WidgetUtils.Visible(redPoint)
        else
            WidgetUtils.Collapsed(redPoint)
        end
        --UI.Open('NewTask',cfg,actId)
    else
        WidgetUtils.Collapsed(btnTrans)
    end
end

function tbClass:GetNextUnLockTime(actId)
    if not actId then return end
    local nowUnlockDay = Activity.GetDiyData(actId,1)
    local maxDay = #(self.tbConfig[actId] or {})

    if nowUnlockDay < maxDay then
        local nowTime = GetTime()
        local todayTime = nowTime % 86400
        local updateTime = (DailyTrigger or 4)*3600;
        if todayTime < updateTime then
            return updateTime - todayTime,true
        else
            return 86400 - todayTime + updateTime,true
        end
    end
    return -1,false
end

----------------------------存上次界面打开的参数-----------------
function tbClass:SetLastOpenCfgAndActId(cfg,actId,dayId)
    self.lastCfg = cfg;
    self.lastActId = actId;
    self.lastDayId = dayId or 1
end

function tbClass:GetLastOpenCfgAndActId()
    return self.lastCfg,self.lastActId,self.lastDayId
end

----------------------------服务器上行--------------------------
function tbClass:GetAcheveimentAward(actId,index,achievementId)
    if type(achievementId) ~= 'number' or type(index) ~= 'number' or type(actId) ~= 'number' then
        return
    end
    if not me then return end
    --print("HasSend!!",type(json.encode({achievementId = achievementId,actId = actId,index = index})))
    me:CallGS("Seven_day_getAchievementAward",json.encode({achievementId = achievementId,actId = actId,index = index}))
end

function tbClass:GetIndexAward(actId,index)
    if type(index) ~= 'number' or type(actId) ~= 'number' then
        return
    end
    if not me then return end
    me:CallGS("Seven_day_getIndexAward",json.encode({actId = actId,index = index}))
end
---------------------------------------------------------------

----------------------------注册服务器回调----------------------
s2c.Register("GetAchievementAwardRsp_SevenDay",function (tbParam)
    local ui = UI.GetUI('NewTask')
    if ui then
        ui:UpdateMission()
        ui:UpdateStage()
        local tbConfig = Achievement.GetQuestConfig(tbParam.achievementId);
        if tbConfig then
            Item.Gain(tbConfig.tbRewards)
        end
    end
end)

s2c.Register("GetIndexAwardRsp_SevenDay",function (tbParam)
    local ui = UI.GetUI('NewTask')
    if ui then
        ui:UpdateStage()
        local cfg = SevenDay.exAwardCfg[tbParam and tbParam.actId] and SevenDay.exAwardCfg[tbParam and tbParam.actId][tbParam.index]
        if cfg then
            Item.Gain({cfg.itemAward})
        end
    end
end)

s2c.Register("OnSevenDayIndexAdd",function (tbParam)
    if UI.IsOpen('NewTask') then
        UI.Close('NewTask')
    end
end)
---------------------------------------------------------------

tbClass:Init()
return SevenDay