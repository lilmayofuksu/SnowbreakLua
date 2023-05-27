
-- ========================================================
-- @File    : uw_widgets_weapon_skillinfo_new.lua
-- @Brief   : 武器信息界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListAtt)
    self.AttrListFactory = Model.Use(self, 'UMG/Role/Widget/uw_role_attribute_data')
end

function tbClass:UpdateSkillPanel(pWeapon)
    local tbSkillID = Weapon.GetWeaponConfig(pWeapon).DefaultSkillID
    if tbSkillID then
        local nSkillID = tbSkillID[1]
        local nLevel = pWeapon:Evolue() + 1
        --self.TextLv:SetText(nLevel)
        self.TxtSkillName:SetText(Localization.GetSkillName(nSkillID))
        self.TxtSkillInfo:SetContent(SkillDesc(nSkillID, nil, nLevel))
    end

    self.Atktype:SetData(pWeapon)
end

--- 武器属性列表
function tbClass:ShowAttrItem(IntbAttr, InWeapon)
    self:DoClearListItems(self.ListAtt)
    for i, nType in ipairs(IntbAttr) do
        local Cate = UE4.UUMGLibrary.GetEnumValueAsString("EWeaponAttributeType", nType)
        local tbParam = {
            Cate = Cate, --Text("attribute." .. Cate),
            ECate = Cate,
            Data = Weapon.ConvertDes(nType, UE4.UItemLibrary.GetWeaponAbilityValueToStr(nType, InWeapon)),
            ShowBG = i%2~=0
        }
        local pObj = self.AttrListFactory:Create(tbParam)
        self.ListAtt:AddItem(pObj)
    end
end

return tbClass
