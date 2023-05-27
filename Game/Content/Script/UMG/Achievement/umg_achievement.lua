-- ========================================================
-- @File    : umg_achievement.lua
-- @Brief   : 成就界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")
--每日，每周， 成就，剧情
tbClass.sMainIcon = {1701088, 1701089, 1701092, 1701090}

tbClass.tbWidgetIndex = {
    [Achievement.GROUP_DAILY]  = 0, -- 日常任务
    [Achievement.GROUP_WEEK]   = 0, -- 周常任务
    [Achievement.GROUP_TARGET] = 1; -- 成就
    [Achievement.GROUP_BranchLine]    = 2; -- 支线任务
}

function tbClass:OnInit()
    self.tbClass = {}
    self.Factory = Model.Use(self);
    self:DoClearListItems(self.ListItem)

    self.BtnQuick.OnClicked:Add(self, function()
        self:DoQuickBtn()
    end)
end

function tbClass:OnOpen(nShowType)
    nShowType = tonumber(nShowType)
    if nShowType and nShowType >= Achievement.GROUP_DAILY and nShowType <= Achievement.GROUP_BranchLine then
        self.ShowType = nShowType
    end

    self:UpdateLeftListPanel()
    self:UpdateRightListPanel()
    self:PlayAnimation(self.Enter)
    self:PlayAnimation(self.AllEnter)

    self.Money:Init({Cash.MoneyType_Vigour, Cash.MoneyType_Silver, Cash.MoneyType_Gold})
end

---刷新左边列表
function tbClass:UpdateLeftListPanel()
    self:DoClearListItems(self.LeftList)
    self.PageItems = {};
    for i in pairs(Achievement.tbGroupConfig) do
        local _, nFunctionId = Achievement.GetTypeName(i)
        if i <= Achievement.GROUP_BranchLine and FunctionRouter.IsOpenById(nFunctionId or 0) then
            local tbParam = {}
            tbParam.type = i
            tbParam.sIcon = self.sMainIcon[i]
            tbParam.isOpen = Achievement.AchievementIsOpen(tbParam.type)
            if  not self.ShowType and tbParam.isOpen then
                self.ShowType = tbParam.type
            end
            tbParam.showType = self.ShowType
            tbParam.sLockText = "achievement.NotOpen"
            tbParam.sNameText = Achievement.GetTypeName(tbParam.type)
            tbParam.GetNewFlag = function()
                return Achievement.IsGroupHaveReceive(tbParam.type)
            end

            tbParam.UpdateSelect = function()
                if self.ShowType == tbParam.type then return end
                self.PageItems[self.ShowType]:SetSelect(false)
                self.PageItems[tbParam.type]:SetSelect(true)
                for k, v in pairs(self.PageItems) do
                    v.showType = tbParam.type
                end
                self.ShowType = tbParam.type
                self:UpdateRightListPanel(true)
                self:PlayAnimation(self.Enter)
            end
            local pObj = self.Factory:Create(tbParam);
            self.PageItems[i] = pObj.Data
            self.LeftList:AddItem(pObj)
        end
    end

    self.LeftList:PlayAnimation()
end

---刷新任务列表
function tbClass:UpdateRightListPanel(bReset, bRefresh)
    self:ShowQuickBtn()

    local nIndex = self.tbWidgetIndex[self.ShowType] or 0
    self.Switcher:SetActiveWidgetIndex(nIndex)

    local Widget = self.Switcher:GetActiveWidget()
    if not Widget then return end

    Widget:OnOpen(self.ShowType, bRefresh)
    if Widget.AllEnter then
        Widget:PlayAnimation(Widget.AllEnter)
    end
end

---领取奖励后刷新页面
function tbClass:OnReceiveUpdate(tbParam)
    for i,v in pairs(self.PageItems) do
        v:UpdateFlagShow()
    end
    
    self:UpdateRightListPanel(nil, true)
    if tbParam and tbParam.tbRewards and #tbParam.tbRewards > 0 then
        Item.Gain(tbParam.tbRewards)
    end
end

-- 一键领取 按钮显示
function tbClass:ShowQuickBtn()
    local bShow = Achievement.IsGroupHaveReceive(self.ShowType)
    if bShow then
        WidgetUtils.Visible(self.BtnQuick)
    else
        WidgetUtils.Collapsed(self.BtnQuick)
    end
end

--一键领取
function tbClass:DoQuickBtn()
    Achievement.QuickGetReward(self.ShowType)
end

return tbClass
