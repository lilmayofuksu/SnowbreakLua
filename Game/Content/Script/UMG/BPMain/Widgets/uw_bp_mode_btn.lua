-- ========================================================
-- @File    : uw_bp_mode_btn.lua
-- @Brief   : 导航按钮
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Button, function() if self.fClickFun then self.fClickFun(self.nType) end end)
end

function tbClass:OnListItemObjectSet(pObj)
    local tbParam = pObj.Data;
    self:Set(tbParam.nType, tbParam, tbParam.funcOnClick)
    self:SelectChange(tbParam.bSelected)
    self:UpdateRed()
    pObj.Data.SubUI = self
end

function tbClass:Set(nType, tbInfo, fClick)
    self.nType = nType
    self.fClickFun = fClick
    self.Text1:SetText(Text(tbInfo.sName))
    self.Text2:SetText(Text(tbInfo.sName))
    if tbInfo.nIcon then
        SetTexture(self.Icon1, tbInfo.nIcon)
        SetTexture(self.Icon2, tbInfo.nIcon)
    end
end

function tbClass:SelectChange(bSelect)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.PaneCheck)
        WidgetUtils.Collapsed(self.PaneUncheck)
    else
        WidgetUtils.Collapsed(self.PaneCheck)
        WidgetUtils.HitTestInvisible(self.PaneUncheck)
    end
end

function tbClass:UpdateRed()
    local bShow = BattlePass.CheckHaveRed(self.nType)
    if bShow then
         WidgetUtils.HitTestInvisible(self.Red)
    else
         WidgetUtils.Collapsed(self.Red)
    end
end

return tbClass