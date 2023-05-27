-- ========================================================
-- @File    : uw_arms_attribute_subitem.lua
-- @Brief   : 武器界面属性条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
    local tbInfo = pObj.Data
    if not tbInfo then return end
    self.TxtName:SetText(Text(tbInfo.sDes))
    self.TxtNum:SetText(tbInfo.nValue)
end

return tbClass