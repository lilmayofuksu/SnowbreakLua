
-- ========================================================
-- @File    : uw_arms_outer_att.lua
-- @Brief   : 武器属性3D界面
-- ========================================================

local tbArmsAtt = Class("UMG.SubWidget")

function tbArmsAtt:Construct()
end

function tbArmsAtt:OnOpen()
end

---UI数据刷新
function tbArmsAtt:ShowDetails(InCard,pWeapon,IntbAttr)
    self.AttrListFactory = Model.Use(self, 'UMG/Role/Widget/uw_role_attribute_data')
    if not pWeapon then return end

    ---判断当前培养武器是不是角色装配的武器
    local pSlotWeapon = InCard:GetSlotWeapon()

    -- self.SkillLv:SetText('PlayerLevel')
    -- self.TxtNum:SetText(pWeapon:Evolue() + 1)
    -- self.TxtSkillName:SetText('TxtSkillName')
    -- self.TxtSkillInfo:SetContent(100092)
    -- self.Skill:Set(pWeapon)

    SetTexture(self.ImgIcon, pWeapon:Icon(), true)
    --技能显示
    -- self.Skill:Set(pWeapon)
    --- 属性描述
    -- self.ArmsActor.GetAttWidget:ShowAttrDes(IntbAttr,pWeapon)
    self:ShowAttrDes(IntbAttr,pWeapon)

    local RetraintIconId = Weapon.GetWeaponGrowConfig(pWeapon).nDamageType
    self.Atktype:SetData(pWeapon)
    self.specs:SetData(pWeapon)
end


function tbArmsAtt:ShowAttrDes(IntbAttr,InWeapon)
    --- 武器名
    self.Arms_NAME:SetText(Text(InWeapon:I18N()))
     ---属性显示
    self:ShowAttrItem(IntbAttr,InWeapon)
      --- 武器品质
    self.Star:OnOpen({nStar = InWeapon:Quality(),nLv = InWeapon:EnhanceLevel()})

    --- 武器类型描述
    self.ArmType:SetText(Weapon.GetTypeName(InWeapon))

    --- 武器类型
    SetTexture(self.ImgArmsType, Weapon.GetTypeIcon(InWeapon))
    --- 武器品质
    SetTexture(self.ImgQuality, Weapon.GetQualityIcon(InWeapon:Color()))
     ---配件信息
    Weapon.ShowPartInfo(InWeapon, self)

end

--- 武器属性列表
function tbArmsAtt:ShowAttrItem(IntbAttr,InWeapon)
    self:DoClearListItems(self.ListAtt)
    for _, nType in ipairs(IntbAttr) do
        local Cate = UE4.UUMGLibrary.GetEnumValueAsString("EWeaponAttributeType", nType)
        local tbParam = {
            Cate = Cate, --Text("attribute." .. Cate),
            ECate = Cate,
            Data = Weapon.ConvertDes(nType, UE4.UItemLibrary.GetWeaponAbilityValueToStr(nType, InWeapon))
        }
        local pObj = self.AttrListFactory:Create(tbParam)
        self.ListAtt:AddItem(pObj)
    end
end

return tbArmsAtt