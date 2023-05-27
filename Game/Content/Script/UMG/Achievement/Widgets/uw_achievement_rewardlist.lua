-- ========================================================
-- @File    : uw_achievement_branchstory.lua
-- @Brief   : 任务界面  主线阶段奖励  单个奖励
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.ListItem)
    self.ListItem:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbConfig = pObj.Data

    self:ShowMain()
    self:ShowItem()
end

function tbClass:ShowMain()
    if not self.tbConfig then return end

    local sIdx = string.format("%02d", self.tbConfig.nChapterGroup)
    self.TxtNum:SetText(sIdx)
    self.TxtState:SetText()

    local isReceive = Achievement.IsReceive(self.tbConfig)
    local finishnum, num = Achievement.GetCompletion(self.tbConfig.nId)

    if finishnum == num then
        self.TxtState:SetText(Text("ui.TxtChapterFinish"))
    else
        self.TxtState:SetText(Text("ui.TxtChapterUnfinish"))
    end

    if isReceive then --已领取
        WidgetUtils.Collapsed(self.Current)
        WidgetUtils.HitTestInvisible(self.Completed)
    elseif Achievement.GetChapter() == self.tbConfig.nChapterGroup then --当前
        WidgetUtils.Collapsed(self.Completed)
        WidgetUtils.HitTestInvisible(self.Current)
    else --未完成
        WidgetUtils.Collapsed(self.Current)
        WidgetUtils.Collapsed(self.Completed)
    end
end

function tbClass:ShowItem()
    self:DoClearListItems(self.ListItem)

    if not self.tbConfig or not self.tbConfig.tbRewards then return end

    for i, v in ipairs(self.tbConfig.tbRewards) do
        local cfg = {G = v[1], D = v[2], P = v[3], L = v[4], N = v[5]}
        local pObj = self.Factory:Create(cfg)
        self.ListItem:AddItem(pObj)
    end
end


return tbClass