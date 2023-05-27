-- ========================================================
-- @File    : uw_widgets_multiple_list.lua
-- @Brief   : 多倍条目
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSelect,function()  self:DoClickItem() end)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbConfig = pObj.Data.tbConfig
    local bSelect = pObj.Data.bSelected
    self.tbFunc = pObj.Data.OnClick

    local sText = string.format("x%d", self.tbConfig.nMultiple)
    self.TxtNormalName:SetText(sText)

    self:ShowLock(self.tbConfig, sText)
    self:ShowSelect(bSelect, sText)
end

function tbClass:ShowLock(tbConfig, sText)
    if tbConfig and not Condition.Check(tbConfig.tbCondition) then
        WidgetUtils.HitTestInvisible(self.PanelLock)
        if sText then
            self.TxtSelectName_1:SetText(sText)
        end
    else
        WidgetUtils.Collapsed(self.PanelLock)
    end
end

function tbClass:ShowSelect(bSelect, sText)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.PanelSelect)
        if sText then
            self.TxtSelectName:SetText(sText)
        end
    else
        WidgetUtils.Collapsed(self.PanelSelect)
    end
end

function tbClass:DoClickItem()
    local bUnLock, tbDes = Condition.Check(self.tbConfig.tbCondition)
    if not bUnLock then
        UI.ShowTip(tbDes[1] or '')
        return
    end

    if self.tbFunc then
        self.tbFunc()
    end
end

return tbClass