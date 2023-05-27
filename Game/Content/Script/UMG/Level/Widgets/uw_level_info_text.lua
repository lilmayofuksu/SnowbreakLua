-- ========================================================
-- @File    : uw_level_info_text.lua
-- @Brief   : 星级目标显示
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:SetInfo(sTxt, bGet)
    self.Des:SetText(sTxt)
    if bGet then
        WidgetUtils.SelfHitTestInvisible(self.Succ)
        WidgetUtils.Collapsed(self.Fail)
    else
        WidgetUtils.Collapsed(self.Succ)
        WidgetUtils.SelfHitTestInvisible(self.Fail)
    end
end

return tbClass