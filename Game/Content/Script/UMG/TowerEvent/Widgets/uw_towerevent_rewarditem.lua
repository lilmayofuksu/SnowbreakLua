-- ========================================================
-- @File    : uw_towerevent_chapter.lua
-- @Brief   : 爬塔-战术考核章节选择界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListItem)
    self.ListFactory = Model.Use(self)
    BtnAddEvent(self.BtnGot, function()
        TowerEvent.GetReward(self.Data.nChapterID, self.Data.nGroup)
    end)
end

function tbClass:OnListItemObjectSet(tbParam)
    self.Data = tbParam.Data
    local nTpye = self.Data.nType
    local tbAward = self.Data.tbAward
    local CompletionPer = self.Data.CompletionPer

    self:DoClearListItems(self.ListItem)
    for _, v in pairs(tbAward) do
        local tbParam = {G = v[1], D = v[2], P = v[3], L = v[4], N = v[5]}
        local pObj = self.ListFactory:Create(tbParam)
        self.ListItem:AddItem(pObj)
    end

    WidgetUtils.Collapsed(self.PanelGain)
    WidgetUtils.Collapsed(self.PanelLock)
    WidgetUtils.Collapsed(self.PanelCompleted)
    if nTpye == 1 then
        WidgetUtils.SelfHitTestInvisible(self.PanelGain)
    elseif nTpye == 2 then
        WidgetUtils.SelfHitTestInvisible(self.PanelCompleted)
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelLock)
    end

    self.TxtLevel:SetText(Text("ui.TxtTowereventdes4", CompletionPer).."%")
    self.TxtLevel_1:SetText(Text("ui.TxtTowereventdes4", CompletionPer).."%")
end
return tbClass