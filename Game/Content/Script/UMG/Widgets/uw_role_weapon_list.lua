-- ========================================================
-- @File    : uw_role_weapon_list.lua
-- @Brief   : 武器技能和属性描述
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListAtt_1)
    self.AttrListFactory = Model.Use(self, 'UMG/Role/Widget/uw_role_attribute_data')
    BtnAddEvent(self.BtnStory, function()
        if self.FunClick then
            self.FunClick()
        end
    end)
end

function tbClass:ShowSkillPanel(InWeapon)
    local cfg = Weapon.GetWeaponConfig(InWeapon)
    local tbSkillID = cfg and cfg.DefaultSkillID or nil
    if tbSkillID then
        local nSkillID = tbSkillID[1]
        local nLevel = InWeapon:Evolue() + 1
        self.TextLv:SetText(nLevel)
        self.TxtSkillName:SetText(Localization.GetSkillName(nSkillID))
        self.TxtIntro:SetContent(SkillDesc(nSkillID, nil, nLevel))
    end

    ---副属性
    local nNow, sSubType = Weapon.GetSubAttr(InWeapon, InWeapon:EnhanceLevel(), InWeapon:Quality())
    self.SubAttribute:Display({sType = sSubType, Attr = nNow})
end

function tbClass:ShowAttributePanel(IntbAttr, InWeapon)
    self.ListAtt_1:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.ListAtt_1)
    for _, nType in ipairs(IntbAttr) do
        local Cate = UE4.UUMGLibrary.GetEnumValueAsString("EWeaponAttributeType", nType)
        local tbParam = {
            Cate = Cate,
            ECate = Cate,
            Data = Weapon.ConvertDes(nType, UE4.UItemLibrary.GetWeaponAbilityValueToStr(nType, InWeapon)),
            ShowBG = false
        }
        local pObj = self.AttrListFactory:Create(tbParam)
        self.ListAtt_1:AddItem(pObj)
    end
end

function tbClass:SetSelect(nType)
    if nType == 1 then
        WidgetUtils.SelfHitTestInvisible(self.PanelInfo)
        WidgetUtils.Collapsed(self.PanelAtt)
        self.TxtName:SetText(Text("ui.TxtWeaponListTitle1"))
    else
        WidgetUtils.Collapsed(self.PanelInfo)
        WidgetUtils.SelfHitTestInvisible(self.PanelAtt)
        self.TxtName:SetText(Text("ui.TxtWeaponListTitle2"))
    end
end

function tbClass:SetClickEvent(fun)
    self.FunClick = fun
end

return tbClass
