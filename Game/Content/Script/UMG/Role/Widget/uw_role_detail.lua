-- ========================================================
-- @File    : uw_role_detail_tips.lua
-- @Brief   : 角色详情
-- @Author  :
-- @Date    :
-- ========================================================

local tbDetail = Class("UMG.BaseWidget")
tbDetail.AttrPath = "UMG/Role/Widget/uw_role_detail_tips_item_data"
tbDetail.tbDemage = {}

function tbDetail:OnInit()
    self:DoClearListItems(self.ListBaseAtt)
    self:DoClearListItems(self.ListSpeAtt)
    self:DoClearListItems(self.ListAmrsAtt)
    self:DoClearListItems(self.ListMask1)
    self:DoClearListItems(self.ListMask2)
    self:DoClearListItems(self.ListMask3)

    BtnAddEvent(self.BtnClose, function()
        UI.Close(self)
    end)

    self.ArrtItem = Model.Use(self, self.AttrPath)
    self.tbCateArrt = {self.RoleAttr, self.WeaponAttr, self.LogisticAttr, self.TotalAttr}

    self.tbValidAtts = {
        UE4.EAttributeType.Health,
        UE4.EAttributeType.Attack,
        UE4.EAttributeType.Defence,
    }

    self:DoClearListItems(self.RightList)
    self.ListFactory = Model.Use(self)
end

--- 界面入口
---@param InCard Template
---@param CurCard UE4.UCharacterCard 角色卡
function tbDetail:OnOpen(InCard, CurCard)
    if CurCard then
        self.pCard = CurCard
    elseif InCard then
        self.pCard = RoleCard.GetItem({InCard.Genre, InCard.Detail, InCard.Particular, InCard.Level})
    end
    if not self.pCard then return end
    self.nType = self.nType or 1

    self.TxtName:SetText(Text(self.pCard:I18N()))
    self.TxtDesc:SetText(Text(self.pCard:I18N()..'_des'))
    self:ShowImgRole(self.pCard)
    self:ChangePanel(self.nType)

    self.Quality:Set(self.pCard:Color())

    self:DoClearListItems(self.RightList)
    for i = 1, 2 do
        local tbParam = {"ui.TxtRoledetail.tab"..i, self.nType == i, function(selectTab) self:ChangeTab(i, selectTab) end}
        local obj = self.ListFactory:Create(tbParam)
        self.RightList:AddItem(obj)
    end
end

function tbDetail:ChangeTab(nType, selectTab)
    if self.SelectTab then
        WidgetUtils.Collapsed(self.SelectTab.Group_on)
        WidgetUtils.SelfHitTestInvisible(self.SelectTab.Group_off)
    end
    if selectTab then
        WidgetUtils.SelfHitTestInvisible(selectTab.Group_on)
        WidgetUtils.Collapsed(selectTab.Group_off)
        self.SelectTab = selectTab
    end
    self.nType = nType
    self:ChangePanel(nType)
end

---切换面板
---@param type integer 1:详情 2:推荐装备
function tbDetail:ChangePanel(type)
    if type == 1 then
        self:ShowDetail(self.pCard)
        self:ShowSpecAttr(self.pCard)
        self:ShowWeapAttr(self.pCard)
        WidgetUtils.Collapsed(self.Selected2)
        WidgetUtils.HitTestInvisible(self.Selected1)
        WidgetUtils.Collapsed(self.PanelEquip)
        WidgetUtils.SelfHitTestInvisible(self.PanelDetail)
    elseif type == 2 then
        self:UpdatePanelEquip()
        WidgetUtils.Collapsed(self.Selected1)
        WidgetUtils.HitTestInvisible(self.Selected2)
        WidgetUtils.Collapsed(self.PanelDetail)
        WidgetUtils.SelfHitTestInvisible(self.PanelEquip)
    end
end

function tbDetail:UpdatePanelEquip()
    local info = RoleCard:GetRoleRecommendData(self.pCard:Genre(), self.pCard:Detail(), self.pCard:Particular(), self.pCard:Level())
    if not info then return end
    if info.Weapon1 and #info.Weapon1 >= 4 then
        self.WeaponItem:Display({G = info.Weapon1[1], D = info.Weapon1[2], P = info.Weapon1[3], L = info.Weapon1[4]})
    end
    if info.Weapon2 and #info.Weapon2 >= 4 then
        self.WeaponItem2:Display({G = info.Weapon2[1], D = info.Weapon2[2], P = info.Weapon2[3], L = info.Weapon2[4]})
    end
    for i = 1, 3 do
        if info.Logistics1[i] and #info.Logistics1[i] >= 4 then
            self["SuppotItem"..i]:Display({G = info.Logistics1[i][1], D = info.Logistics1[i][2], P = info.Logistics1[i][3], L = info.Logistics1[i][4]})
        end
        if info.Logistics2[i] and #info.Logistics2[i] >= 4 then
            self["SuppotItem2_"..i]:Display({G = info.Logistics2[i][1], D = info.Logistics2[i][2], P = info.Logistics2[i][3], L = info.Logistics2[i][4]})
        end
    end
end

--- 属性列表
function tbDetail:ShowDetail(InItem)
    if not InItem then
        return
    end
    self:DoClearListItems(self.ListBaseAtt)
    for index, value in ipairs(self.tbValidAtts) do
        local Type = UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", value)
        local fBase = 0
        local fScale = 0
        local fTotal = 0
        if index==1 then
            fTotal, fBase, fScale = InItem:Ability_Health()
        elseif index==2 then
            fTotal, fBase, fScale = InItem:Ability_Attack()
        elseif index==3 then
            fTotal, fBase, fScale = InItem:Ability_Defence()
        end
        local tbParam = {
            sUIType = "RoleDetail",
            sName = Text("attribute." .. tostring(Type)),
            fBase = fBase,
            fScale = fScale,
            fTotal = fTotal,
            ECate = Type
        }

        local NewAttr = self.ArrtItem:Create(tbParam)
        self.ListBaseAtt:AddItem(NewAttr)
    end
end

function tbDetail:OnTitle()
    --- 角色
    self.character:SetText(Text("character"))
    --- 武器
    self.weapon:SetText(Text("weapon"))
    --- 后勤
    self.supporter:SetText(Text("supporter"))
    --- 总计
    self.TxtAllAtt:SetText(Text('total'))
    --- 基础属性
    self.TxtBaseAtt:SetText(Text('TxtBaseAtt'))
    --- 特殊属性
    self.TxtSpeAtt_1:SetText(Text('TxtSpeAtt'))
    --- 枪械属性
    self.TxtArmsAtt_2:SetText(Text('TxtArmsAtt'))
end

--- 特殊属性
function tbDetail:ShowSpecAttr(InItem)
    local function GetEnergyEfficiency()
        local v = InItem:Total_CharacterEnergyEfficiency(InItem:EnhanceLevel(),InItem:Color())
        if v > 0 then
            return TackleDecimalUnit(v + 100, "%", 1)
        else
            return '100%'
        end
    end

    local tbSpecialAttr = {
        UE4.EAttributeType.CriticalValue,
        UE4.EAttributeType.CriticalDamageAddtion,
        101,                                                    -- 爆发能量获取率
        UE4.EAttributeType.Vigour,                              -- 耐力
        UE4.EAttributeType.EntityBulletResistance,              -- 动能抗性
        UE4.EAttributeType.FireResistance,                      -- 高热抗性
        UE4.EAttributeType.IceResistance,                       -- 低温抗性
        UE4.EAttributeType.ThunderResistance,                   -- 电击抗性
        UE4.EAttributeType.SuperpowersResistance,               -- 特异抗性
        UE4.EAttributeType.SkillCDQuick,                        -- 主动技能急速
        UE4.EAttributeType.NormalEnergyRecoverSpeed,            -- 常规能量回复速率
        UE4.EAttributeType.Command,                             -- 指挥值
        UE4.EAttributeType.SkillMastery,                        -- 技能精通
    }

    self:DoClearListItems(self.ListSpeAtt)
    for i, value in pairs(tbSpecialAttr) do
        local Cate = UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", value)
        local tbParam = {
            sName = "attribute." .. Cate,
            ECate = Cate,
            fRoleAttr = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_" .. Cate, InItem)
        }
        if value == 101 then
            tbParam.sName = "attribute.characterenergyefficiency"
            tbParam.ECate = 'CharacterEnergyEfficiency'
            tbParam.fRoleAttr = GetEnergyEfficiency()
        end
        if (i >= 1 and i <= 2) or (i >= 5 and i <= 9) or i == 12 then
            tbParam.fRoleAttr = TackleDecimalUnit(tbParam.fRoleAttr, "%")
        end
        local NewAttr = self.ArrtItem:Create(tbParam)
        self.ListSpeAtt:AddItem(NewAttr)
    end
end

--- 武器属性
function tbDetail:ShowWeapAttr(InItem)
    local pWeapon = InItem:GetSlotWeapon()
    local lv = pWeapon:EnhanceLevel()
    local color = pWeapon:Color()
    local function DemageType()
        return Text('ui.DamageType.'..pWeapon:DamageType(lv,color))
    end
    local tbWeaponAttr = {
        UE4.EWeaponAttributeType.DamageCoefficient,
        UE4.EWeaponAttributeType.FireSpeed,
        100,
        101,
        --UE4.EWeaponAttributeType.DamageType,
        UE4.EWeaponAttributeType.BulletNum,
        -- UE4.EWeaponAttributeType.BulletCost,
        UE4.EWeaponAttributeType.ReloadSpeed,
        UE4.EWeaponAttributeType.CriticalDamage,
        -- UE4.EWeaponAttributeType.WeaknessDamage,                    --- 弱伤加成
        -- UE4.EWeaponAttributeType.AdditionalCritPercentInAimState, 
    }

    local tbUnit = {
        -- UE4.EWeaponAttributeType.WeaknessDamage, 
        UE4.EWeaponAttributeType.DamageCoefficient,
        UE4.EWeaponAttributeType.AdditionalCritDamageInAimState,
        UE4.EWeaponAttributeType.AdditionalCritPercentInAimState, 
        }
    local function Unit(i)
        for index, value in ipairs(tbUnit) do
            if value == i then
                return '%'
            end
        end
        return ''
    end

    local function Decimnal(InVal)
        local a , b = math.modf(InVal)
        if b<=0 then
            return '%d'
        end
        return '%.1f'
    end

    self:DoClearListItems(self.ListAmrsAtt)
    for _, nType in ipairs(tbWeaponAttr) do
        local Cate = UE4.UUMGLibrary.GetEnumValueAsString("EWeaponAttributeType", nType)
        local nValue = UE4.UItemLibrary.GetWeaponAbilityValue(nType, pWeapon)
        local tbParam = {
            sName = "attribute." .. Cate,
            ECate = Cate,
            fRoleAttr = string.format(Decimnal(nValue),nValue)..Unit(nType)
        }
        if nType == 100 then
            tbParam.sName = "attribute.DamageType"
            tbParam.ECate = 'DamageType'
            tbParam.fRoleAttr = DemageType()
        elseif nType == 101 then
            tbParam.sName = "attribute.FiringRangeUltimateLimit"
            tbParam.ECate = 'FiringRangeUltimateLimit'
            tbParam.fRoleAttr = TackleDecimal(pWeapon:FiringRangeUltimateLimit(lv,color)/100)..Text('ui.TxtDisUnit')
        elseif nType == UE4.EWeaponAttributeType.CriticalDamage then
            tbParam.fRoleAttr = TackleDecimalUnit(tbParam.fRoleAttr, "%")
        end
        local NewAttr = self.ArrtItem:Create(tbParam)
        self.ListAmrsAtt:AddItem(NewAttr)
    end
end

--- 角描述
function tbDetail:ShowContentDes(InCard)
    local sDes = InCard:I18N()..'_title'
    self.TxtIntro:SetText(Text(sDes))
end

--- 裁剪立绘，克制属性
function tbDetail:ShowImgRole(InCard)
    self:ShowContentDes(InCard)
    local Mat = self.ImgRole:GetDynamicMaterial()
    if Mat then
        Mat:SetTextureParameterValue("Image", GetTexture(self.ImgRole, InCard:Icon()))
    end

    -- local CharacterTemplateId = InCard:TemplateId()
    -- local nTriangleAttribute = UE4.UItemLibrary.GetCharacterAtrributeTemplate(CharacterTemplateId).TriangleType
    -- SetTexture(self.ImgRestraint, Item.RoleTrangleAttr[nTriangleAttribute+1])
end
return tbDetail
