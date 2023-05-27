-- ========================================================
-- @File    : umg_newtask.lua
-- @Brief   : 新手7天乐
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.ListTask:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.ListDay:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

function tbClass:OnInit()
    WidgetUtils.Hidden(self.ItemTip)
end

function tbClass:OnOpen(cfg,actId)

    self.Factory = Model.Use(self);

    if cfg and actId then
        self.cfg = cfg;
        self.actId = actId;
        SevenDay:SetLastOpenCfgAndActId(self.cfg,self.actId,self.dayId)
    else
        self.cfg,self.actId,self.dayId = SevenDay:GetLastOpenCfgAndActId();
    end

    local info = SevenDay:GetSevenDayInfo(self.actId)
    self.maxPoint = info.maxPoint or 1;

    --活动介绍
    --[[WidgetUtils.Hidden(self.Activity)
    self.Info:SetBtnListener(function ()
        WidgetUtils.Visible(self.Activity)
    end)
    self.Activity:SetInfo(info.intro,function ()
        WidgetUtils.Hidden(self.Activity)
    end);]]

    --天数tab
    local nowUnLockDay = SevenDay:GetNowSevenDayIndex(self.actId)
    if nowUnLockDay > #(self.cfg or {}) then
        nowUnLockDay = #(self.cfg or {})
    end
    if not UI.bPoping then
        self.dayId = nowUnLockDay--默认选中最新解锁的一天
        SevenDay:SetLastOpenCfgAndActId(self.cfg,self.actId,self.dayId)
    end
    self:DoClearListItems(self.ListDay)
    for dayId,tbAchieve in ipairs(self.cfg) do
        local tbParam = {}
        tbParam.dayId = dayId;
        tbParam.actId = actId
        tbParam.onClick = function ()
            self:UpdateMission(dayId)
            --self.dayId = dayId;
            self.ListDay:RegenerateAllEntries()
            self:UpdateStage()
        end
        tbParam.nowUnLockDay = nowUnLockDay;
        local obj = self.Factory:Create(tbParam)
        self.ListDay:AddItem(obj)
        if dayId == self.dayId then
            tbParam.onClick()
        end
    end

    --设置美宣图
    WidgetUtils.SelfHitTestInvisible(self.ImgSer)
    SetTexture(self.ImgSer,Resource.Get(info and info.imgPath))
    WidgetUtils.Collapsed(self.Spine)
    --[[local spineKey = info and info.SpineResKey or '芙提雅'
    --设置spine
    if self.NowSpineKey ~= spineKey then
        self.Spine:PlayDefaultSpine(spineKey)
    end
    self.NowSpineKey = spineKey]]

    --WidgetUtils.Collapsed(self.Spine)

    --设置倒计时
    --self:ClearTimer()

    --self.nCountDownTime,self.notUnlockAll = SevenDay:GetNextUnLockTime(actId);
    --[[if self.notUnlockAll then
        WidgetUtils.Visible(self.Time)
        self.Time:SetTime(self.nCountDownTime);
        self.nCountDown = UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                    self.nCountDownTime = self.nCountDownTime - 1
                    self.Time:SetTime(self.nCountDownTime);
                end
            },
            2.0,
            true
        )
    else]]
        WidgetUtils.Collapsed(self.Time)
    --end

    --设置阶段奖励
    self.TxtPt:SetText(info.maxPoint)
    self:UpdateStage()

    self.TxtIntro:SetContent(Text(info.intro))

    if self.TxtName then
        self.TxtName:SetText(Text('weapon.gun2004'))
    end
end

function tbClass:UpdateMission(dayId)
    dayId = dayId or self.dayId
    self.dayId = dayId;
    SevenDay:SetLastOpenCfgAndActId(self.cfg,self.actId,self.dayId)
    self:DoClearListItems(self.ListTask)
    local tbAchievement = self.cfg and self.cfg[dayId]
    self:Bubbling(tbAchievement,function (a,b)
        local stateA = Achievement.CheckAchievementReward(a,true)
        local stateB = Achievement.CheckAchievementReward(b,true)
        if stateA > 1 then stateA = -1 end
        if stateB > 1 then stateB = -1 end
        return stateA > stateB;
    end)

    for i,achieveId in ipairs(tbAchievement) do
        local obj = self.Factory:Create({achieveId = achieveId,actId = self.actId,dayId = self.dayId})
        self.ListTask:AddItem(obj)
    end
    if not UI.bPoping then
        self.ListTask:ScrollIndexIntoView(0)
    end
end

function tbClass:Bubbling(tb,func)
    for i = 1,#tb do
        for j = #tb,i+1,-1 do
            if func(tb[j],tb[j-1]) then
                local t = tb[j-1];
                tb[j-1] = tb[j]
                tb[j] = t;
            end
        end
    end
end

function tbClass:UpdateStage()
    WidgetUtils.Collapsed(self.ItemTip)
    local tbCash = Activity.GetCashList(self.actId);
    local nowPoint = 0
    if #tbCash > 0 then
        nowPoint = Cash.GetMoneyCount(tbCash[1])
        self.TxtPoint:SetText(math.min(self.maxPoint or 1,nowPoint))
    end

    self:DoClearListItems(self.ListReward)
    local exAwardCfg = SevenDay:GetSevenDayExAwardCfg(self.actId)
    if not exAwardCfg then
        return
    end
    self.ProgressBar_Pt:SetPercent(self:GetStageBarPer(exAwardCfg,nowPoint,math.max(self.maxPoint or 1,1)))
    local nowIndexAward = Activity.GetDiyData(self.actId,2)
    local maxAwardIndex = #exAwardCfg
    for i,indexCfg in ipairs(exAwardCfg) do
        local tbParam = {
            --tbAward = indexCfg.tbAward,
            itemAward = indexCfg.itemAward,
            needPoint = indexCfg.needPoint,
            nowPoint = nowPoint,
            gotState = GetBits(nowIndexAward,i,i),
            index = i,
            maxIndex = maxAwardIndex,
            actId = self.actId,
            preViewFunc = function ( ... )
                if self.ItemTip == nil then
                    self.ItemTip = WidgetUtils.AddChildToPanel(self.panelnew, '/Game/UI/UMG/Common/Widgets/uw_achievement_itemtip.uw_achievement_itemtip_C', 4)
                end

                if self.ItemTip then
                    WidgetUtils.Visible(self.ItemTip)
                    self.ItemTip:Init(indexCfg.tbAward, GetBits(nowIndexAward,i,i) + 1)
                end
            end,
            getAwardFunc = function ()
                SevenDay:GetIndexAward(self.actId, i)
            end
        }
        local pObj = self.Factory:Create(tbParam)
        self.ListReward:AddItem(pObj)
    end
    self.ListDay:RegenerateAllEntries()

    self.ListReward:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.ListReward:SetWheelScrollMultiplier(0)
end

function tbClass:ClearTimer()
    --[[if self.nCountDown then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.nCountDown)
    end]]
end

function tbClass:GetStageBarPer(exAwardCfg,nowPoint,maxPoint)
    local allStageCount = #exAwardCfg;
    local res = 0
    if allStageCount < 1 then
        return 0
    end
    if nowPoint > exAwardCfg[allStageCount].needPoint then
        return 1
    end
    for i=1,allStageCount do
        if nowPoint > exAwardCfg[i].needPoint then
            res = res + 1/allStageCount
        else
            local preNeedCount = (i-1) > 0 and exAwardCfg[i-1].needPoint or 0
            res = res + (nowPoint - preNeedCount) * (1/allStageCount) / (exAwardCfg[i].needPoint - preNeedCount)
            break
        end
    end
    return res
end

function tbClass:OnClose()
    --self:ClearTimer()
    --self.NowSpineKey = nil
end

return tbClass