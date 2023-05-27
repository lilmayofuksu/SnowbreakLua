-- ========================================================
-- @File    : uw_widgets_attribute07.lua
-- @Brief   : 属性说明文本7号样式
-- ========================================================

local tbClass = Class("UMG.SubWidget")

---@param pWeapon UWeaponItem
function tbClass:SetData(pWeapon)
    if not Weapon.GetWeaponGrowConfig(pWeapon) then return end
    ---设置克制标记
    local damageType = Weapon.GetWeaponGrowConfig(pWeapon).nDamageType
    self.DamageType:SetData(damageType)
    self.DesTxt:SetText(Text("ui.TxtDamageType." .. damageType))
    ---设置主属性
    self.ArmAtk:SetData(pWeapon)
end

---显示成副属性
function tbClass:ShowSubAttr(pWeapon)
    local nNow, sSubType = Weapon.GetSubAttr(pWeapon, pWeapon:EnhanceLevel(), pWeapon:Quality())
    local sCate = Text(string.format('attribute.%s', sSubType))
    self.DesTxt:SetText(sCate)
    if sSubType == 'Defence' then
        self.IText_Num:SetText(TackleDecimalUnit(nNow))
    elseif sSubType == "CriticalDamage" or sSubType == "CriticalValue" then
        local sTxt = TackleDecimalUnit(nNow,'%')
        local sReal = UE4.UKismetStringLibrary.Replace(sTxt, '%%', '%')
        self.IText_Num:SetText(sReal)
    else
        self.IText_Num:SetText(nNow)
    end
    local sPath = Resource.GetAttrPaint(sSubType)
    SetTexture(self.ImgAttIcon, sPath)
end

return tbClass
