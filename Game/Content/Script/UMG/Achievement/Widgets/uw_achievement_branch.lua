-- ========================================================
-- @File    : uw_achievement_branch.lua
-- @Brief   : 任务界面  支线类条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnGo, function()
        Achievement.GoToUI(self.tbParam)
    end)
    BtnAddEvent(self.BtnGot, function()
        if not self.tbParam or not self.tbParam.nId then return end
        Achievement.GetReward(self.tbParam.nId)
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    self.Factory = Model.Use(self)

    self.tbParam = pObj.Data
    self.TxtTitle:SetText(Text(self.tbParam.sName))
    self.TxtContent:SetText(Achievement.GeDescribe(self.tbParam))
    self.TxtTitle_2:SetText(Text(self.tbParam.sName))
    self.TxtContent_2:SetText(Achievement.GeDescribe(self.tbParam))
    local now, num = Achievement.GetProgresAndSum(self.tbParam.nId)
    self.TxtNum:SetText(now .. "/" .. num)
    self.ExpBar:SetPercent(now / num)
    self:UpdateItemPanel()
    self:PlayAnimation(self.AllEnter)
end

---刷新任务信息的显示
function tbClass:UpdateItemPanel()
    local nId = self.tbParam.nId
    local state = Achievement.CheckAchievementReward(nId)
    if state == 0 then
        WidgetUtils.Collapsed(self.PanelGot)
        WidgetUtils.Collapsed(self.PanelCompleted)
        WidgetUtils.Visible(self.Content)
        WidgetUtils.Visible(self.PanelGo)
        if self.tbParam.sGotoUI or self.tbParam.sConditionGoto then
            WidgetUtils.Visible(self.PanelGo)
        else
            WidgetUtils.Collapsed(self.PanelGo)
        end
    elseif state == 1 then
        WidgetUtils.Collapsed(self.PanelCompleted)
        WidgetUtils.Visible(self.Content)
        WidgetUtils.Collapsed(self.PanelGo)
        WidgetUtils.Visible(self.PanelGot)
    elseif state == 2 then
        WidgetUtils.Collapsed(self.PanelGot)
        WidgetUtils.Collapsed(self.PanelGo)
        WidgetUtils.Visible(self.PanelCompleted)
        WidgetUtils.Collapsed(self.Content)
    end

    self:DoClearListItems(self.ListItem)
    if self.tbParam.tbRewards then
        for _, item in ipairs(self.tbParam.tbRewards) do
            local cfg = {G = item[1], D = item[2], P = item[3], L = item[4], N = item[5], bGeted = state == 2}
            local pObj = self.Factory:Create(cfg)
            self.ListItem:AddItem(pObj)
        end
    end
end

return tbClass