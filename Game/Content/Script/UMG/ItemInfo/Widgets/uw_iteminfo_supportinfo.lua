-- ========================================================
-- @File    : uw_iteminfo_supportinfo.lua
-- @Brief   : 道具信息展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
end

---显示模板信息
---@param pItemTemplate FItemTemplate
function tbClass:ShowTemplate(pItemTemplate)
    local GrowupID= Logistics.GetSupportGrowupIDByGDPL(pItemTemplate.Genre, pItemTemplate.Detail, pItemTemplate.Particular, pItemTemplate.Level)
    self.TxtNameItem:SetText(Text(pItemTemplate.I18N))
    if Text(pItemTemplate.I18N .. "_des")~=(pItemTemplate.I18N .. "_des") then
        self.TxtIntro:SetText(Text(pItemTemplate.I18N .. "_des"))
    else
        WidgetUtils.Collapsed(self.TxtIntro)
    end
    
    self.Level:SetText("1")
    self.TxtMax:SetText(Item.GetMaxLevlByTemplate(pItemTemplate))
    SetTexture(self.ImgQuality, Item.ItemInfoColorIcon[pItemTemplate.Color])
    SetTexture(self.ImgType, Item.SupportTypeIcon[pItemTemplate.Detail])
    if pItemTemplate.Icon > 0 then
        SetTexture(self.ImgIcon, pItemTemplate.Icon)
    end
    self:SetStar(pItemTemplate.InitBreak)
    WidgetUtils.Collapsed(self.Equipped)
    local tbGrow = Logistics.tbGrow[GrowupID]

    WidgetUtils.Collapsed(self.Attr1)
    WidgetUtils.Collapsed(self.Attr2)
    WidgetUtils.Collapsed(self.SubAttr1)
    WidgetUtils.Collapsed(self.SubAttr2)
    for _, v in pairs(tbGrow) do
        if string.find(tostring(_), "_break") then
            local tbParam = {
                Attr = v[1][2],
                sType = _,
                IsPercent = not (_ == "Command_break"),
                bItemInfo = true
            }
            self.SubAttr1:Display(tbParam)
            WidgetUtils.HitTestInvisible(self.SubAttr1)
        else
            local tbParam = {
                Attr = v[1][2],
                sType = _,
                bItemInfo = true
            }
            self.Attr1:Display(tbParam)
            WidgetUtils.HitTestInvisible(self.Attr1)
        end
    end
    
    local SkillList2=UE4.USupporterCard.FindSuitSkillTemplate(pItemTemplate.SuitSkill).TwoSkillID:ToTable()
    local SkillList3=UE4.USupporterCard.FindSuitSkillTemplate(pItemTemplate.SuitSkill).ThreeSkillID:ToTable()
    --- 套装技能效果
    --local pSkillList2, pSkillList3 = Logistics.GetSuitSkill(pItem)
    self.TxtSuitName:SetText(Localization.GetSkillName(SkillList2[1]))
    self.TxtSuitInfo2:SetContent(SkillDesc(SkillList2[1], nil,  1))
    self.TxtSuitInfo3:SetContent(SkillDesc(SkillList3[1], nil,  1))

    self.TxtAffixIntro1:SetText(Text("ui.TxtLogisAffixUnlockCondition1"))
    self.TxtAffixIntro2:SetText(Text("ui.TxtLogisAffixUnlockCondition2"))
    self.TxtAffixIntro3:SetText(Text("ui.TxtLogisAffixUnlockCondition3"))

    self:DealJumpInfo({pItemTemplate.Genre,pItemTemplate.Detail,pItemTemplate.Particular,pItemTemplate.Level})
end

function tbClass:ShowSuitSkill(InItemTemplate)
    
end

---显示道具信息
---@param pItem UItem
function tbClass:ShowItem(pItem)
    self.Level:SetText(pItem:EnhanceLevel())
    self.TxtMax:SetText(Item.GetMaxLevel(pItem))
    self.TxtNameItem:SetText(Item.GetName(pItem))
    self.TxtType:SetText(Text(Logistics.tbTeamDes[pItem:Detail()]))
    if Item.GetDes(pItem)~=(pItem:I18N() .. "_des") then
        self.TxtIntro:SetText(Item.GetDes(pItem))
    else
        WidgetUtils.Collapsed(self.TxtIntro)
    end

    SetTexture(self.ImgQuality, Item.ItemInfoColorIcon[pItem:Color()])
    SetTexture(self.ImgType, Item.SupportTypeIcon[pItem:Detail()])
    if pItem:Icon() > 0 then
        if Item.IsBreakMax(pItem) then
            SetTexture(self.ImgIcon, pItem:IconBreak())
        else
            SetTexture(self.ImgIcon, pItem:Icon())
        end
        
    end
    self:SetStar(pItem:Quality())

    if pItem:HasFlag(Item.FLAG_USE) then
        WidgetUtils.Visible(self.EquippedSupport)
        local pTmpData = UE4.TArray(UE4.UItem)
        me:GetItemsByType(UE4.EItemType.CharacterCard, pTmpData)
        for i = 1, pTmpData:Length() do
            for idx = 1, 3 do
                local pCard = pTmpData:Get(i)
                local pEquip = pCard:GetSlotItem(UE4.ECardSlotType["SupporterCard" .. idx])
                if pEquip and pEquip:Id() == pItem:Id() and pEquip:Icon() > 0 then
                    
                    SetTexture(self.ImgHead, pCard:Icon())
                    break
                end
                
            end
        end
    else
        WidgetUtils.Collapsed(self.EquippedSupport)
    end

    ---后勤卡属性显示
    WidgetUtils.Collapsed(self.Attr1)
    WidgetUtils.Collapsed(self.Attr2)
    WidgetUtils.Collapsed(self.SubAttr1)
    WidgetUtils.Collapsed(self.SubAttr2)

    local MainAttrList = Logistics.GetMainAttr(pItem)
    local tbSubAttr = Logistics.GetSubAttr(pItem)
    for _, tbMainAttr in pairs(MainAttrList) do
        local tbMainParam = {
            nValue = tbMainAttr.Attr,
            sType = tbMainAttr.sType,
            sDes = Text(string.format('attribute.%s', tbMainAttr.sType)),
            bItemInfo = true
        }
        self["Attr".._]:Display(tbMainParam)
        WidgetUtils.HitTestInvisible(self["Attr".._])
    end
    if tbSubAttr then
        local tbSubAttrParam = {
            nValue = tbSubAttr.Attr,
            sType = tbSubAttr.sType,
            sDes = Text(string.format('attribute.%s', tbSubAttr.sType)),
            IsPercent = tbSubAttr.IsPercent,
            bItemInfo = true
        }
        self.SubAttr1:Display(tbSubAttrParam)
    end
    WidgetUtils.HitTestInvisible(self.SubAttr1)

    --- 套装技能效果
    local pSkillList2, pSkillList3 = Logistics.GetSuitSkill(pItem)
    self.TxtSuitName:SetText(Localization.GetSkillName(pSkillList2:Get(1)))
    self.TxtSuitInfo2:SetContent(SkillDesc(pSkillList2:Get(1), nil, 1))
    self.TxtSuitInfo3:SetContent(SkillDesc(pSkillList3:Get(1), nil, 1))

    --- 显示词缀
    if pItem:GetAffix(1):Length()<=0 then
        WidgetUtils.Collapsed(self.TxtAffixIntro1)
        print("1")
    else
        self.TxtAffixIntro1:SetText(Logistics.GetAffixShowNameByTarray(pItem:GetAffix(1), 1))
    end

    if pItem:GetAffix(2):Length()<=0 then
        WidgetUtils.Collapsed(self.TxtAffixIntro2)
        print("2")
    else
        self.TxtAffixIntro2:SetText(Logistics.GetAffixShowNameByTarray(pItem:GetAffix(2), 2))
    end

    if pItem:GetAffix(3):Length()<=0 then
        WidgetUtils.Collapsed(self.TxtAffixIntro3)
        print("3")
    else
        self.TxtAffixIntro3:SetText(Logistics.GetAffixShowNameByTarray(pItem:GetAffix(3)))
    end
    --self.Skill:Set(pItem)
    self:DealJumpInfo({pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level()})
end

function tbClass:SetStar(nStar)
    for i = 1, 6 do
        if i < nStar then
            WidgetUtils.Visible(self["s_" .. i].ImgStar)
            WidgetUtils.Collapsed(self["s_" .. i].ImgStarOff)
        else
            WidgetUtils.Collapsed(self["s_" .. i].ImgStar)
            WidgetUtils.Visible(self["s_" .. i].ImgStarOff)
        end
    end
end
function tbClass:SetNum(n)
    if n==nil then
        self.TxtNum:SetText()
        return
    end
    if self.TxtNum~=nil then
        self.TxtNum:SetText(n)
    end
    
end

--处理跳转信息
function tbClass:DealJumpInfo(gdpl)
    if UI.bPoping then
        return
    end

    local hasDropWay = DropWay.ShowWaysOnUI(self, self.ListObtain, self.Factory, gdpl, self)
    WidgetUtils.Hidden(self.BtnObtainReturn)
    WidgetUtils.Collapsed(self.PanelListObtain)
    WidgetUtils.Visible(self.PanelContent)
    if Map.GetCurrentID() ~= 2 then--非主场景不显示跳转按钮
        hasDropWay = false;
    end
    if not hasDropWay then
        WidgetUtils.Collapsed(self.BtnObtain)
        WidgetUtils.Collapsed(self.PanelObtain)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.PanelObtain)
    WidgetUtils.Visible(self.BtnObtain)
end

return tbClass
