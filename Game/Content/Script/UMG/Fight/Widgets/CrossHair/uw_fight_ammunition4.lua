-- ========================================================
-- @File    : uw_fight_ammunition4.lua
-- @Brief   : 弹药控制
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_ammunition4 = Class("UMG.SubWidget")

local Widget = uw_fight_ammunition4

function Widget:Construct()
    self.tbBullets = {}
    table.insert(self.tbBullets, self.ImgBullet1)
    table.insert(self.tbBullets, self.ImgBullet2)
    table.insert(self.tbBullets, self.ImgBullet3)
    table.insert(self.tbBullets, self.ImgBullet4)
    table.insert(self.tbBullets, self.ImgBullet5)
    table.insert(self.tbBullets, self.ImgBullet6)
    table.insert(self.tbBullets, self.ImgBullet7)
    table.insert(self.tbBullets, self.ImgBullet8)
    table.insert(self.tbBullets, self.ImgBullet9)
    table.insert(self.tbBullets, self.ImgBullet10)
    table.insert(self.tbBullets, self.ImgBullet11)
    table.insert(self.tbBullets, self.ImgBullet12)
end

function Widget:OnDestruct()
    self.tbBullets = {}
end

function Widget:Tick(MyGeometry, InDeltaTime)
    local Pawn = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    if Pawn then
        local Weapon = Pawn:GetWeapon()
        if Weapon and Weapon.AccessoryAbility then
            
            local curBullet = Weapon.AccessoryAbility:GetRolePropertieValue(UE4.EAttributeType.Bullet)
            local maxBulet = Weapon.AccessoryAbility:GetRolePropertieMaxValue(UE4.EAttributeType.Bullet)
            for _i, imgBullet in ipairs(self.tbBullets) do
                if _i <= maxBulet then
                    if _i <= curBullet then
                        WidgetUtils.SelfHitTestInvisible(imgBullet)
                    else
                        WidgetUtils.Hidden(imgBullet)
                    end
                else
                    WidgetUtils.Collapsed(imgBullet)
                end
            end
        end
    end
end



return uw_fight_ammunition4
