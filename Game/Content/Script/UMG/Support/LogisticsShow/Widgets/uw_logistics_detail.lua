-- ========================================================
-- @File    : uw_logistics_detail.lua
-- @Brief   : 角色后勤属性列表
-- @Author  :
-- @Date    :
-- ========================================================

local  tbSupportDetail = Class("UMG.BaseWidget")
tbSupportDetail.AttrPath = "UMG/Role/Widget/uw_role_attribute_data"

function tbSupportDetail:Construct()
    self.AttrItem = Model.Use(self, self.AttrPath)
    self.AffixFactory = Model.Use(self)
    self.SkillFactory = Model.Use(self)

    self:DoClearListItems(self.LixtAffix)
end

function tbSupportDetail:OnInit()

end

function tbSupportDetail:OnOpen(InCard)
    self.Popup:Init(
        Text(InCard:I18N()),
        function()
            UI.CloseByName("SupportDetail")
        end,
        InCard:Icon())
    --- 属性列表
    local tbSlot = UE4.TArray(UE4.USupporterCard)
    self:ShowAttrList(InCard)
    --- 词缀列表
    self:ShowAffixList(InCard)
    --- 套装技能
    local Skills = Logistics.GetAllSlotSkills(tbSlot:ToTable())
    self:ShowSlotSkills(Skills)
    --- 激活套装
    -- local SuitSkill = UE4.TArray(UE4.int32)
    self:ShowSuitInfo(InCard)
    
    -- self.Suit:OnActive(SuitSkill:ToTable(), 1)
end

function tbSupportDetail:SetAttrInfo(InName,InVal)
    self.TxtName:SetText(InName)
    self.TxtAttr:SetText(InVal)
end

--- 属性列表
---@param InType Enum AttrSign
function tbSupportDetail:ShowAttrList(InCard)
    local ListMainAttr = {}
    local ListSubAttr = {}

    ---获得属性并合并相同的属性
    for i = 1, 3 do
        local pSlot = InCard:GetSupporterCardForIndex(i)
        if pSlot then
            local MainAttrList = Logistics.GetMainAttr(pSlot)
            local SubAttr = Logistics.GetSubAttr(pSlot)
            if MainAttrList then
                --- 合并相同的属性值
                for _, MainAttr in pairs(MainAttrList) do
                    local IsMerged = false
                    for _, tbAttr in pairs(ListMainAttr) do
                        if tbAttr.sType == MainAttr.sType then
                            tbAttr.Attr = tbAttr.Attr + MainAttr.Attr
                            IsMerged = true
                            break
                        end
                    end
                    if not IsMerged then
                        table.insert(ListMainAttr, MainAttr)
                    end
                end
            end

            if SubAttr then
                --- 合并相同的属性值
                local IsMerged = false
                for _, tbAttr in pairs(ListSubAttr) do
                    if tbAttr.sType == SubAttr.sType then
                        tbAttr.Attr = tbAttr.Attr + SubAttr.Attr
                        IsMerged = true
                        break
                    end
                end
                if not IsMerged then
                    table.insert(ListSubAttr, SubAttr)
                end
            end
        end
    end

    for i = 1, 3 do
        local tbAttr = ListSubAttr[i]
        if tbAttr then
            self["SubAttr"..i]:Display(tbAttr)
            WidgetUtils.HitTestInvisible(self["SubAttr"..i])
        else
            WidgetUtils.Collapsed(self["SubAttr"..i])
        end
    end

    for i = 1, 4 do
        local tbAttr = ListMainAttr[i]
        if tbAttr then
            self["Attr"..i]:Display(tbAttr)
            WidgetUtils.HitTestInvisible(self["Attr"..i])
        else
            WidgetUtils.Collapsed(self["Attr"..i])
        end
    end
end

--- 洗练词缀
function tbSupportDetail:ShowAffixList(InCard)
    for i = 1, 3 do
        local pSlot = InCard:GetSupporterCardForIndex(i)
        if pSlot then
            local affix3 = pSlot:GetAffix(3)
            local key3 = affix3:Get(1)
            local value3 = affix3:Get(2)
            local HasAffix3 = true
            if not (key3 and value3) or key3 == 0 or value3 == 0 then
                HasAffix3 = false
            end
            local tbParam = {
                sName = Text(pSlot:I18N()),
                Des1 = Logistics.GetAffixShowNameByTarray(pSlot:GetAffix(1)),
                Des2 = Logistics.GetAffixShowNameByTarray(pSlot:GetAffix(2)),
                Des3 = Logistics.GetAffixShowNameByTarray(affix3),
                HasAffix3 = HasAffix3
            }
            local NewObj = self.AffixFactory:Create(tbParam)
            self.LixtAffix:AddItem(NewObj)
        end
    end
end

--- 技能套装
function tbSupportDetail:ShowSlotSkills(InSkills)
    self:DoClearListItems(self.ListSkill)
    for index, value in ipairs(InSkills) do
        local tbParam = 
            {   
                sTitle = Text("arms_lv2"),
                nLv = 999,
                sName = SkillName(value),
                sDes  = SkillDesc(value),
            }
        local NewObj = self.AffixFactory:Create(tbParam)
        self.ListSkill:AddItem(NewObj)
    end
end

function tbSupportDetail:ShowSuitInfo(InCard)
    local SuitSkill = InCard:GetSupporterSuitFirstSkill()
    ---激活的套装数
    local nSkill = SuitSkill:Length()
    if nSkill == 0 then
        WidgetUtils.Collapsed(self.PanelActive)
        WidgetUtils.SelfHitTestInvisible(self.PanelNotActive)
        return
    end
    WidgetUtils.Collapsed(self.PanelNotActive)
    WidgetUtils.SelfHitTestInvisible(self.PanelActive)

    self.TxtNum:SetText(string.format("(%d/3)", nSkill + 1))
    self.TxtSuitName:SetText()
    self.TxtSuitName:SetText(SkillName(SuitSkill:Get(1)))
    if nSkill == 1 then
        local SlotArray = InCard:GetSupporterSuit()
        local pSupportCard = InCard:GetSupporterCard(SlotArray:Get(1))
        local ThreeSuitSkill = UE4.TArray(UE4.int32)
        pSupportCard:GetSuitFirstSkills(3, ThreeSuitSkill)
        self.TxtSuitInfo2:SetContent(SkillDesc(SuitSkill:Get(1)))
        if ThreeSuitSkill:Length() > 0 then
            self.TxtSuitInfo3_1:SetContent(SkillDesc(ThreeSuitSkill:Get(1)))
        end
        WidgetUtils.SelfHitTestInvisible(self.Activity)
        WidgetUtils.SelfHitTestInvisible(self.NoActivity2)
        WidgetUtils.Collapsed(self.Activity2)
    elseif nSkill == 2 then
        self.TxtSuitInfo2:SetContent(SkillDesc(SuitSkill:Get(1)))
        self.TxtSuitInfo3:SetContent(SkillDesc(SuitSkill:Get(2)))
        WidgetUtils.SelfHitTestInvisible(self.Activity)
        WidgetUtils.SelfHitTestInvisible(self.Activity2)
        WidgetUtils.Collapsed(self.NoActivity2)
    end
end

return tbSupportDetail