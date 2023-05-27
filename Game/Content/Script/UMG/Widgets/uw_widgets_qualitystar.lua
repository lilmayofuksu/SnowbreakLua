-- ========================================================
-- @File    : uw_widgets_qualitystar.lua
-- @Brief   : 星级显示
-- ========================================================

local tbClass = Class("UMG.SubWidget")


function tbClass:OnListItemObjectSet(pObj)
    self:Display(pObj.Data)
end

function tbClass:Display(tbData)
    if not tbData then return end
    
end

return tbClass