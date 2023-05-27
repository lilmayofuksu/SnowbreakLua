-- ========================================================
-- @File    : uw_level_group.lua
-- @Brief   : 关卡容器
-- ========================================================

local tbClass = Class("UMG.SubWidget")

local tbWidgetPath = {
    [0] = '/Game/UI/UMG/Level/Widgets/uw_level_item_common.uw_level_item_common_C',
    [1] = '/Game/UI/UMG/Level/Widgets/uw_level_item_boss.uw_level_item_boss_C',
    [2] = '/Game/UI/UMG/Level/Widgets/uw_level_item_st.uw_level_item_st_C',
    [3] = '/Game/UI/UMG/Level/Widgets/uw_level_item_elite.uw_level_item_elite_C',
    [7] = '/Game/UI/UMG/Level/Widgets/uw_level_item_ep.uw_level_item_ep_C',
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
            local levelConf = ChapterLevel.Get(levelId)
            local Widget = self:LoadLevelWidget(levelConf, self['Level'..i], fClickFun)
            local bUnLock = Condition.Check(levelConf)
            WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self['Lock'..i], not bUnLock)
            WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self['Completed'..i], bUnLock)

            if type(tbLevel) == 'table' and #tbLevel > 1 then
                local branchId = i == 1 and 2 or 1
                if #tbLevel == 2 then
                    levelConf = ChapterLevel.Get(tbLevel[2])
                    local branchWidget = LoadWidget(string.format('/Game/UI/UMG/Level/Widgets/uw_level_branch%d.uw_level_branch%d_C', branchId, branchId))
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
                    local branchWidget = LoadWidget(string.format('/Game/UI/UMG/Level/Widgets/uw_level_branch%dmulti2.uw_level_branch%dmulti2_c', branchId, branchId))
                    if branchWidget then
                        WidgetUtils.PlayEnterAnimation(branchWidget)
                        WidgetUtils.PlayEnterAnimation(branchWidget)
                        Widget.Center:AddChild(branchWidget)
                        local tbConf = {ChapterLevel.Get(tbLevel[2]), ChapterLevel.Get(tbLevel[3])}
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
    local ui = UI.GetUI('Level')
    if Widget then
        if ui and ui.LevelContent then ui.LevelContent.tbLevelWidget[levelConf.nID] = Widget end
        parent:AddChild(Widget)
        Widget:Init(levelConf.nID, function(cfg)
            local bUnLock, sLockDes = Condition.Check(cfg.tbCondition)
            if bUnLock == false then
                UI.ShowTip(sLockDes[1])
                return
            end

            if ui and ui.LevelContent then
                if ui.LevelContent.pSelectWidget then
                    ui.LevelContent.pSelectWidget:SelectChange(false)
                end
                ui.LevelContent.pSelectWidget = Widget
                ui.LevelContent.pSelectWidget:SelectChange(true)
            end

            self:FoucsItem(Widget)
            fClickFun(cfg)
        end)
    end
    return Widget
end

function tbClass:FoucsItem(pWidget)
    local pLevelUI = UI.GetUI('Level')
    if pLevelUI then
        pLevelUI.LevelScrollBox:ScrollWidgetIntoView(pWidget, false, UE4.EDescendantScrollDestination.TopOrLeft, 400)
    end
end

return tbClass