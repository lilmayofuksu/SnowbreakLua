-- ========================================================
-- @File    : uw_widgets_attribute06.lua
-- @Brief   : 属性说明文本6号样式
-- ========================================================

local tbClass = Class("UMG.SubWidget")

---@param pWeapon UWeaponItem
function tbClass:SetData(pWeapon, bItemInfo)
    local attack = UE4.UItemLibrary.GetWeaponAbilityValueToStr(UE4.EWeaponAttributeType.Attack, pWeapon)
    if not bItemInfo then
        WidgetUtils.SelfHitTestInvisible(self.ItemInfo)
        WidgetUtils.Collapsed(self.ItemBox)
        WidgetUtils.Collapsed(self.IText_Num)
        self.Text_Cate:SetText(attack)
    else
        WidgetUtils.Collapsed(self.ItemInfo)
        WidgetUtils.SelfHitTestInvisible(self.ItemBox)
        WidgetUtils.Collapsed(self.IText_Num_1)
        self.Text_Cate_1:SetText(attack)
    end
end


return tbClass