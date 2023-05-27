-- ========================================================
-- @File    : umg_common_itemselect.lua
-- @Brief   : 头像控件?
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

---@param pItem  
function tbClass:OnOpen(iconId, borderId)
    if iconId and iconId > 0 then
        SetTexture(self.IconGirl, iconId)
    end

    if borderId and borderId > 0 then
        SetTexture(self.Image_61, borderId)
    end
end

function tbClass:OnClose()
end

return tbClass
