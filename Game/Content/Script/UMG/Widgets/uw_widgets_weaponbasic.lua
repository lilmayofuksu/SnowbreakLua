-- ========================================================
-- @File    : uw_widgets_weaponbasic.lua
-- @Brief   : 武器信息
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.BtnIntro:InitHelpImages(17)
end

---@param pWeapon UWeaponItem
function tbClass:UpdatePanel(InWeapon, nForm)
    if nForm then
        WidgetUtils.Collapsed(self.PanelTestPart)
    else
        WidgetUtils.Visible(self.PanelTestPart)
    end

    ---武器名
    self.Arms_NAME:SetText(Text(InWeapon:I18N()))
    --- 武器类型描述
    self.ArmType:SetText(Weapon.GetTypeName(InWeapon))
    --- 武器品质
    self.Star:OnOpen({nStar = InWeapon:Break(), nLv = InWeapon:EnhanceLevel()})
    --- 武器等级
    self.TxtNum:SetText(InWeapon:EnhanceLevel())
    --- 武器类型
    SetTexture(self.ImgArmsType, Weapon.GetTypeIcon(InWeapon))
    --- 武器品质
    SetTexture(self.ImgQuality, Item.RoleColorWeapon[InWeapon:Color()])
    ---配件信息
    Weapon.ShowPartInfo(InWeapon, self)

    self.Quality:Set(InWeapon:Color())
    self:PlayAnimation(self.AllEnter)

    ---设置克制标记
    self:UpdateDamageType(InWeapon)
end

---设置克制标记
function tbClass:UpdateDamageType(InWeapon)
    local cfg = Weapon.GetWeaponGrowConfig(InWeapon)
    if cfg then
        self.DamageType:SetData(cfg.nDamageType)
        self.ArmType2:SetText(Text("ui.TxtDamageType." .. cfg.nDamageType))
    end
end

return tbClass

