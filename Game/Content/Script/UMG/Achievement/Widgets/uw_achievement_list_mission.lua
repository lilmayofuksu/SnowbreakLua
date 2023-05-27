-- ========================================================
-- @File    : uw_achievement_list_mission.lua
-- @Brief   : 任务界面  日常周常任务条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnGo, function()
        Achievement.GoToUI(self.tbParam)
    end)
    BtnAddEvent(self.BtnGot, function()
        if not self.tbParam then return end

        if self.tbParam.tbGotFunc then --bp领取任务奖励
            self.tbParam.tbGotFunc()
            return
        end

        if not self.tbParam.nId or self.bQuest then return end
        Achievement.GetReward(self.tbParam.nId)--常规任务领取
    end)
    self.Factory = Model.Use(self)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data
    self.bQuest = (self.tbParam.nGroupId == Achievement.GroupID_Quest) --是否活动任务
    self.TxtTitle_1:SetText(Text(self.tbParam.sName))
    self.TxtContent_1:SetText(Achievement.GeDescribe(self.tbParam))

    self.TxtTitle_2:SetText(Text(self.tbParam.sName))
    self.TxtContent_2:SetText(Achievement.GeDescribe(self.tbParam))
    self:UpdateState()
    self:ShowAwardItem()
    self:ShowLock()
    self:PlayAnimation(self.AllEnter)
end

---刷新状态的显示和点击事件
function tbClass:UpdateState()
    local nId = self.tbParam.nId
    local state = Achievement.CheckAchievementReward(self.tbParam)
    local pointnum = 0
    local maxpoint = 1
    if not self.bQuest then
        pointnum = AchievementPoint.GetPoint(self.tbParam.nGroup)
        maxpoint = AchievementPoint.GetMaxPoint(self.tbParam.nGroup)
    end

    --活跃点获满以后，就不显示 前往等按钮
    if not self.bQuest and pointnum > 0 and maxpoint and maxpoint > 0 and pointnum >= maxpoint then
        WidgetUtils.Hidden(self.PanelGot)
        WidgetUtils.Hidden(self.PanelCompleted)
        WidgetUtils.Visible(self.Content)
        WidgetUtils.Hidden(self.PanelGo)
    elseif state == 0 then
        WidgetUtils.Hidden(self.PanelGot)
        WidgetUtils.Hidden(self.PanelCompleted)
        WidgetUtils.Visible(self.Content)
        WidgetUtils.Visible(self.PanelGo)
        WidgetUtils.Collapsed(self.IconActiveGo)
        WidgetUtils.Collapsed(self.TxtNumGo)
    elseif state == 1 then
        WidgetUtils.Hidden(self.PanelGo)
        WidgetUtils.Hidden(self.PanelCompleted)
        WidgetUtils.Visible(self.Content)
        WidgetUtils.Visible(self.PanelGot)
        WidgetUtils.Collapsed(self.IconActiveGot)
        WidgetUtils.Collapsed(self.TxtNumGot)
    elseif state == 2 then
        WidgetUtils.Hidden(self.PanelGo)
        WidgetUtils.Hidden(self.PanelGot)
        WidgetUtils.Visible(self.PanelCompleted)
        WidgetUtils.Collapsed(self.TxtNumCompleted)
        WidgetUtils.Collapsed(self.Content)
    end


    if WidgetUtils.IsVisible(self.PanelGo) and (not self.tbParam or (not self.tbParam.sGotoUI and not self.tbParam.sConditionGoto)) then
        WidgetUtils.Hidden(self.PanelGo)
        WidgetUtils.Visible(self.PanelNo)
    else
        WidgetUtils.Hidden(self.PanelNo)
    end

    local now, num = Achievement.GetProgresAndSum(self.tbParam)
    self.ExpBar_1:SetPercent(now / num)
    self.TxtNum_1:SetText(now .. "/" .. num)
end


-- 显示奖励
function tbClass:ShowAwardItem()
    self:DoClearListItems(self.ListItem)
    if not self.tbParam then
        return
    end

    if self.tbParam.nGroupId == Achievement.GroupID_Quest then
        if self.tbParam and self.tbParam.tbRewards then
            for i,v in ipairs(self.tbParam.tbRewards) do
                local obj = self.Factory:Create({G = v[1],D = v[2],P = v[3],L = v[4],N =v[5] or 1})
                self.ListItem:AddItem(obj)
            end
        end
    else
        if self.tbParam.nAchievementPoint  and self.tbParam.nAchievementPoint > 0 then
            local obj = self.Factory:Create({G = Achievement.DegreeItem[1],D = Achievement.DegreeItem[2],P = Achievement.DegreeItem[3],L = Achievement.DegreeItem[4],N =self.tbParam.nAchievementPoint})
            self.ListItem:AddItem(obj)
        end
    end
end

function tbClass:ShowLock()
    if not self.tbParam.tbCondition or #self.tbParam.tbCondition == 0 then
        WidgetUtils.Collapsed(self.Locked)
        return
    end

    local bUnLock, tbDes = Condition.Check(self.tbParam.tbCondition)
    if not bUnLock then
        WidgetUtils.Visible(self.Locked)
        self.TxtLock:SetText(tbDes[1] or "")
    else
        WidgetUtils.Collapsed(self.Locked)
    end
end

return tbClass