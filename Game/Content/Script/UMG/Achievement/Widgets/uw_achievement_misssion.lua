-- ========================================================
-- @File    : uw_achievement_misssion.lua
-- @Brief   : 任务界面  每日 每周界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListMission)
    self.ListMission:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

function tbClass:OnOpen(nShowType, bRefresh)
    self.Factory = Model.Use(self)
    self.ShowType = nShowType
    self.bRefresh = bRefresh

    self:DoClearListItems(self.ListMission)
    self:ShowItems(self.ListMission)
    self:UpdatePointPenel()
end


---刷新活跃点数列表
function tbClass:UpdatePointPenel()
    local tbConfig = AchievementPoint.GetRewards(self.ShowType)
    if not tbConfig then
        WidgetUtils.Hidden(self.Active)
        return
    end

    local maxAwardIndex = #tbConfig
    if maxAwardIndex == 0 then
        WidgetUtils.Hidden(self.Active)
        return
    end

    local pointnum = AchievementPoint.GetPoint(self.ShowType)
    local maxpoint = tbConfig[maxAwardIndex].nPoint
    WidgetUtils.Visible(self.Active)
    self:DoClearListItems(self.ListReward)
    local tbShowConfig = nil
    for i, v in ipairs(tbConfig) do
        local state = AchievementPoint.CheckPointReward(self.ShowType, i)
        local showItem = v.tbRewards[1]
        if showItem then
            local tbParam = {
                tbAward = v.tbRewards,
                needPoint = v.nPoint,
                nowPoint = pointnum,
                gotState = ((state == 2) and 1 or 0),
                index = i,
                maxIndex = maxAwardIndex,
                preViewFunc = function ( ... )
                    UI.Open('CheckItem', v.tbRewards, (state == 2))
                end,
                getAwardFunc = function ()
                    AchievementPoint.GetReward(self.ShowType, i)
                end
            }

            if not tbShowConfig and state ~= 2 and not self.bRefresh then
                tbParam.tbPopConfig = v
                tbShowConfig = v
            end

            local pObj = self.Factory:Create(tbParam)
            self.ListReward:AddItem(pObj)
        end
    end

    if pointnum > maxpoint and maxpoint > 0 then
        self.TxtPoint:SetText(maxpoint)
    else
        self.TxtPoint:SetText(pointnum)
    end

    self.ExpBar:SetPercent(self:GetProgressBarValue(pointnum, maxpoint))

    if pointnum >= maxpoint  then
        WidgetUtils.SelfHitTestInvisible(self.Empty)
        WidgetUtils.Collapsed(self.ListMission)
    else
        WidgetUtils.Hidden(self.Empty)
        WidgetUtils.SelfHitTestInvisible(self.ListMission)
    end
end

---得到进度条的值
---@param count number 当前计数
---@param tbReward table 奖励配置列表
---@return float 进度条的值 0~1
function tbClass:GetProgressBarValue(count, nMax)
    if not count or not nMax then return 0 end
    
    if nMax <= 0 then return 0 end

    if count > nMax then return 1 end

    return count / nMax
end

function tbClass:ShowItems(ListView)
    if not ListView then return end

    self:DoClearListItems(ListView)
    local tbConfig = Achievement.GetTbConfigByGroup(self.ShowType)
    local tbfinished = {}      --已完成未领取
    local tbnotFinished = {}   --进行中
    local tbreceived = {}      --已领取
    local tbLockList = {}   --未解锁
    for _, config in ipairs(tbConfig) do
        if Achievement.IsPreFinished(config) then
            local situation = Achievement.CheckAchievementReward(config)
            if situation == Achievement.STATUS_GOT then
               if config.nReceivedShow > 0 then table.insert(tbreceived, config) end
            elseif situation == Achievement.STATUS_CAN then
                table.insert(tbfinished, config)
            else
                local bUnLock = Condition.Check(config.tbCondition)
                if not bUnLock then
                    table.insert(tbLockList, config)
                else
                    table.insert(tbnotFinished, config)
                end
            end
        end
    end

    for i, v in ipairs(tbfinished) do
        local pObj = self.Factory:Create(v)
        ListView:AddItem(pObj)
    end
    for i, v in ipairs(tbnotFinished) do
        local pObj = self.Factory:Create(v)
        ListView:AddItem(pObj)
    end

    table.sort(tbLockList, function (configA, configB)
        if not configA then return false end
        if not configB then return true end

        local tbInfoA = configA.tbCondition
        local tbInfoB = configB.tbCondition
        if not tbInfoA or #tbInfoA == 0 then return false end
        if not tbInfoB or #tbInfoB == 0 then return true end

        local infoA = tbInfoA[1]
        local infoB = tbInfoB[1]
        if not infoA or #infoA == 0 then return false end
        if not infoB or #infoB == 0 then return true end 

        if infoA[1] == infoB[1] then
            return infoA[2] < infoB[2] 
        end

        return infoA[1] < infoB[1]
    end);

    for i, v in ipairs(tbLockList) do
        local pObj = self.Factory:Create(v)
        ListView:AddItem(pObj)
    end
    
    for i, v in ipairs(tbreceived) do
        local pObj = self.Factory:Create(v)
        ListView:AddItem(pObj)
    end

    if bReset then
        ListView:ScrollIndexIntoView(0)
    end
end

return tbClass