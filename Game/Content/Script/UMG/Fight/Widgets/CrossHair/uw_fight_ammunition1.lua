-- ========================================================
-- @File    : uw_fight_ammunition1.lua
-- @Brief   : 弹药控制
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_ammunition1 = Class("UMG.SubWidget")

local Widget = uw_fight_ammunition1
Widget.nValue = 0

function Widget:Tick(MyGeometry, InDeltaTime)
    local Pawn = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    if Pawn then
        local Weapon = Pawn:GetWeapon()
        if Weapon and Weapon.AccessoryAbility then
            local curBullet = Weapon.AccessoryAbility:GetRolePropertieValue(UE4.EAttributeType.Bullet)
            local maxBulet = Weapon.AccessoryAbility:GetRolePropertieMaxValue(UE4.EAttributeType.Bullet)
            local pre = maxBulet > 0 and curBullet/maxBulet or 0
            if self.nValue ~= pre then
                self.nValue = pre
                self.Bullet:SetPercent(pre)
            end
        end
    end
end

return uw_fight_ammunition1
