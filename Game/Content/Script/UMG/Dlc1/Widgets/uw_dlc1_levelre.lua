-- ========================================================
-- @File    : uw_level_chapter.lua
-- @Brief   : 关卡容器
-- ========================================================

local tbClass = Class("UMG.SubWidget")

local tbWidgetPath = {
    [0] = '/Game/UI/UMG/DLC1/Widgets/uw_dlc1_level_refresh.uw_dlc1_level_refresh_C',
    [1] = '/Game/UI/UMG/DLC1/Widgets/uw_dlc1_level_refresh.uw_dlc1_level_refresh_C',
    [2] = '/Game/UI/UMG/DLC1/Widgets/uw_dlc1_level_refresh.uw_dlc1_level_refresh_C',
    [7] = '/Game/UI/UMG/DLC1/Widgets/uw_dlc1_level_refresh.uw_dlc1_level_refresh_C',
}

tbClass.tbLevelWidget = {}

function tbClass:Set(tbInfo, fClickFun)
    self.nLevelID = Chapter.GetLevelID()
    self.tbInfo = tbInfo
    local tbLevel = self.tbInfo.tbLevelBranch
    if #tbLevel == 0 then tbLevel = self.tbInfo.tbLevel end

    local levelId = type(tbLevel[1]) == 'number' and tbLevel[1] or tbLevel[1][1]
    local levelConf = DLCLevel.Get(levelId)
    local Widget = self:LoadLevelWidget(levelConf, self.Level1, fClickFun)
    if type(tbLevel[1]) == 'table' and #tbLevel[1] > 1 then
        if #tbLevel[1] == 2 then
            levelConf = DLCLevel.Get(tbLevel[1][2])
            local branchWidget = LoadWidget('/Game/UI/UMG/DLC1/Widgets/uw_dlc1_level_branchup.uw_dlc1_level_branchup_C')
            if branchWidget then
                Widget.Center:AddChild(branchWidget)
                local bUnLock = Condition.Check(levelConf)
                WidgetUtils.Collapsed(bUnLock and branchWidget.Lock or branchWidget.Completed)
                WidgetUtils.SelfHitTestInvisible(bUnLock and branchWidget.Completed or branchWidget.Lock)
                self:LoadLevelWidget(levelConf, branchWidget.Level, fClickFun)
            end
        else
            local branchWidget = LoadWidget('/Game/UI/UMG/DLC1/Widgets/uw_dlc1_level_branchdown.uw_dlc1_level_branchdown_C')
            if branchWidget then
                Widget.Center:AddChild(branchWidget)
                local tbConf = {DLCLevel.Get(tbLevel[1][2]), ChapterLevel.Get(tbLevel[1][3])}
                for j = 1, 2 do
                    WidgetUtils.Collapsed(Condition.Check(tbConf[j]) and branchWidget['Lock'..j] or branchWidget['Completed'..j])
                    WidgetUtils.SelfHitTestInvisible(Condition.Check(tbConf[j]) and branchWidget['Completed'..j] or branchWidget['Lock'..j])
                    self:LoadLevelWidget(tbConf[j], branchWidget['Level'..j], fClickFun)
                end
            end
        end
    end

    local idx = 1
    for i = 2, #tbLevel do
        if i % 2 == 0 then
            local GroupWidget = LoadWidget('/Game/UI/UMG/DLC1/Widgets/uw_dlc1_groupre.uw_dlc1_groupre_c')
            self.HorizontalBox:AddChild(GroupWidget)
            --GroupWidget:SetRenderTranslation(UE.FVector2D(-85 * (idx - 1), 0))
            GroupWidget:Show({tbLevel[i], tbLevel[i + 1]}, fClickFun)
            idx = idx + 1
        end
    end

    if self.pSelectWidget then
        local widget = self.pSelectWidget
        widget:OnSelectChange(true)
        self:FoucsItem(widget)

        if DLC_Chapter.bShowDetail == true then
            fClickFun(self.pSelectWidget.tbCfg)
            DLC_Chapter.bShowDetail = false
        end
    end
end

function tbClass:FoucsItem(pWidget)
    local pLevelUI = UI.GetUI('Dlc1Refresh')
    if pLevelUI then
        pLevelUI.LevelScrollBox:ScrollWidgetIntoView(pWidget, false, UE4.EDescendantScrollDestination.TopOrLeft, 400)
    end
end

--- 选择一个关卡并滚动到视图中（新手指引时）
function tbClass:ScrollIntoView(nLevelID, bSelect)
    local Widget = self.tbLevelWidget[nLevelID]
    if Widget then
        self:FoucsItem(Widget)
        if bSelect then
            if self.pSelectWidget then
                self.pSelectWidget:OnSelectChange(false)
            end
            self.pSelectWidget = Widget
            self.pSelectWidget:OnSelectChange(true)
        end
        return Widget
    end
end

function tbClass:LoadLevelWidget(levelConf, parent, fClickFun)
    local Widget = LoadWidget(tbWidgetPath[levelConf.nType])
    if Widget then
        self.tbLevelWidget[levelConf.nID] = Widget
        parent:AddChild(Widget)
        Widget:Init(levelConf.nID, function(cfg)
            local bUnLock, sLockDes = Condition.Check(cfg.tbCondition)
            if bUnLock == false then
                UI.ShowTip(sLockDes[1])
                return
            end

            if self.pSelectWidget then
                self.pSelectWidget:OnSelectChange(false)
            end

            self:FoucsItem(Widget)

            self.pSelectWidget = Widget
            self.pSelectWidget:OnSelectChange(true)
            fClickFun(cfg)
        end)
    end
    return Widget
end

return tbClass
