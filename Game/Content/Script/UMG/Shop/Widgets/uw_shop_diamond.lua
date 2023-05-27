-- ========================================================
-- @File    : uw_shop_purchase.lua
-- @Brief   : 商城数据金页面
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Info.BtnInfo, function()
        UI.Open("ItemInfo", "ShowJPInfo")
    end)
end

--显示
function tbClass:ShowMallInfo(tbData)
    local tbConfig = tbData and tbData.tbConfig
    if not tbConfig then return end

    if tbConfig.nPic and self.Bg then
        SetTexture(self.Bg, tbConfig.nPic)
    end

    local tbgoods = IBLogic.GetIBShowGoods(tbConfig.nShopId)
    local nShowIdx = 1
    for _, config in ipairs(tbgoods) do
        local tbPanel = self[tostring(nShowIdx)]
        if tbPanel then
            WidgetUtils.SelfHitTestInvisible(tbPanel)
        end

        if self:ShowItem(nShowIdx, config) then
            nShowIdx = nShowIdx + 1
        end
    end

    for i=nShowIdx,6 do
        local tbPanel = self[tostring(i)]
        if tbPanel then
            WidgetUtils.Collapsed(tbPanel)
        end
    end

    if Localization.GetCurrentLanguage() == "ja_JP" then
        WidgetUtils.SelfHitTestInvisible(self.Info)
    else
        WidgetUtils.Collapsed(self.Info)
    end
end

--显示单个商品
function tbClass:ShowItem(nPos, tbConfig)
    if not nPos or not tbConfig then return end

    local tbPanel = self[tostring(nPos)]
    WidgetUtils.SelfHitTestInvisible(tbPanel)

    local numPanel = self["Num"..nPos]
    local btnPanel = self["Btn"..nPos]
    if not  numPanel then return end

    self:ShowTag(nPos, tbConfig)

    --价格
    local priceInfo = IBLogic.GetRealPrice(tbConfig)
    if priceInfo and priceInfo[2] and priceInfo[2] > 0 then

        local sIcon = Cash.GetMoneyInfo(priceInfo[1])
        if sIcon then
            --SetTexture(self.Image_112 , sIcon)
        end

        numPanel:SetText(NumberToString(priceInfo[2]))
    else    ---免费
        numPanel:SetText(Text("ui.TxtFree"))
    end

    BtnClearEvent(btnPanel)
    BtnAddEvent(btnPanel, function()
        self:ClickMallTips(tbConfig)
    end)

    return true
end

--显示首次等
function tbClass:ShowTag(nPos, tbConfig)
    local tagPanel = self["Tag"..nPos]
    --local iconPanel = self["ImgIcon"..nPos]
    local freePanel = self["FreeNum"..nPos]
    local textPanel = self["CustomTextBlock"..nPos]
    if not tagPanel then return end

    if #tbConfig.tbParam > 0 and tbConfig.tbParam[1] > 0 and IBLogic.GetBuyNum(tbConfig.nGoodsId) <= 0 then
        WidgetUtils.SelfHitTestInvisible(tagPanel)
        textPanel:SetText("TxtShopSend")
        freePanel:SetText(NumberToString(tbConfig.tbParam[1]))
    elseif #tbConfig.tbParam > 1 and tbConfig.tbParam[2] > 0 then
        WidgetUtils.SelfHitTestInvisible(tagPanel)
        textPanel:SetText("TxTShopExtra")
        freePanel:SetText(NumberToString(tbConfig.tbParam[2]))
    else
        WidgetUtils.Collapsed(tagPanel)
    end
end

function tbClass:ClickMallTips(tbConfig)
    if not tbConfig then return end

    if tbConfig.nLimitType > 0 and tbConfig.nLimitNum ~= -1 then
        if IBLogic.GetBuyNum(tbConfig.nGoodsId) >= tbConfig.nLimitNum then
            UI.ShowTip(Text("ui.TxtSellOut"))
            return
        end
    end

    local nExtraNum = 0
    if #tbConfig.tbParam > 0 and tbConfig.tbParam[1] > 0 and IBLogic.GetBuyNum(tbConfig.nGoodsId) <= 0 then
        nExtraNum = nExtraNum + tbConfig.tbParam[1] or 0
    elseif #tbConfig.tbParam > 1 and tbConfig.tbParam[2] > 0 then
        nExtraNum = nExtraNum + tbConfig.tbParam[2] or 0
    end

    local DoFunc = function ()
        local  tbPrice = IBLogic.GetRealPrice(tbConfig)
        local tbInfo = {
            tbExchange = {
                nCashID = tbPrice and tbPrice[1] or Cash.MoneyType_Money,
                nCount = tbPrice and tbPrice[2] or 0
            },
            tbExhcangTarget = {
                nCashID = Cash.MoneyType_Gold,
                nCount = tbConfig.tbItem[5] or 0
            },
        }
        tbInfo.bMall = true
        tbInfo.nExtra = nExtraNum
        tbInfo.nGoodsId = tbConfig.nGoodsId
        UI.Open("PurchaseExchange", tbInfo)
    end

    if tbConfig.nAddiction > 0 then
        UI.Open("MessageBox", Text("ui.WarningTips"), DoFunc)
    else
        DoFunc()
    end
end

return tbClass
