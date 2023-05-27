-- ========================================================
-- @File    : uw_level_content.lua
-- @Brief   : 关卡容器
-- ========================================================

local tbClass = Class("UMG.SubWidget")
 
function tbClass:Set(tbInfo, fClickFun)
    self.nLevelID = Chapter.GetLevelID()
    self.tbInfo = tbInfo
    local tbLevel = self.tbInfo.tbLevel
    for i = 1, #tbLevel do
        local Widget = self['Level' .. tbLevel[i]]
        if Widget then
            self.nLevelID = self.nLevelID or tbLevel[i]
            WidgetUtils.SelfHitTestInvisible(Widget)
            Widget:Init(tbLevel[i], function(cfg)

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
            local bSelect = self.nLevelID == tbLevel[i]
            Widget:SelectChange(bSelect)

            if bSelect or self.pSelectWidget == nil then
                self.pSelectWidget = Widget
            end
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
    local nPosX = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(pWidget:GetParent()):GetPosition().X
    if pLevelUI then
        pLevelUI.LevelScrollBox:ScrollWidgetIntoView(pWidget, false, UE4.EDescendantScrollDestination.TopOrLeft, 400)
    end
end

--- 选择一个关卡并滚动到视图中（新手指引时）
function tbClass:ScrollIntoView(widgetname)
    local Widget = self[widgetname]
    if Widget then
        if self.pSelectWidget then
            self.pSelectWidget:SelectChange(false)
        end
        self.pSelectWidget = Widget
        self.pSelectWidget:SelectChange(true)
        return Widget
    end
end

return tbClass
