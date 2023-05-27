-- ========================================================
-- @File    : uw_arms_up_max.lua
-- @Brief   : 武器升级
-- ========================================================


---@class tbClass
---@field pWeapon UWeaponItem
---@field MaxStar UWrapBox 
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
end

 function tbClass:OnActive(pWeapon)
     self.pWeapon = pWeapon
     if not self.pWeapon then return end

    ---属性显示
    local sNow = UE4.UItemLibrary.GetWeaponAbilityValueToStr(UE4.EWeaponAttributeType.Attack, self.pWeapon)
    ---霰弹枪
    if self.pWeapon:Detail() == 3 then
        local nLaunch = TackleDecimal(tonumber(UE4.UItemLibrary.GetCharacterCardAbilityValueByStr('BulletLaunchCount', self.pWeapon)))
        sNow = TackleDecimal(tonumber(sNow)) * nLaunch
    end
    local damageType = Weapon.GetWeaponGrowConfig(self.pWeapon).nDamageType
    local IconId = Weapon.tbRestraintIcon[damageType]
    self.MainAtt:SetWeaponAttr(IconId, Text('ui.TxtArmAtt1'), sNow)

    local nNow, sSubType =  Weapon.GetSubAttr(self.pWeapon, self.pWeapon:EnhanceLevel(), self.pWeapon:Quality())
    self.SubAtt:SetData(Text(string.format("attribute.%s", sSubType)), Resource.GetAttrPaint(sSubType), nNow)

    sSubType = 'DamageCoefficient'
    nNow = UE4.UItemLibrary.GetCharacterCardAbilityValueByStr(sSubType, self.pWeapon)
    local fCover = function(n) return string.format('%0.1f', n) .. '%' end
    self.BreachAtt:SetData(Text(string.format("attribute.%s", sSubType)), Resource.GetAttrPaint(sSubType), fCover(tonumber(nNow)))

    self.EXP:Set(self.pWeapon, 0)
    SetTexture(self.Logo, self.pWeapon:Icon())

    ---星级显示
    local nStarNum = self.pWeapon:Break()
    local nAllNum = self.Star:GetChildrenCount()
    for i = 0, nAllNum - 1 do
        local pWidget = self.Star:GetChildAt(i)
        if i < nStarNum then
            WidgetUtils.HitTestInvisible(pWidget.ImgStar)
            WidgetUtils.Collapsed(pWidget.ImgStarOff)
        else
            WidgetUtils.Collapsed(pWidget.ImgStar)
            WidgetUtils.HitTestInvisible(pWidget.ImgStarOff)
        end
    end

    self.Partslock:Set(self.pWeapon)
 end

return tbClass