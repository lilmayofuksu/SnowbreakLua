-- ========================================================
-- @File    : uw_widgets_weapon_atktype.lua
-- @Brief   : 武器克制属性
-- @Author  :
-- @Date    :
-- ========================================================

local tbWeaponRestraint = Class("UMG.SubWidget")

function tbWeaponRestraint:SetData(InSkillID)
    if not InSkillID then
        return
    end
    local IconId = Weapon.tbRestraintIcon[InSkillID]
    if IconId and IconId > 0 then
        SetTexture(self.Icon, IconId, true)
    end
end

return tbWeaponRestraint