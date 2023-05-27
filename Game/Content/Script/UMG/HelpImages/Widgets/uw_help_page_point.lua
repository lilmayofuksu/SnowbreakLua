-- ========================================================
-- @File    : uw_help_page_point.lua
-- @Brief   : 图片轮播介绍界面的页码
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:SetChecked(isChecked)
    if isChecked then
        WidgetUtils.Collapsed(self.Unchecked)
        WidgetUtils.HitTestInvisible(self.Checked)
    else
        WidgetUtils.Collapsed(self.Checked)
        WidgetUtils.HitTestInvisible(self.Unchecked)
    end
end

return tbClass