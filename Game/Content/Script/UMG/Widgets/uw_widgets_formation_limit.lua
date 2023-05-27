-- ========================================================
-- @File    : uw_widgets_formation_limit.lua
-- @Brief   : 限制信息
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(InObj)
   local Data = InObj.Data
    if Data.bLimit then
        WidgetUtils.SelfHitTestInvisible(self.ImgNot)
    else
        WidgetUtils.Collapsed(self.ImgNot)
    end
    self.TxtType:SetText(Data.nId)
end

return tbClass