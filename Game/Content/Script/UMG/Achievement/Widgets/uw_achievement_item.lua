-- ========================================================
-- @File    : uw_achievement_item.lua
-- @Brief   : 任务界面  成就类条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")
tbClass.sIcon = "/Game/UI/UI/Task/Frames/gui_achieve01_icon004_05_png.gui_achieve01_icon004_05_png"

function tbClass:Construct()
    self:DoClearListItems(self.ListItem)
end

function tbClass:OnListItemObjectSet(pObj)
    self.Factory = Model.Use(self)

    self.tbParam = pObj.Data
    self.TxtTitle:SetText(Text(self.tbParam.sName))
    self.TxtContent:SetText(Achievement.GeDescribe(self.tbParam))
    self.TxtTitle_2:SetText(Text(self.tbParam.sName))
    self.TxtContent_2:SetText(Achievement.GeDescribe(self.tbParam))
    if self.tbParam.nIcon then
        SetTexture(self.ImgIcon, self.tbParam.nIcon)
    else
        SetTexture(self.ImgIcon, tbClass.sIcon)
    end

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
        self.BtnGo.OnClicked:Clear()
        self.BtnGo.OnClicked:Add(self, function()
            Achievement.GoToUI(self.tbParam)
        end)
    elseif state == 1 then
        WidgetUtils.Collapsed(self.PanelCompleted)
        WidgetUtils.Visible(self.Content)
        WidgetUtils.Visible(self.PanelGot)
        WidgetUtils.Hidden(self.PanelGo)
        self.BtnGot.OnClicked:Clear()
        self.BtnGot.OnClicked:Add(self, function()
            Achievement.GetReward(nId)
        end)
    elseif state == 2 then
        WidgetUtils.Collapsed(self.PanelGot)
        WidgetUtils.Visible(self.PanelCompleted)
        WidgetUtils.Collapsed(self.Content)
        WidgetUtils.Hidden(self.PanelGo)
        -- local timestr = os.date("%Y/%m/%d", Achievement.GetFirstTime(nId))
        -- self.TxtTime:SetText(timestr)
    end

    if WidgetUtils.IsVisible(self.PanelGo) and (not self.tbParam or (not self.tbParam.sGotoUI and not self.tbParam.sConditionGoto)) then
        WidgetUtils.Hidden(self.PanelGo)
        WidgetUtils.Visible(self.PanelNo)
    else
        WidgetUtils.Hidden(self.PanelNo)
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