-- ========================================================
-- @File    : uw_widgets_attribute10.lua
-- @Brief   : 属性说明文本7号样式
-- ========================================================

local tbClass = Class("UMG.SubWidget")

---@param pWeapon UWeaponItem
function tbClass:SetData(pWeapon, bItemInfo)
    ---设置克制标记
    if not pWeapon or not Weapon.GetWeaponGrowConfig(pWeapon) then
        return
    end
    local damageType = Weapon.GetWeaponGrowConfig(pWeapon).nDamageType
    self.DamageType:SetData(damageType)
    self.DesTxt:SetText(Text("ui.TxtDamageType." .. damageType))
    ---设置主属性
    self.ArmAtk:SetData(pWeapon, bItemInfo)
end

return tbClass

