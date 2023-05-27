-- ========================================================
-- @File    : uw_widgets_award_star.lua
-- @Brief   : 通用材料显示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Set(bSuc, sDes, sProgress, bHasGot)
    self.Des:SetText(sDes)
    self.TxtTarget:SetText(sProgress)
    WidgetUtils.Collapsed(self.PanelFail)
    if bSuc then
        WidgetUtils.SelfHitTestInvisible(self.Succ)
        WidgetUtils.HitTestInvisible(self.Image1)
        WidgetUtils.HitTestInvisible(self.Image2)
        self.Des:SetRenderOpacity(1)
        self.img:SetRenderOpacity(1)
        if bHasGot then WidgetUtils.Collapsed(self.TxtTarget) end
    else
        WidgetUtils.Collapsed(self.Succ)
        WidgetUtils.Collapsed(self.Image1)
        WidgetUtils.Collapsed(self.Image2)
        self.Des:SetRenderOpacity(0.4)
        self.img:SetRenderOpacity(0.4)
    end
end

return tbClass