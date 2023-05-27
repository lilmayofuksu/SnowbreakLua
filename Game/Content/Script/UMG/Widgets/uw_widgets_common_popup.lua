-- ========================================================
-- @File    : uw_widgets_common_popup.lua
-- @Brief   : 通用弹窗背景
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Init(sTitle, fOnClose, nIconID)
    self.TxtTitle:SetText(sTitle)
    BtnClearEvent(self.BtnClose)
    BtnAddEvent(self.BtnClose, fOnClose)
    if nIconID then
        WidgetUtils.Visible(self.ImgSystem)
        SetTexture(self.ImgSystem, nIconID)
    else
        WidgetUtils.Hidden(self.ImgSystem)
    end
end

function tbClass:SetFunClose(fOnClose)
    if fOnClose then
        BtnClearEvent(self.BtnClose)
        BtnAddEvent(self.BtnClose, fOnClose)
    end
end

return tbClass;