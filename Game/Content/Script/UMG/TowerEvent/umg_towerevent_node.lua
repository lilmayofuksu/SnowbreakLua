-- ========================================================
-- @File    : umg_towerevent_map.lua
-- @Brief   : 爬塔-战术考核主界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.Title:SetCustomEvent(function()
        if self.OnTitleBack then
            self.OnTitleBack()
        end
        UI.Close(self)
    end)

    BtnAddEvent(self.AWARD_btn, function()
        if not self.TowerAward then
            self.TowerAward = WidgetUtils.AddChildToPanel(self.TowerEventPanel, "/Game/UI/UMG/TowerEvent/Widgets/uw_towerevent_reward.uw_towerevent_reward_C", 5)
        end
        if self.TowerAward then
            WidgetUtils.SelfHitTestInvisible(self.TowerAward)
            self.TowerAward:UpdateRewards(self.Chapter)
        end
    end)

    self.EventHandel = EventSystem.OnTarget(TowerEventChapter, 'CloseAwardList', function()
        WidgetUtils.Collapsed(self.TowerAward)
    end)
end

function tbClass:OnOpen(tbParam)
    self.tbParam = tbParam or self.tbParam
    self.Index = self.tbParam.Index
    self.Chapter = self.tbParam.Chapter
    self.nPassLevel = self.tbParam.nPassLevel
    self.OnTitleBack = self.tbParam.OnTitleBack
    self.TextChapter:SetText(string.format(Text('ui.TxtTowereventNum'), self.Index))
    self.TextBlock_71:SetText(string.format(Text('%d/%d', self.nPassLevel, #self.Chapter.tbLevel)))
    WidgetUtils.Collapsed(self.TowerInfo)
    self.uw_towerevent_node2:UpdateLevels(self.Chapter, self.LevelScrollBox_1, function(tbCfg, Callback)
        if not self.TowerInfo then
            self.TowerInfo = WidgetUtils.AddChildToPanel(self.Panel, "/Game/UI/UMG/Common/Widgets/uw_level_info.uw_level_info_C", 8)
        end
        if self.TowerInfo then
            WidgetUtils.SelfHitTestInvisible(self.TowerInfo)
            self.TowerInfo:Show(tbCfg)
            self.TowerInfo.tbFunc = Callback
        end
    end)
    self:UpdateRewards()
    WidgetUtils.Collapsed(self.TowerAward)
end

function tbClass:UpdateRewards()
    local tbInfo = TowerEvent.tbAwardConf[self.Chapter.nID]
    if not tbInfo then
        return
    end

    local nCanGetAward = 0
    local ShowRed = false
    for i, nNeedPassLevel in pairs(tbInfo.tbLevelCount) do
        if self.nPassLevel >= nNeedPassLevel then
            nCanGetAward = nCanGetAward + 1
            if not TowerEvent.IsReceive(self.Chapter.nID, i) then
                ShowRed = true
            end
        end
    end

    self.ImgBar:GetDynamicMaterial():SetScalarParameterValue("Percent", nCanGetAward / #tbInfo.tbLevelCount)
    if ShowRed then
        WidgetUtils.SelfHitTestInvisible(self.New)
    else
        WidgetUtils.Collapsed(self.New)
    end
end

function tbClass:OnReceiveCallback()
    if not self.Chapter then
        return
    end
    self:UpdateRewards()
    if self.TowerAward then
        self.TowerAward:UpdateRewards(self.Chapter)
    end
end

function tbClass:OnClose()
    EventSystem.Remove(self.EventHandel)
end


return tbClass
