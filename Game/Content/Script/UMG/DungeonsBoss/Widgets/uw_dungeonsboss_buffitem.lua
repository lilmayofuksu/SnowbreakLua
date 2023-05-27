-- ========================================================
-- @File    : uw_dungeonsboss_buffitem.lua
-- @Brief   : boss挑战词条条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnNormal, function()
        if not self.EntrieCfg then return end
        BossLogic.AddEntrie(self.EntrieCfg.nID)
        self.tbParam.UpdateSelect()
    end)
    BtnAddEvent(self.BtnDisable, function()
        if not self.EntrieCfg then return end
        BossLogic.AddEntrie(self.EntrieCfg.nID)
        self.tbParam.UpdateSelect()
    end)
    BtnAddEvent(self.BtnSelected, function()
        if not self.EntrieCfg then return end
        BossLogic.ReduceEntrie(self.EntrieCfg.nID)
        self.tbParam.UpdateSelect()
    end)
end

function tbClass:UpdatePanel(info)
    self.tbParam = info

    if not self.tbParam then return end
    self.EntrieCfg = self.tbParam.cfg

    self:UpdateState()
end

function tbClass:ShowBasicsItem()
    WidgetUtils.Collapsed(self.PanelNormal)
    WidgetUtils.Collapsed(self.PanelDisable)
    WidgetUtils.Collapsed(self.PanelLock)
    WidgetUtils.SelfHitTestInvisible(self.PanelSelected)
end

function tbClass:UpdateState()
    local nState, sDesc = BossLogic.GetEntrieState(self.EntrieCfg.nID)
    if nState == 0 then
        self:SetLock(sDesc)
    elseif nState == 1 then
        self:OnSelect()
    elseif nState == 2 then
        self:UnSelect()
    else
        self:SetDisable()
    end
end

---设置为锁定状态
function tbClass:SetLock(desc)
    WidgetUtils.Collapsed(self.PanelNormal)
    WidgetUtils.Collapsed(self.PanelSelected)
    WidgetUtils.Collapsed(self.PanelDisable)
    WidgetUtils.HitTestInvisible(self.PanelLock)
    self.TextLockNum:SetText(self.EntrieCfg.nScore)
    if desc then
        self.TxtLock:SetText(desc)
    end
end

---设置为未选中状态
function tbClass:UnSelect()
    WidgetUtils.Collapsed(self.PanelSelected)
    WidgetUtils.Collapsed(self.PanelDisable)
    WidgetUtils.Collapsed(self.PanelLock)
    WidgetUtils.SelfHitTestInvisible(self.PanelNormal)
    self.TextNormalNum:SetText(self.EntrieCfg.nScore)
    self.TxtNormal:SetText(Text(self.EntrieCfg.sDesc or self.EntrieCfg.nID))
end

---设置为选中状态
function tbClass:OnSelect()
    WidgetUtils.Collapsed(self.PanelNormal)
    WidgetUtils.Collapsed(self.PanelDisable)
    WidgetUtils.Collapsed(self.PanelLock)
    WidgetUtils.SelfHitTestInvisible(self.PanelSelected)
    self.TextSelectedNum:SetText(self.EntrieCfg.nScore)
    self.TxtSelected:SetText(Text(self.EntrieCfg.sDesc or self.EntrieCfg.nID))
end

---设置为不可选中状态
function tbClass:SetDisable()
    WidgetUtils.Collapsed(self.PanelNormal)
    WidgetUtils.Collapsed(self.PanelSelected)
    WidgetUtils.Collapsed(self.PanelLock)
    WidgetUtils.SelfHitTestInvisible(self.PanelDisable)
    self.TextDisableNum:SetText(self.EntrieCfg.nScore)
    self.TxtDisable:SetText(Text(self.EntrieCfg.sDesc or self.EntrieCfg.nID))
end

return tbClass