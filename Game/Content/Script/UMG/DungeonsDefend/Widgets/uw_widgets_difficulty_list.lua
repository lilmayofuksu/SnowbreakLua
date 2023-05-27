-- ========================================================
-- @File    : uw_widgets_difficulty_list.lua
-- @Brief   : 死斗难度条目
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
end

function tbClass:OnListItemObjectSet(pObj)
    BtnClearEvent(self.BtnSelect)
    self.tbData = pObj.Data
    BtnAddEvent(self.BtnSelect, self.tbData.pCallBack)
    self:Show()
end

function tbClass:Show()
    local StrName = Text('ui.TxtDifficulty') .. self.tbData.nDiff
    self.TxtNormalName:SetText(StrName)
    self.TxtSelectName_1:SetText(StrName)
    self.TxtSelectName:SetText(StrName)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.PanelSelect, self.tbData.bSelect)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.PanelLock, not self.tbData.bUnlock)
end

return tbClass