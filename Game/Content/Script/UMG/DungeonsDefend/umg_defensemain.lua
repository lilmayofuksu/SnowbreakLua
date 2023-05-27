-- ========================================================
-- @File    : umg_defensemain.lua
-- @Brief   : 死斗活动主界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.ListFactory = self.ListFactory or Model.Use(self)
    self:DoClearListItems(self.ListScreen)
    WidgetUtils.Collapsed(self.Popup)

    BtnAddEvent(self.BtnIntro, function()
        UI.Open("HelpImages", self.ActCfg.nHelpImg)
    end)

    BtnAddEvent(self.AWARD_btn, function()
        UI.Open('DefenseAward')
    end)

    BtnAddEvent(self.BtnChange, function()
        if not DefendLogic.CanChangeDiff() then
            UI.ShowMessage(Text('ui.TxtDefenseTip3'))
        else
            self.bShowList = not self.bShowList
            WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.ListScreen, self.bShowList)
        end
    end)

    BtnAddEvent(self.BtnShop, function() UI.Open('Shop', self.ActCfg.nShopId) end)

    if self.BtnMission then
        BtnAddEvent(self.BtnMission, function() UI.Open('Dlc1Award', 3) end)
    end
end

function tbClass:OnOpen()
    if #DefendLogic.tbCurTimeConf < 2 or not IsInTime(DefendLogic.tbCurTimeConf[1], DefendLogic.tbCurTimeConf[2]) then
        UI.CloseTop()
        DefendLogic.CheckOpenAct()
        return
    end

    Launch.SetType(LaunchType.DEFEND)
    self:PlayAnimation(self.AllEnter)
    self.nId, self.nDiff = DefendLogic.GetIDAndDiff()
    self.ActCfg = DefendLogic.GetOpenConf()
    if DefendLogic.GetCurDiff() == 0 then
        WidgetUtils.SelfHitTestInvisible(self.Popup)
        WidgetUtils.PlayEnterAnimation(self.Popup)
        self.Popup:Show()
    else
        WidgetUtils.Collapsed(self.Popup)
    end
    self:ShowInfo()
    DefendLogic.ShowGetAll()
    self.Time:ShowNormal(DefendLogic.tbCurTimeConf[2], function() DefendLogic.CheckOpenAct() end)
end

function tbClass:ShowInfo(bConfirm)
    self.nId, self.nDiff = DefendLogic.GetIDAndDiff()
    self.TxtLevel:SetText(tostring(self.nDiff))
    self.tbLevelConf = DefendLogic.GetLevelConf(self.nId, self.nDiff)
    self:UpdateWave()
    if not self.TowerInfo then
        self.TowerInfo = WidgetUtils.AddChildToPanel(self.CanvasPanel_39, '/Game/UI/UMG/Common/Widgets/uw_level_info2.uw_level_info2_C', 0)
        if self.TowerInfo then
            BtnAddEvent(self.TowerInfo.BtnMonsters, function() self:ShowMonInfo() end)
        end
    end
    if self.TowerInfo then
        self.TowerInfo:Show(self.tbLevelConf)
    end
    self:DoClearListItems(self.ListScreen)
    for _, v in ipairs(DefendLogic.tbLevelOrder[self.nId]) do
        local tb = {bSelect = v.nDiff == self.nDiff, nDiff = v.nDiff, bUnlock = v.nDiff <= DefendLogic.GetMaxDiff() + 1}
        tb.pCallBack = function ()
            if not tb.bUnlock then return UI.ShowMessage('ui.Defense_Unlock_Tips') end
            DefendLogic.ChangeDiff(tb.nDiff, function()
                    local ui = UI.GetUI(DefendLogic.sUI)
                    if ui then ui:ShowInfo()
                end
            end)
        end
        self.ListScreen:AddItem(self.ListFactory:Create(tb))
    end
    WidgetUtils.Collapsed(self.ListScreen)
    self.bShowList = false
    self:UpdateNew()
    if bConfirm and DefendLogic.IsFirstEnter() then
        UI.Open("HelpImages", 13)
    end
end

function tbClass:ShowMonInfo()
    UI.Open('DefenseInfo')
end

function tbClass:UpdateWave()
    self.Num:SetText(DefendLogic.GetMaxWave())
    self.Num_1:SetText(DefendLogic.GetCurrWave())
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.DifficultyTip, DefendLogic.CanChangeDiff() and DefendLogic.GetCurDiff() ~= 10)
end

function tbClass:UpdateNew()
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.DifficultyTip, DefendLogic.CanChangeDiff() and DefendLogic.GetCurDiff() ~= 10)
    local tbLevelConf = DefendLogic.GetLevelConf(self.nId, self.nDiff)
    if not tbLevelConf then return end
    for _, v in ipairs(tbLevelConf.tbTarget) do
        if DefendLogic.GetTargetState(v) == 1 then
            WidgetUtils.SelfHitTestInvisible(self.New)
            return
        end
    end
    WidgetUtils.Collapsed(self.New)
end

function tbClass:OnClose()
    self.Popup:ClearTimer()
end

return tbClass