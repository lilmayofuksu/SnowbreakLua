-- ========================================================
-- @File    : uw_dlcrogue_award_list.lua
-- @Brief   : 肉鸽活动奖励条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSelect, function() self:Click() end)
end

function tbClass:OnListItemObjectSet(pObj)
    local conf = pObj.Data
    self.TxtBg:SetText(Text(conf.sName))
    self.TxtCheckSecond:SetText(Text(conf.sName))
    self.pCall = conf.pCall
    self:UpdateState(false)
    if conf.bSelect then self:Click() end
end

function tbClass:Click()
    if self.pCall then self.pCall(self) end
end

function tbClass:UpdateState(bSelect)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.Check, bSelect)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.Bg, not bSelect)
end

return tbClass