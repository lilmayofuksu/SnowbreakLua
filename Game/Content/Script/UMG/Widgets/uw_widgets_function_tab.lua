-- ========================================================
-- @File    : uw_widgets_function_tab.lua
-- @Brief   : 功能页签
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Btn, function() if self.fClickEvent then self.fClickEvent(self.nPage) end end)
end

function tbClass:Init(sName, nIcon, nPage, fClickEvent, bChecked, bDisbale)
    self.TxtName1:SetText(Text(sName))
    self.TxtName2:SetText(Text(sName))

    self.nPage = nPage or 0
    self.fClickEvent = fClickEvent
    self:SetChecked(bChecked or false)
    self:SetDisbale(bDisbale or false)

    SetTexture(self.ImgCheck, nIcon)
    SetTexture(self.ImgUncheck, nIcon)
end

function tbClass:SetChecked(bChecked)
    if bChecked then
        WidgetUtils.HitTestInvisible(self.Checked)
        WidgetUtils.Collapsed(self.Unchecked)
    else
        WidgetUtils.Collapsed(self.Checked)
        WidgetUtils.HitTestInvisible(self.Unchecked)
    end
end

function tbClass:SetDisbale(bDisbale)
    if bDisbale then
        WidgetUtils.Visible(self.Disable)
    else
        WidgetUtils.Hidden(self.Disable)
    end
end

return tbClass