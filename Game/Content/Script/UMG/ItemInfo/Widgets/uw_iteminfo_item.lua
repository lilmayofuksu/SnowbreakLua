-- ========================================================
-- @File    : uw_iteminfo_item.lua
-- @Brief   : 道具信息展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

tbClass.tbTimeColor =
{
    {3600*12, 1005001},
    {3600*3, 1005002},
    {0, 1005003},
    {-1, 1005000},
}
tbClass.nSpiltDay = 24*3600

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self.ListObtain:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    self.ListItem:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

function tbClass:OnDestruct()
    if self.TimerHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
    end
    self.TimerHandle = nil
end

---显示模板信息
---@param pItemTemplate FItemTemplate
function tbClass:ShowTemplate(pItemTemplate)
    --self.TxtNameWeapon:SetText(Text(pItemTemplate.I18N))
    WidgetUtils.Collapsed(self.PanelCheckMoney)
    self.TxtNameItem:SetText(Text(pItemTemplate.I18N))
    if pItemTemplate.Genre == UE4.EItemType.CharacterCard then
        WidgetUtils.SelfHitTestInvisible(self.ImgLogo)
        self.TxtSkillIntro1:SetText(Text(pItemTemplate.I18N .. "_title"))

        SetClippingTeure(self.ImgIcon, pItemTemplate.Icon, {0,0}, 1, true)

        SetTexture(self.ImgLogo, pItemTemplate.Icon)
        WidgetUtils.Collapsed(self.IMgItemLogo)
    else
        self.TxtSkillIntro1:SetText(Text(pItemTemplate.I18N .. "_use"))
        SetTexture(self.ImgIcon, pItemTemplate.Icon, true)
        WidgetUtils.SelfHitTestInvisible(self.IMgItemLogo)
    end
    self.TxtIntro:SetText(Text(pItemTemplate.I18N .. "_des"))
    self.TxtType:SetText(Text(Item.TypeText[pItemTemplate.Genre]))
    SetTexture(self.ImgQuality, Item.ItemInfoColorIcon[pItemTemplate.Color])

    if pItemTemplate.Genre == UE4.EItemType.Suplies and pItemTemplate.Detail == 4 then
        WidgetUtils.HitTestInvisible(self.PanelPiece)
        SetTexture(self.ImgPiece, pItemTemplate.EXIcon)
    else
        WidgetUtils.Collapsed(self.PanelPiece)
    end

    self:DealJumpInfo({pItemTemplate.Genre, pItemTemplate.Detail, pItemTemplate.Particular, pItemTemplate.Level})

    self:ShowShadowHex(pItemTemplate.Color)
end

---设置数量
function tbClass:SetNum(n)
    if n == nil then
        self.TxtNum:SetText()
        return
    end
    if self.TxtNum ~= nil then
        self.TxtNum:SetText(n)
    end
end

function tbClass:IsItemShowInBag(pItem)
    if pItem.Type == UE4.EItemType.Weapon or pItem.Type == UE4.EItemType.SupporterCard or pItem.Type == UE4.EItemType.Useable or 
        pItem.Type == UE4.EItemType.WeaponParts or pItem.Type == UE4.EItemType.Suplies then
        return true
    end

    return false
end

---显示道具信息
---@param pItem UItem
function tbClass:ShowItem(pItem,bShowNum)
    WidgetUtils.Collapsed(self.PanelCheckMoney)
    self.TxtNameItem:SetText(Item.GetName(pItem))
    if pItem:IsCharacterCard() then
        self.TxtSkillIntro1:SetText(Item.GetTitle(pItem))
    else
        self.TxtSkillIntro1:SetText(Item.GetUse(pItem))
    end
    self.TxtIntro:SetText(Item.GetDes(pItem))
    self.TxtType:SetText(Text(Item.TypeText[pItem:Genre()]))

    WidgetUtils.Collapsed(self.PanelNum)
    -- local BagUI = UI.GetUI("Bag")
    if bShowNum and not pItem:IsCharacterCard() then
        local nHaveCount = 0
        if self:IsItemShowInBag(pItem) then
            nHaveCount = me:GetItemCount(pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level())
        end

        if nHaveCount > 0 then
            WidgetUtils.Visible(self.PanelNum)
            self.TxtNum:SetText(tostring(nHaveCount))
        end
    end

    SetTexture(self.ImgQuality, Item.ItemInfoColorIcon[pItem:Color()])
    if pItem:Icon() then
        if pItem:Genre() == UE4.EItemType.CharacterCard then
            SetTexture(self.ImgRole, pItem:Icon())
            SetTexture(self.ImgLogo, pItem:Icon())
            WidgetUtils.SelfHitTestInvisible(self.ImgRole)
            WidgetUtils.SelfHitTestInvisible(self.ImgLogo)
            WidgetUtils.Collapsed(self.ImgIcon)
            WidgetUtils.Collapsed(self.IMgItemLogo)
        else
            WidgetUtils.SelfHitTestInvisible(self.ImgIcon)
            WidgetUtils.Collapsed(self.ImgRole)
            WidgetUtils.Collapsed(self.ImgLogo)
            WidgetUtils.SelfHitTestInvisible(self.IMgItemLogo)
            SetTexture(self.ImgIcon, pItem:Icon())
        end
    end

    if pItem:Genre() == UE4.EItemType.Suplies and pItem:Detail() == 4 then
        WidgetUtils.HitTestInvisible(self.PanelPiece)
        SetTexture(self.ImgPiece, pItem:EXIcon())
        self:ShowShadowHex(pItem:Color())
    else
        WidgetUtils.Collapsed(self.PanelPiece)
    end

    self:DealJumpInfo({pItem:Genre(), pItem:Detail(), pItem:Particular(), pItem:Level()})

    self:ShowTime(pItem)

    self.TimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                self:ShowTime()
            end
        },
        0.5,
        true
    )
end

function tbClass:ShowTime(pItem)
    WidgetUtils.Collapsed(self.PanelCheckMoney)
    self.pItem = self.pItem or pItem
    if not self.pItem or self.pItem:Expiration() <= 0 then
        WidgetUtils.Collapsed(self.PanelLimitTime)
        return
    end

    WidgetUtils.Visible(self.PanelLimitTime)
    local nLast = self.pItem:Expiration() - GetTime()
    if nLast < 0 then
        nLast = 0
    end
    if nLast < self.nSpiltDay then 
        WidgetUtils.Collapsed(self.TxtDate)
        WidgetUtils.SelfHitTestInvisible(self.TxtTime)
        local sTime = string.format("%02d:%02d:%02d", math.floor(nLast/3600), math.floor(nLast%3600/60), math.floor(nLast%60))
        self.TxtTime:SetText(sTime)
    else
        WidgetUtils.SelfHitTestInvisible(self.TxtDate)
        WidgetUtils.Collapsed(self.TxtTime)
        local sData = string.format(Text('ui.TxtDungeonsTowerTime0'), math.floor(nLast/3600/24))
        self.TxtDate:SetText(sData)
    end

    for _, tbInfo in ipairs(self.tbTimeColor) do
        if nLast > tbInfo[1] or tbInfo[1] < 0 then
            SetTexture(self.ImgTimeBG, tbInfo[2])
            break
        end
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
    if Map.GetCurrentID() ~= 2 then --非主场景不显示跳转按钮
        hasDropWay = false
    end
    if not hasDropWay then
        WidgetUtils.Collapsed(self.BtnObtain)
        WidgetUtils.Collapsed(self.PanelObtain)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.PanelObtain)
    WidgetUtils.Visible(self.BtnObtain)
end

---显示代币信息
---@param moneycfg table 代币配置信息
function tbClass:ShowMoneyInfo(moneycfg,bShowNum)
    -- print("ShowMoneyInfo bShow:",bShow)
    -- if bShow == nil then
    --     print("debug:",debug.traceback())
    -- end
    WidgetUtils.Collapsed(self.PanelCheckMoney)
    WidgetUtils.Collapsed(self.PanelPiece)
    WidgetUtils.Collapsed(self.ImgRole)
    WidgetUtils.Collapsed(self.ImgLogo)
    SetTexture(self.ImgQuality, Item.ItemInfoColorIcon[moneycfg.nColor])
    SetTexture(self.ImgIcon, moneycfg.nIcon)
    self.TxtNameItem:SetText(Text(moneycfg.sName))
    self.TxtSkillIntro1:SetText(Text(moneycfg.sUse))
    self.TxtIntro:SetText(Text(moneycfg.sDesc))
    self.TxtType:SetText(Text(Item.TypeText[4]))
    WidgetUtils.SelfHitTestInvisible(self.IMgItemLogo)
    if bShowNum then
        self.TxtNum:SetText(Cash.GetMoneyCount(moneycfg.nId))
    end
    if moneycfg.tbItem then
        self:DealJumpInfo({moneycfg.tbItem[1],moneycfg.tbItem[2],moneycfg.tbItem[3],moneycfg.tbItem[4]})
    else
        self:DealJumpInfo()
    end
end

function tbClass:ShowShadowHex(InColor)
    local  HexColor = Color.tbShadowHex[InColor]
    if not HexColor then
        return
    end
    self.ImgPieceQuality:SetColorAndOpacity(UE4.FLinearColor(HexColor.R,HexColor.G,HexColor.B,HexColor.A))
end

---专属道具描述
function tbClass:ShowPanelNerve(InCard, InItem)
    if InCard and InItem and Spine.tbExItem[table.concat({InItem:Genre(),InItem:Detail(),InItem:Particular(),InItem:Level()}, "-")] then
        WidgetUtils.HitTestInvisible(self.PanelNerveIDesc)
        SetTexture(self.ImgNeverHead, InCard:Icon())
        self.TxtNerveIntro:SetText(Text("supplies.spineskilladd", Text(InCard:I18N().."_suits")))
        local Num = Spine.GetItemNumByGDPL(InCard:Id(), InItem:Genre(),InItem:Detail(),InItem:Particular(),InItem:Level())
        if Num and Num > 0 then
            WidgetUtils.Visible(self.PanelNum)
            self.TxtNum:SetText(Num)
        end
    else
        WidgetUtils.Collapsed(self.PanelNerveIDesc)
    end
end

---显示日语货币提示信息
function tbClass:ShowJPMoneyInfo()
    WidgetUtils.Collapsed(self.PanelPiece)
    WidgetUtils.Collapsed(self.ImgRole)
    WidgetUtils.Collapsed(self.ImgLogo)
    WidgetUtils.Collapsed(self.PanelBoxcontent)
    WidgetUtils.Collapsed(self.ScrollContent)
    WidgetUtils.Collapsed(self.PanelListObtain)
    WidgetUtils.Collapsed(self.PanelObtain)
    WidgetUtils.Collapsed(self.TxtType)

    WidgetUtils.SelfHitTestInvisible(self.PanelCheckMoney)
    WidgetUtils.SelfHitTestInvisible(self.PanelNum)
    
    self.TxtNumFree:SetText(NumberToString(Cash.GetMoneyCount(Cash.MoneyType_Gold) - Cash.GetMoneyCount(Cash.MoneyType_PayGold)))
    self.TxtNumFee:SetText(NumberToString(Cash.GetMoneyCount(Cash.MoneyType_PayGold)))
    self.TxtNum:SetText(NumberToString(Cash.GetMoneyCount(Cash.MoneyType_Gold)))
    
     SetTexture(self.ImgIcon, 1510046)
     self.TxtNameItem:SetText(Text("ui.TxtMoneyInformation"))
end

return tbClass
