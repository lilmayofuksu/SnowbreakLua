-- ========================================================
-- @File    : uw_shop_item_item2.lua
-- @Brief   : 商店界面-比特金商品
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.ButtonTips, function()
        if self.bMall then 
            self:ClickMallTips()
        else
            self:ClickShopTips()
        end
    end)
end

function tbClass:OnListItemObjectSet(pObj)
        if not pObj or not pObj.Data then return end

        if pObj.Data.bMall then
            self.bMall = pObj.Data.bMall
            self:ShowMallItem(pObj)
        else
            self:ShowShopItem(pObj)
        end
end

--商店商品显示
function tbClass:ShowShopItem(pObj)
    self.tbParam = pObj.Data

    --图标、名字
    local iteminfo = UE4.UItem.FindTemplate(self.tbParam.tbGDPLN[1], self.tbParam.tbGDPLN[2], self.tbParam.tbGDPLN[3], self.tbParam.tbGDPLN[4])
    if iteminfo then
        self.TxtName:SetText(Text(iteminfo.I18N))
        SetTexture(self.Icon, iteminfo.Icon)
    end

    self.TxtExchange:SetText(NumberToString(self.tbParam.tbGDPLN[5] or 1))

    if #self.tbParam.tbParam > 0 and ShopLogic.GetBuyNum(self.tbParam.nGoodsId) <= 0 then
        self.CustomText:SetText("TxtShopSend")
        self.txtnum:SetText(NumberToString(self.tbParam.tbParam[1]))
    else
        self.CustomText:SetText("TxTShopExtra")
        self.txtnum:SetText(NumberToString(self.tbParam.nExtra))
    end

    --价格
    local priceInfo = ShopLogic.GetBuyPrice(self.tbParam.nGoodsId, 1)
    if priceInfo[1] then
        self.TxtPrice:SetText(NumberToString(priceInfo[1][2]))
    else    ---免费
        WidgetUtils.Collapsed(self.Choice)
        WidgetUtils.Visible(self.Normal)
        WidgetUtils.Collapsed(self.CurrencyTwo)
        WidgetUtils.Visible(self.CurrencyOne)
        WidgetUtils.Collapsed(self.Discount1_1)
        WidgetUtils.Collapsed(self.IconCurrency1_1)
        self.TxtNum1_1:SetText(Text("ui.TxtFree"))
    end
end


---付费商城商品显示
function tbClass:ShowMallItem(pObj)
    self.tbParam = pObj.Data.tbConfig
    if not self.tbParam then return end
    if #self.tbParam.tbItem == 0 then return end

    --图标、名字
    local iteminfo = UE4.UItem.FindTemplate(self.tbParam.tbItem[1], self.tbParam.tbItem[2], self.tbParam.tbItem[3], self.tbParam.tbItem[4])
    if iteminfo then
        SetTexture(self.Icon, iteminfo.Icon)
    end
 
    WidgetUtils.SelfHitTestInvisible(self.TxtName)
    WidgetUtils.SelfHitTestInvisible(self.TxtExchange)
    WidgetUtils.SelfHitTestInvisible(self.Image_219)
    WidgetUtils.Collapsed(self.CustomTextBlock_75)

    self.TxtExchange:SetText(NumberToString(self.tbParam.tbItem[5] or 1))

    --图标、名字
    if self.tbParam.sItemName then
        self.TxtName:SetText(Text(self.tbParam.sItemName))
    elseif iteminfo then
        self.TxtName:SetText(Text(iteminfo.I18N))
    end

    --价格
    local priceInfo = self.tbParam.tbCost or {}
    if priceInfo[2] and priceInfo[2] > 0 then
        local _,sIcon,nPrice = IBLogic.GetPriceInfo(priceInfo)
        if sIcon then
            self.TxtSign:SetText(sIcon)
        end
        if nPrice then
            self.TxtPrice:SetText(NumberToString(nPrice))
        end
    else    ---免费
        self.TxtPrice:SetText(Text("ui.TxtFree"))
    end
end

--点击tips
function tbClass:ClickShopTips()
    if not self.tbParam then return end
    if self.tbParam.nLimitType > 0 and self.tbParam.nLimitTimes ~= -1 then
        if ShopLogic.GetBuyNum(self.tbParam.nGoodsId) >= self.tbParam.nLimitTimes then
            UI.ShowTip(Text("ui.TxtSellOut"))
            return
        end
    end
    if self.tbParam.nAddiction > 0 then
        UI.Open("MessageBox", Text("ui.WarningTips"),
            function()
                ShopLogic.BuyGoods(self.tbParam.nGoodsId)
            end
        )
    else
        ShopLogic.BuyGoods(self.tbParam.nGoodsId)
    end
end

function tbClass:ClickMallTips()
    if not self.tbParam then return end
    if self.tbParam.nLimitType > 0 and self.tbParam.nLimitNum ~= -1 then
        if IBLogic.GetBuyNum(self.tbParam.nGoodsId) >= self.tbParam.nLimitNum then
            UI.ShowTip("ui.TxtSellOut")
            return
        end
    end
    if self.tbParam.nAddiction > 0 then
        UI.Open("MessageBox", Text("ui.WarningTips"),
            function()
                IBLogic.BuyIbGoods(self.tbParam.nGoodsId)
            end
        )
    else
        IBLogic.BuyIbGoods(self.tbParam.nGoodsId)
    end
end

return tbClass
