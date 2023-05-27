-- ========================================================
-- @File    : uw_achievement_achievement.lua
-- @Brief   : 任务界面  成就界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListAchievement)
    self.ListAchievement:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

function tbClass:OnOpen(nShowType)
    self.Factory = Model.Use(self)
    self.ShowType = nShowType

    self:DoClearListItems(self.ListAchievement)
    self:ShowItems(self.ListAchievement)
end

function tbClass:ShowItems(ListView)
    if not ListView then return end

    self:DoClearListItems(ListView)
    local tbConfig = Achievement.GetTbConfigByGroup(self.ShowType)
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
        ListView:AddItem(pObj)
    end
    for i, v in ipairs(tbnotFinished) do
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