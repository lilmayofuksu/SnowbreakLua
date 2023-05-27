-- ========================================================
-- @File    : uw_widgets_attribute05.lua
-- @Brief   : 属性说明文本5号样式
-- ========================================================

local tbClass = Class("UMG.SubWidget")

---@param pWeapon UWeaponItem
function tbClass:SetData(pWeapon, bItemInfo, bWeaponDetail)
    local nSubValue, sSubType = Weapon.GetSubAttr(pWeapon)

    SetTexture(self.ImgIcon, Resource.GetAttrPaint(sSubType))
    self.Text_Cate:SetText(Text('attribute.' .. sSubType))

    WidgetUtils.Collapsed(self.IText_Num)
    WidgetUtils.Collapsed(self.IText_Num_1)

    if bWeaponDetail then
        WidgetUtils.HitTestInvisible(self.IText_Num_1)
        self.IText_Num_1:SetText(nSubValue)
    else
        WidgetUtils.HitTestInvisible(self.IText_Num)
        self.IText_Num:SetText(nSubValue)
    end
    
    if bItemInfo then
        WidgetUtils.SelfHitTestInvisible(self.BgItem)
        WidgetUtils.Collapsed(self.Bg)
    else
        WidgetUtils.Collapsed(self.BgItem)
        WidgetUtils.SelfHitTestInvisible(self.Bg)
    end
end


return tbClass