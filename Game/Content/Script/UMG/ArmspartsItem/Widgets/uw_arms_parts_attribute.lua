-- ========================================================
-- @File    : uw_arms_parts_attribute.lua
-- @Brief   : 武器配件属性条目
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(InObj)
    local Data = InObj.Data
    if Data == nil then return end
    self.Text_Cate:SetText(Data.sDes)
    self.IText_Num:SetText(Data.nNow)
    self.TxtNumNew:SetText(Data.nAdd)
    SetTexture(self.ImgIcon, Data.nIcon)
end

return tbClass
