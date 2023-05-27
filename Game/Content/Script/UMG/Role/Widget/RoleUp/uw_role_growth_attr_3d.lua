-- ========================================================
-- @File    : uw_role_growth_attr_3d.lua
-- @Brief   : 养成界面
-- ========================================================

local tbRoleAtts = Class("UMG.BaseWidget")

tbRoleAtts.AttrPath = "UMG/Role/Widget/uw_role_attribute_data"
tbRoleAtts.tbItemDes = {
    UE4.EAttributeType.Health,
    UE4.EAttributeType.Attack,
    UE4.EAttributeType.Defence,
    UE4.EAttributeType.SkillMastery,
}

function tbRoleAtts:Construct()
    BtnAddEvent(self.DetailClick, function()
        if self.ClickCall then
            self.ClickCall()
        end
    end)
end

function tbRoleAtts:ShowActived(InCard)
    local bUnlock, tbTip = FunctionRouter.IsOpenById(FunctionType.RoleBreak)
    if not bUnlock then
        self.RoleStar:ShowActiveImg(0)
        self.TextBreak:SetText(Text(tbTip[1] or ''))
    else
        local nBreak = RBreak.GetProcess(InCard)
        self.RoleStar:ShowActiveImg(nBreak)
        self.TextBreak:SetText(Text("ui.TxtRoleBreakRank", nBreak))
    end
end

--- 角色名描述
function tbRoleAtts:ShowRoleName(InCard)
    self.TxtName:SetText(Text(InCard:I18N()))
    self.TxtTitle:SetText(Text(InCard:I18N()..'_title'))
end

--- 属性列表
function tbRoleAtts:LvAttrItem(InItem)
    local AttrItem = Model.Use(self,self.AttrPath)
    self.ListAtt:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden);
    self:DoClearListItems(self.ListAtt)
    for index, value in pairs(self.tbItemDes) do
        local sCate = UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", value)
        local function ShowUnit(Index)
            if Index == 6 then
                return TackleDecimal(self:InitRoleData(InItem,sCate))
            else
                return TackleDecimal(self:InitRoleData(InItem,sCate))
            end
        end
        local tbParam = {
            Cate = sCate, --self:InitRoleCate(Cate),
            ECate = sCate,
            Data = self:InitRoleData(InItem, sCate), --ShowUnit(index),
            ShowBG = index % 2 ~= 0
        }
        if value == UE4.EAttributeType.CriticalDamageAddtion then
            tbParam.Data = TackleDecimalUnit(tonumber(tbParam.Data), "%", "1")
        end
        local NewAttrInfo = AttrItem:Create(tbParam)  -- NewObject(AttrItem, self, nil)
        self.ListAtt:AddItem(NewAttrInfo)
    end
end


function tbRoleAtts:InitRoleData(InCard,sCate)
    -- local strRoleAttr, strWeaponAttr, strLogisticAttr , strTotal = UE4.UItemLibrary.GetSingleTotalValueToStr(sCate,InCard)
    -- local data = strTotal --TackleDecimal(fRoleAttr + fWeaponAttr + fLogisticAttr)
    return UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_" .. sCate, InCard)
end

--角色战力展示界面数据
function tbRoleAtts:Updatecarddate(InCard)
    if not InCard then return end
    self:SetSingleText(self.TexBatPower, TackleDecimal(Item.Zhanli_CardTotal(InCard)))
end

function tbRoleAtts:SetSingleText(InText, InValue)
    InText:SetText(InValue)
end

function tbRoleAtts:DetailClickCall(InCallBack)
    self.ClickCall = InCallBack
end

function tbRoleAtts:OnDisable()
end
return tbRoleAtts