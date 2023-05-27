-- ========================================================
-- @File    : uw_achievement_branchstory.lua
-- @Brief   : 任务界面  主线界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.BtnLast_1.OnClicked:Add(self, function()
        if self.ShowBLineChapter > 1 then
            self.ShowBLineChapter = self.ShowBLineChapter - 1
            self:UpdateBranchLinePanel(true)
        end
        self:ShowPreNextBtn()
        if self.ShowBLineChapter < Achievement.GetChapter() then
            WidgetUtils.Collapsed(self.LockNext_1)
            WidgetUtils.HitTestInvisible(self.NormalNext_1)
        else
            WidgetUtils.Collapsed(self.NormalNext_1)
            WidgetUtils.HitTestInvisible(self.LockNext_1)
        end
    end)

    self.BtnNext_1.OnClicked:Add(self, function()
        local nowChapter = Achievement.GetChapter()
        if self.ShowBLineChapter < nowChapter then
            self.ShowBLineChapter = self.ShowBLineChapter + 1
            self:UpdateBranchLinePanel(true)
        else
            local sTip = "achievement.NotOpen"
            local extraRewardCfg = Achievement.GetExtraRewardCfg(self.ShowBLineChapter)
            if extraRewardCfg then
                local finishnum, num = Achievement.GetCompletion(extraRewardCfg.nId)
                if finishnum >= num then
                    sTip = "achievement.GetReward"
                end
            end

            UI.ShowMessage(sTip)
        end

        self:ShowPreNextBtn()
        if self.ShowBLineChapter < nowChapter then
            WidgetUtils.Collapsed(self.LockNext_1)
            WidgetUtils.HitTestInvisible(self.NormalNext_1)
        else
            WidgetUtils.Collapsed(self.NormalNext_1)
            WidgetUtils.HitTestInvisible(self.LockNext_1)
        end
    end)

    self.BtnReward.OnClicked:Add(self, function()
        self:ShowAllAward()
    end)

    self:DoClearListItems(self.ListBranchMission)
    self.ListBranchMission:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

function tbClass:OnOpen(nShowType)
    self.Factory = Model.Use(self)
    self.ShowType = nShowType
    self.ShowBLineChapter = Achievement.GetChapter()

    self:DoClearListItems(self.ListBranchMission)
    self:UpdateBranchLinePanel()
    self:ShowPreNextBtn()
end

---刷新支线任务界面
function tbClass:UpdateBranchLinePanel(bReset)
    self:DoClearListItems(self.ListBranchMission)
    local tbConfig = Achievement.GetAllBranchLine(self.ShowBLineChapter)
    local tbfinished = {}      --已完成未领取
    local tbnotFinished = {}   --进行中
    local tbreceived = {}      --已领取
    for _, config in ipairs(tbConfig) do
        if Achievement.IsPreFinished(config) then
            local situation = Achievement.CheckAchievementReward(config)
            if situation == Achievement.STATUS_GOT then
               if config.nReceivedShow > 0 then table.insert(tbreceived, config) end
            elseif situation == Achievement.STATUS_CAN then
                table.insert(tbfinished, config)
            else
                table.insert(tbnotFinished, config)
            end
        end
    end
    for i, v in ipairs(tbfinished) do
        local pObj = self.Factory:Create(v)
        self.ListBranchMission:AddItem(pObj)
    end
    for i, v in ipairs(tbnotFinished) do
        local pObj = self.Factory:Create(v)
        self.ListBranchMission:AddItem(pObj)
    end
    for i, v in ipairs(tbreceived) do
        local pObj = self.Factory:Create(v)
        self.ListBranchMission:AddItem(pObj)
    end

    if bReset then
        self.ListBranchMission:ScrollIndexIntoView(0)
    end

    --完成所有支线任务的额外奖励
    self:DoClearListItems(self.RewardsList)
    local extraRewardCfg = Achievement.GetExtraRewardCfg(self.ShowBLineChapter)
    if extraRewardCfg and extraRewardCfg.tbRewards then
        local isReceive = Achievement.IsReceive(extraRewardCfg)
        for i, v in ipairs(extraRewardCfg.tbRewards) do
            local cfg = {G = v[1], D = v[2], P = v[3], L = v[4], N = v[5], bGeted = isReceive}
            local pObj = self.Factory:Create(cfg)
            self.RewardsList:AddItem(pObj)
        end
        local finishnum, num = Achievement.GetCompletion(extraRewardCfg.nId)
        local nPer = finishnum / num
        self.TxtRewardNum:SetText(string.format("%d%%", math.floor(nPer*100)))
        local Mat = self.RoundYellow:GetDynamicMaterial()
        if Mat then
            Mat:SetScalarParameterValue("Percent", nPer)
        end

        if extraRewardCfg.sName then
            --self.TxtName_1:SetText(Text(extraRewardCfg.sName))
            self.TextBlock_158:SetText(Text(extraRewardCfg.sName))
        end

        if extraRewardCfg.nChapterIcon then
            SetTexture(self.Image_105, extraRewardCfg.nChapterIcon)
        end

        self.BtnGain.OnClicked:Clear()
        if isReceive then
            WidgetUtils.Collapsed(self.BtnGain)
            WidgetUtils.Visible(self.Completed)
            WidgetUtils.Collapsed(self.GainAble)
            WidgetUtils.HitTestInvisible(self.PanelBar)
        else
            if finishnum == num then
                WidgetUtils.HitTestInvisible(self.Completed)
                WidgetUtils.HitTestInvisible(self.GainAble)
                WidgetUtils.Visible(self.BtnGain)
                WidgetUtils.Collapsed(self.PanelBar)
                self.BtnGain.OnClicked:Add(self, function()
                    if finishnum >= num then
                        Achievement.GetExtraReward(extraRewardCfg.nId)
                    else
                        UI.ShowMessage('achievement.NotFinished')
                    end
                end)
            else
                WidgetUtils.Collapsed(self.Completed)
                WidgetUtils.Collapsed(self.BtnGain)
                WidgetUtils.HitTestInvisible(self.PanelBar)
            end
        end
    end
end

--显示 主线 前置 后置按钮
function tbClass:ShowPreNextBtn()
    WidgetUtils.Collapsed(self.Last_1)
    WidgetUtils.Collapsed(self.Next_1)
end

--显示所有奖励
function tbClass:ShowAllAward()
    local sUI = UI.GetUI("AchievementReward")
    if sUI and sUI:IsOpen() then
        UI.Close("AchievementReward")
    end

    UI.Open("AchievementReward")
end

return tbClass