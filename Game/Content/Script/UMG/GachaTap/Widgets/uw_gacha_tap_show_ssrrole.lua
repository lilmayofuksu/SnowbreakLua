-- ========================================================
-- @File    : uw_gacha_tap_show.lua
-- @Brief   : 抽奖结果展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

local utils = require('UMG.GachaTap.Widgets.GachaTapUtils')


local tbColorEffect = {20, 21, 22, 23, 24, 25}

function tbClass:Set(pTemplate)
    if not pTemplate then return end

    self.Extra:SetByGDPL(pTemplate.Genre, pTemplate.Detail, pTemplate.Particular, pTemplate.Level)
    WidgetUtils.Collapsed(self.Extra)

    SetTexture(self.ImgRoleLogo, pTemplate.Icon)
    SetTexture(self.ImgRoleLogo2, pTemplate.Icon)
    SetTexture(self.ImgRoleLogo3, pTemplate.Icon)

    SetTexture(self.RoleRarityLine1, utils.QualityRoleImg[pTemplate.Color])
    SetTexture(self.RoleRarityLine2, utils.QualityRoleImg[pTemplate.Color])

    self.TxtRoleName:SetContent(Text('ui.TxtGachaSingleShow', Text(pTemplate.I18N), Text(pTemplate.I18N .. '_title')))

    local sColorCode = utils.ColorStr[pTemplate.Color]
    if sColorCode then
        Color.SetColorFromHex(self.ImgRoleLogo2, sColorCode)
    end

    self.nStarNum = pTemplate.Color

    WidgetUtils.Collapsed(self.LogoEffect)

    WidgetUtils.Collapsed(self.RoleInfo)
    WidgetUtils.Collapsed(self.PanelRole3D)

        
    PlayEffect(self.RoleRarity1, tbColorEffect[pTemplate.Color])
    PlayEffect(self.RoleRarity2, tbColorEffect[pTemplate.Color])

    utils.SetImgColor(self, pTemplate.Color)
end

function tbClass:RoleLogo()
    if self.LogoEffect then
        WidgetUtils.HitTestInvisible(self.LogoEffect)
        self.LogoEffect:ActivateSystem(true)
    end
end

function tbClass:OnShowRole()
    UI.Call2('GachaTap', 'PlaySSR')
end


function tbClass:PlayInfo(fCallback)
    WidgetUtils.HitTestInvisible(self.RoleInfo)
    WidgetUtils.HitTestInvisible(self.Extra)
    utils.PlayAnim(self, self.InfoSSR, fCallback)
    utils.PlayStarAnim(self, self.ListRoleStar, self.nStarNum or 0)
end


function tbClass:PlayShow(fCallback)
    WidgetUtils.HitTestInvisible(self.PanelRole3D)
    utils.PlayAnim(self, self.Role, fCallback)
end

function tbClass:PlayClose(fCallback)
    WidgetUtils.HitTestInvisible(self.RoleInfo)
    WidgetUtils.HitTestInvisible(self.PanelRole3D)
    utils.PlayAnim(self, self.RoleClose, fCallback)
end


return tbClass