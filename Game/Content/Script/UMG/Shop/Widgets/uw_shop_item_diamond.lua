-- ========================================================
-- @File    : uw_shop_item_diamond.lua
-- @Brief   : 商城界面-数据金商品
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.ButtonTips, function()
        self:ClickMallTips()
    end)
end

function tbClass:OnListItemObjectSet(pObj)
        if not pObj or not pObj.Data then return end

        self.nExtraNum = 0
        self:ShowMallItem(pObj)
end

---付费商城商品显示
function tbClass:ShowMallItem(pObj)
    self.tbParam = pObj.Data.tbConfig
    if not self.tbParam then return end
    if #self.tbParam.tbItem == 0 then return end

    --图标、名字
    local iteminfo = UE4.UItem.FindTemplate(self.tbParam.tbItem[1], self.tbParam.tbItem[2], self.tbParam.tbItem[3], self.tbParam.tbItem[4])
    if iteminfo then
        self.TxtName:SetText(Text(iteminfo.I18N))
        SetTexture(self.Icon, iteminfo.Icon)
    end

    if self.tbParam.sItemName then
        self.TxtName:SetText(Text(self.tbParam.sItemName))
    end

    self.TxtExchange:SetText(NumberToString(self.tbParam.tbItem[5] or 1))
    if self.TxtExchange1 then
        self.TxtExchange1:SetText(NumberToString(self.tbParam.tbItem[5] or 1))
    end

    if #self.tbParam.tbParam > 0 and self.tbParam.tbParam[1] > 0 and IBLogic.GetBuyNum(self.tbParam.nGoodsId) <= 0 then
        WidgetUtils.HitTestInvisible(self.CustomText_1)
        WidgetUtils.HitTestInvisible(self.Image_174)
        self.CustomText:SetText("TxtShopSend")
        self.txtnum:SetText(NumberToString(self.tbParam.tbParam[1]))
        self.nExtraNum = self.nExtraNum + self.tbParam.tbParam[1] or 0
    elseif #self.tbParam.tbParam > 1 and self.tbParam.tbParam[2] > 0 then
        self.CustomText:SetText("TxTShopExtra")
        self.txtnum:SetText(NumberToString(self.tbParam.tbParam[2]))
        self.nExtraNum = self.nExtraNum + self.tbParam.tbParam[2] or 0
        WidgetUtils.Collapsed(self.CustomText_1)
        WidgetUtils.Collapsed(self.Image_174)
    else
        WidgetUtils.Collapsed(self.Tip)
        WidgetUtils.Collapsed(self.Image_174)
        WidgetUtils.Collapsed(self.CustomText_1)
    end

    --价格
    local priceInfo = self.tbParam.tbCost or {}
    if priceInfo[2] and priceInfo[2] > 0 then
        local sIcon = Cash.GetMoneyInfo(priceInfo[1])
        if sIcon then
            --SetTexture(self.Image_112 , sIcon)
        end

        self.TxtPrice:SetText(NumberToString(priceInfo[2]))
    else    ---免费
        self.TxtPrice:SetText(Text("ui.TxtFree"))
    end
end

function tbClass:ClickMallTips()
    if not self.tbParam then return end
    if self.tbParam.nLimitType > 0 and self.tbParam.nLimitNum ~= -1 then
        if IBLogic.GetBuyNum(self.tbParam.nGoodsId) >= self.tbParam.nLimitNum then
            UI.ShowTip(Text("ui.TxtSellOut"))
            return
        end
    end

    local DoFunc = function () 
        local tbInfo = {
            tbExchange = {
                nCashID = self.tbParam.tbCost and self.tbParam.tbCost[1] or Cash.MoneyType_Money,
                nCount = self.tbParam.tbCost and self.tbParam.tbCost[2] or 0
            },
            tbExhcangTarget = {
                nCashID = Cash.MoneyType_Gold,
                nCount = self.tbParam.tbItem[5] or 0
            },
        }
        tbInfo.bMall = true
        tbInfo.nExtra = self.nExtraNum
        tbInfo.nGoodsId = self.tbParam.nGoodsId
        UI.Open("PurchaseExchange", tbInfo)
    end

    if self.tbParam.nAddiction > 0 then
        UI.Open("MessageBox", Text("ui.WarningTips"), DoFunc)
    else
        DoFunc()
    end
end

return tbClass
