-- ========================================================
-- @File    : uw_iteminfo_weaponinfo.lua
-- @Brief   : 道具信息展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
end

---显示道具信息
---@param pItem UWeaponItem
function tbClass:ShowItem(pItem)
    self.TxtNameItem:SetText(pItem:EnhanceLevel())
    self.Level:SetText(pItem:EnhanceLevel())
    self.TxtMax:SetText(Item.GetMaxLevel(pItem))
    self.TxtNameItem:SetText(Item.GetName(pItem))
    self.TxtIntro:SetText(Item.GetDes(pItem))
    self.TxtType:SetText(Weapon.GetTypeName(pItem))

    self:SetStar(pItem:Break())

    SetTexture(self.ImgQuality, Item.ItemInfoColorIcon[pItem:Color()])
    SetTexture(self.ImgType, Item.WeaponTypeIcon[pItem:Detail()])
    SetTexture(self.Imglogo, pItem:Icon())
    if pItem:Icon() > 0 then
        SetTexture(self.ImgIcon, pItem:Icon())
    end

    local tbLimit = Weapon.GetWeaponPartsLimit(pItem)
    if tbLimit then
        for _, nSlot in ipairs(Weapon.tbShowPart) do
            if tbLimit[nSlot] and tbLimit[nSlot] ~= 0 then
                WidgetUtils.Visible(self["Part" .. nSlot])
                if pItem:GetSlotItem(nSlot) then
                    WidgetUtils.Visible(self["arms_s" .. nSlot])
                    WidgetUtils.Collapsed(self["arms_s" .. nSlot .. "_1"])
                else
                    WidgetUtils.Collapsed(self["arms_s" .. nSlot])
                    WidgetUtils.Visible(self["arms_s" .. nSlot .. "_1"])
                end
            else
                WidgetUtils.Collapsed(self["Part" .. nSlot])
            end
        end
        -- 屏蔽枪托
        WidgetUtils.Collapsed(self["Part" .. UE4.EWeaponSlotType.Butt])
    end

    if pItem:HasFlag(Item.FLAG_USE) then
        WidgetUtils.Visible(self.Equipped)
        local pTmpData = UE4.TArray(UE4.UItem)
        me:GetItemsByType(UE4.EItemType.CharacterCard, pTmpData)
        for i = 1, pTmpData:Length() do
            local pCard = pTmpData:Get(i)
            local pEquip = pCard:GetSlotItem(UE4.ECardSlotType.Weapon)
            if pEquip and pEquip:Id() == pItem:Id() and pEquip:Icon() > 0 then
                SetTexture(self.ImgHead, pCard:Icon())
                break
            end
        end
    else
        WidgetUtils.Collapsed(self.Equipped)
    end

    self.atktype:SetData(pItem, true)
    self.specs:SetData(pItem, true)

    self:DoClearListItems(self.ListAtt)

    for _, nType in ipairs(Weapon.tbShowAttr) do
        local sKey = UE4.UUMGLibrary.GetEnumValueAsString("EWeaponAttributeType", nType)
        local nValue = Weapon.ConvertDes(nType, UE4.UItemLibrary.GetWeaponAbilityValueToStr(nType, pItem))
        local tbParam = {sPreWord = Text("attribute." .. sKey), nIcon = Resource.GetAttrPaint(sKey), nNum = nValue, bItemInfo=true}
        local pObj = self.Factory:Create(tbParam)
        self.ListAtt:AddItem(pObj)
    end

    local nSkillID = 0
    if pItem:IsWeapon() then
        local tbSkillID = Weapon.GetWeaponConfig(pItem).DefaultSkillID
        if tbSkillID then
            nSkillID = tbSkillID[1]
        end
    else
        nSkillID = Logistics.GetSkillID(pItem)
    end

    if not nSkillID or nSkillID == 0 then
        WidgetUtils.Hidden(self.PanelSkill)
        return
    else
        WidgetUtils.Visible(self.PanelSkill)
    end
    local nLevel = pItem:Evolue() + 1
    local nLvMax = 5
    if Weapon.tbEvolutionMaterials[pItem:EvolutionMatID()] then
        nLvMax = #Weapon.tbEvolutionMaterials[pItem:EvolutionMatID()] + 1
    end

    self.Level_2:SetText(nLevel)
    self.TxtMax_1:SetText(nLvMax)

    self.TxtSkillName:SetText(Localization.GetSkillName(nSkillID))
    self.TxtSkillInfo:SetContent(SkillDesc(nSkillID, nil, nLevel))

   self:DealJumpInfo({pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level()})
end

function tbClass:SetStar(nStar)
    for i = 1, 6 do
        if i > nStar then
            WidgetUtils.Collapsed(self["s_" .. i].ImgStar)
            WidgetUtils.Visible(self["s_" .. i].ImgStarOff)
        else
            WidgetUtils.Visible(self["s_" .. i].ImgStar)
            WidgetUtils.Collapsed(self["s_" .. i].ImgStarOff)
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
