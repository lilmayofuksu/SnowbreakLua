-- ========================================================
-- @File    : uw_level_chapter.lua
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

local tbBranchType = {
    ['UpBranch'] = {1,3,6,9,11,14,16},
    ['DownBranch'] = {2,4,5,7,8,10,12,13,15},
}

tbClass.tbLevelWidget = {}

function tbClass:Set(tbInfo, fClickFun)
    self.nLevelID = Chapter.GetLevelID()
    self.tbInfo = tbInfo
    local tbLevel = self.tbInfo.tbLevelBranch
    if #tbLevel == 0 then tbLevel = self.tbInfo.tbLevel end

    local levelId = type(tbLevel[1]) == 'number' and tbLevel[1] or tbLevel[1][1]
    local levelConf = ChapterLevel.Get(levelId)
    local Widget = self:LoadLevelWidget(levelConf, self.Level1, fClickFun)
    if type(tbLevel[1]) == 'table' and #tbLevel[1] > 1 then
        local branchId = 1
        if #tbLevel[1] == 2 then
            levelConf = ChapterLevel.Get(tbLevel[1][2])
            local branchWidget = LoadWidget(string.format('/Game/UI/UMG/Level/Widgets/uw_level_branch%d.uw_level_branch%d_C', branchId, branchId))
            if branchWidget then
                Widget.Center:AddChild(branchWidget)
                local bUnLock = Condition.Check(levelConf)
                WidgetUtils.Collapsed(bUnLock and branchWidget.Lock or branchWidget.Completed)
                WidgetUtils.SelfHitTestInvisible(bUnLock and branchWidget.Completed or branchWidget.Lock)
                self:LoadLevelWidget(levelConf, branchWidget.Level, fClickFun)
            end
        else
            local branchWidget = LoadWidget(string.format('/Game/UI/UMG/Level/Widgets/uw_level_branch%dmulti2.uw_level_branch%dmulti2_c', branchId, branchId))
            if branchWidget then
                Widget.Center:AddChild(branchWidget)
                local tbConf = {ChapterLevel.Get(tbLevel[1][2]), ChapterLevel.Get(tbLevel[1][3])}
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
            local GroupWidget = LoadWidget('/Game/UI/UMG/Level/Widgets/uw_level_group.uw_level_group_c')
            self.HorizontalBox_208:AddChild(GroupWidget)
            GroupWidget:SetRenderTranslation(UE.FVector2D(-85 * (idx - 1), 0))
            GroupWidget:Show({tbLevel[i], tbLevel[i + 1]}, fClickFun)
            idx = idx + 1
        end
    end

    if self.pSelectWidget then
        local widget = self.pSelectWidget
        widget:SelectChange(true)
        self:FoucsItem(widget)

        if Chapter.bShowDetail == true then
            fClickFun(self.pSelectWidget.tbCfg)
            Chapter.bShowDetail = false
        end
    end
end

function tbClass:FoucsItem(pWidget)
    local pLevelUI = UI.GetUI('Level')
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
                self.pSelectWidget:SelectChange(false)
            end
            self.pSelectWidget = Widget
            self.pSelectWidget:SelectChange(true)
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
                self.pSelectWidget:SelectChange(false)
            end

            self:FoucsItem(Widget)

            self.pSelectWidget = Widget
            self.pSelectWidget:SelectChange(true)
            fClickFun(cfg)
        end)
    end
    return Widget
end

return tbClass
