-- ========================================================
-- @File    : uw_fight_ammunition2.lua
-- @Brief   : 弹药控制
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_ammunition2 = Class("UMG.SubWidget")

local Widget = uw_fight_ammunition2

Widget.nValue = 0

function Widget:Tick(MyGeometry, InDeltaTime)
    local Pawn = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    if Pawn then
        local Weapon = Pawn:GetWeapon()
        if Weapon and Weapon.AccessoryAbility then
            local curBullet = Weapon.AccessoryAbility:GetRolePropertieValue(UE4.EAttributeType.Bullet)  
            if self.nValue ~= curBullet then
                self.nValue = curBullet
                self.BulletTex:SetText(math.floor(curBullet))
            end
        end
    end
end

return uw_fight_ammunition2
