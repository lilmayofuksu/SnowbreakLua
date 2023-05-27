-- ========================================================
-- @File    : uw_arms_attribute_list_Item.lua
-- @Brief   : 武器界面属性条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Update(tbData)
    local Des = UE4.UUMGLibrary.GetEnumValueAsString("EWeaponAttributeType",tbData.Type)
    self.Text_Cate:SetText(Text("attribute." .. Des))
    self.IText_Num:SetText(tbData.Num)
end

return tbClass
