-- ========================================================
-- @File    : uw_new_role_info.lua
-- @Brief   : 信息展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.ListAtt:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end


function tbClass:Set(pCard)
    if not pCard then return end
   
    self.ListAtt:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)

    self.tbMainAttr = self.tbMainAttr or {}

    self.AttrListFactory =  self.AttrListFactory or Model.Use(self, 'UMG/Role/Widget/uw_role_attribute_data')

    local pWeapon = pCard:GetSlotWeapon()
    self:ShowDetails(pWeapon)
    Preview.PreviewByCardAndWeapon(pCard:Id(), pWeapon:Id(), PreviewType.role_weapon)
end

---UI数据刷新
function tbClass:ShowDetails(pWeapon)
    if not pWeapon then return end


    self.TextCurrLv:SetText(pWeapon:EnhanceLevel())
    self.TextMax:SetText(Item.GetMaxLevel(pWeapon))
    self.Arms_NAME:SetText(Text(pWeapon:I18N()))

    SetTexture(self.ImgIcon, pWeapon:Icon(), true)
    SetTexture(self.ImgArmsType, Weapon.GetTypeIcon(pWeapon))
    SetTexture(self.ImgQuality, Weapon.GetQualityIcon(pWeapon:Color()))

    self:ShowStar(pWeapon:Quality())
    --技能显示
    self.Skill:Set(pWeapon)

    ---属性显示
    self:DoClearListItems(self.ListAtt)
    for _, nType in ipairs(self.tbMainAttr) do
        local Cate = UE4.UUMGLibrary.GetEnumValueAsString("EWeaponAttributeType", nType)
        local tbParam = {
            Cate = Text("attribute." .. Cate),
            ECate = Cate,
            Data = Weapon.ConvertDes(nType, UE4.UItemLibrary.GetWeaponAbilityValueToStr(nType, pWeapon))
        }
        local pObj = self.AttrListFactory:Create(tbParam)
        self.ListAtt:AddItem(pObj)
    end

    ---配件信息

    Weapon.ShowPartInfo(pWeapon, self)
end

---显示星级
---@param nStar number 数量
function tbClass:ShowStar(nStar)
    for i = 1, 5 do
        local pw = self["s_" .. i]
        if pw then
            if i <= nStar then
                WidgetUtils.SelfHitTestInvisible(pw.ImgStar)
                WidgetUtils.Collapsed(pw.ImgStarOff)
            else
                WidgetUtils.Collapsed(pw.ImgStar)
                WidgetUtils.SelfHitTestInvisible(pw.ImgStarOff)
            end
        end
    end
end


return tbClass