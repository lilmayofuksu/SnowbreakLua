-- ========================================================
-- @File    : uw_level_group.lua
-- @Brief   : 关卡容器
-- ========================================================

local tbClass = Class("UMG.SubWidget")

local tbWidgetPath = {
    [0] = '/Game/UI/UMG/DLC1/Widgets/uw_dlc1_level_refresh.uw_dlc1_level_refresh_C',
    [1] = '/Game/UI/UMG/DLC1/Widgets/uw_dlc1_level_refresh.uw_dlc1_level_refresh_C',
    [2] = '/Game/UI/UMG/DLC1/Widgets/uw_dlc1_level_refresh.uw_dlc1_level_refresh_C',
    [7] = '/Game/UI/UMG/DLC1/Widgets/uw_dlc1_level_refresh.uw_dlc1_level_refresh_C',
}

local tbBranchWidget = 
{
    '/Game/UI/UMG/DLC1/Widgets/uw_dlc1_level_branchdown.uw_dlc1_level_branchdown_C',
    '/Game/UI/UMG/DLC1/Widgets/uw_dlc1_level_branchup.uw_dlc1_level_branchup_C'
}

function tbClass:Show(tbInfo, fClickFun)
    for i = 1, 2 do
        local tbLevel = tbInfo[i]
        if not tbLevel then
            WidgetUtils.Collapsed(self['Line'..i])
            WidgetUtils.Collapsed(self['Level'..i])
        else
            WidgetUtils.SelfHitTestInvisible(self['Line'..i])
            WidgetUtils.SelfHitTestInvisible(self['Level'..i])

            local levelId = type(tbLevel) == 'number' and tbLevel or tbLevel[1]
            local levelConf = DLCLevel.Get(levelId)
            local Widget = self:LoadLevelWidget(levelConf, self['Level'..i], fClickFun)
            local bUnLock = Condition.Check(levelConf)
            WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self['Lock'..i], not bUnLock)
            WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self['Completed'..i], bUnLock)

            if type(tbLevel) == 'table' and #tbLevel > 1 then
                local branchId = i == 1 and 2 or 1
                if #tbLevel == 2 then
                    levelConf = DLCLevel.Get(tbLevel[2])
                    local branchWidget = LoadWidget(tbBranchWidget[i==1 and 1 or 2])
                    if branchWidget then
                        WidgetUtils.PlayEnterAnimation(branchWidget)
                        WidgetUtils.PlayEnterAnimation(branchWidget)
                        Widget.Center:AddChild(branchWidget)
                        local bUnLock = Condition.Check(levelConf)
                        WidgetUtils.Collapsed(bUnLock and branchWidget.Lock or branchWidget.Completed)
                        WidgetUtils.SelfHitTestInvisible(bUnLock and branchWidget.Completed or branchWidget.Lock)
                        self:LoadLevelWidget(levelConf, branchWidget.Level, fClickFun)
                    end
                else
                    local branchWidget = LoadWidget(tbBranchWidget[i==1 and 1 or 2])
                    if branchWidget then
                        WidgetUtils.PlayEnterAnimation(branchWidget)
                        WidgetUtils.PlayEnterAnimation(branchWidget)
                        Widget.Center:AddChild(branchWidget)
                        local tbConf = {DLCLevel.Get(tbLevel[2]), DLCLevel.Get(tbLevel[3])}
                        for j = 1, 2 do
                            WidgetUtils.Collapsed(Condition.Check(tbConf[j]) and branchWidget['Lock'..j] or branchWidget['Completed'..j])
                            WidgetUtils.SelfHitTestInvisible(Condition.Check(tbConf[j]) and branchWidget['Completed'..j] or branchWidget['Lock'..j])
                            self:LoadLevelWidget(tbConf[j], branchWidget['Level'..j], fClickFun)
                        end
                    end
                end
            end
        end
    end
    WidgetUtils.PlayEnterAnimation(self)
end

function tbClass:LoadLevelWidget(levelConf, parent, fClickFun)
    local Widget = LoadWidget(tbWidgetPath[levelConf.nType])
    local ui = UI.GetUI('Dlc1Refresh')
    if Widget then
        if ui and ui.LevelContent then 
            ui.LevelContent.tbLevelWidget[levelConf.nID] = Widget 
        end
        parent:AddChild(Widget)
        Widget:Init(levelConf.nID, function(cfg)
            local bUnLock, sLockDes = Condition.Check(cfg.tbCondition)
            if bUnLock == false then
                UI.ShowTip(sLockDes[1])
                return
            end

            if ui and ui.LevelContent then
                if ui.LevelContent.pSelectWidget then
                    ui.LevelContent.pSelectWidget:OnSelectChange(false)
                end
                ui.LevelContent.pSelectWidget = Widget
                ui.LevelContent.pSelectWidget:OnSelectChange(true)
            end

            self:FoucsItem(Widget)
            fClickFun(cfg)
        end)
    end
    return Widget
end

function tbClass:FoucsItem(pWidget)
    local pLevelUI = UI.GetUI('Dlc1Refresh')
    if pLevelUI then
        pLevelUI.LevelScrollBox:ScrollWidgetIntoView(pWidget, false, UE4.EDescendantScrollDestination.TopOrLeft, 400)
    end
end

return tbClass