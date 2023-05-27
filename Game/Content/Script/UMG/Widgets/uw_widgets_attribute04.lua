-- ========================================================
-- @File    : uw_widgets_attribute04.lua
-- @Brief   : 属性说明文本4号样式
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
    local nAdd = tonumber(pObj.Data.nAdd) or 0

    if nAdd > 0 then
        WidgetUtils.SelfHitTestInvisible(self.AddNode)
        self.TxtAddNum:SetText(pObj.Data.nAdd)
    else
        WidgetUtils.Collapsed(self.AddNode)
    end

    self.TxtName:SetText(pObj.Data.sName)
    self.TxtNum:SetText(pObj.Data.nNow)
end

return tbClass