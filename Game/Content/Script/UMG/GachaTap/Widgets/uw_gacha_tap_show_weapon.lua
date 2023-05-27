-- ========================================================
-- @File    : uw_gacha_tap_show.lua
-- @Brief   : 抽奖结果展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")


local utils = require('UMG.GachaTap.Widgets.GachaTapUtils')


local tbColorEffect = {20, 21, 22, 23, 24, 25}

function tbClass:Set(pTemplate)
    if not pTemplate then return end

    self.pTemplate = pTemplate

    SetTexture(self.ImgWeaponLogo, pTemplate.Icon)
    SetTexture(self.ImgWeaponLogo2, pTemplate.Icon)
    SetTexture(self.ImgWeaponLogo3, pTemplate.Icon)
    SetTexture(self.WeaponRarityLine, utils.QualityWeaponImg[pTemplate.Color])

    local sColorCode = utils.ColorStr[pTemplate.Color]

    if sColorCode then
        Color.SetColorFromHex(self.ImgWeaponLogo2, sColorCode)
    end

    self.Extra:SetByGDPL(pTemplate.Genre, pTemplate.Detail, pTemplate.Particular, pTemplate.Level)
    WidgetUtils.Collapsed(self.Extra)

    self.TxtWeaponName:SetText(Text(pTemplate.I18N))
    WidgetUtils.Collapsed(self.LogoEffect_1)
    if pTemplate.Color == 5 then
        self.bPlayLogEffect = true
    else
        self.bPlayLogEffect = false
    end
    self.nStarNum = pTemplate.Color
    PlayEffect(self.WeaponRarity, tbColorEffect[pTemplate.Color])
    
    WidgetUtils.Collapsed(self.WenponInfo)
    WidgetUtils.Collapsed(self.PanelWeapon3D)

    utils.SetImgColor(self, pTemplate.Color)
end

function tbClass:WeaponLogo()
    if not self.bPlayLogEffect then return end
    if self.LogoEffect_1 then
        WidgetUtils.HitTestInvisible(self.LogoEffect_1)
        self.LogoEffect_1:ActivateSystem(true)
    end
end

function tbClass:OnShowWeapon()
    UI.Call2('GachaTap', 'PlayWeapon')
end


function tbClass:PlayInfo(fCallback)
    WidgetUtils.HitTestInvisible(self.WenponInfo)
    WidgetUtils.HitTestInvisible(self.Extra)
    utils.PlayAnim(self, self.WenponInfoAni, fCallback)
    utils.PlayStarAnim(self, self.ListWeaponStar, self.nStarNum or 0)
end


function tbClass:PlayShow(fCallback)
    WidgetUtils.HitTestInvisible(self.PanelWeapon3D)
    utils.PlayAnim(self, self.Weapon, fCallback)
end

function tbClass:PlayClose(fCallback)
    WidgetUtils.HitTestInvisible(self.WenponInfo)
    WidgetUtils.HitTestInvisible(self.PanelWeapon3D)
    utils.PlayAnim(self, self.WeaponClose, fCallback)
end


local tbSounds = {0, 0, 3028, 3027, 3026}

function tbClass:ExpandSound()
    if self.pTemplate then
        Audio.PlaySounds(tbSounds[self.pTemplate.Color])
    end
end


return tbClass