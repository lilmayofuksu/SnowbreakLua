-- ========================================================
-- @File    : uw_shop_purchase.lua
-- @Brief   : 商城比特金页面
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Info.BtnInfo, function()
        UI.Open("ItemInfo", "ShowJPInfo")
    end)
end

--显示
function tbClass:ShowMallInfo(tbData)
    self.tbData = tbData
    local tbConfig = tbData and tbData.tbConfig
    if not tbConfig then return end

    if tbConfig.nPic and self.Bg then
        SetTexture(self.Bg, tbConfig.nPic)
    end

    local tbgoods = IBLogic.GetIBShowGoods(tbConfig.nShopId)
    local nShowIdx = 1
    for _, config in ipairs(tbgoods) do
        if self:ShowItem(nShowIdx, config) then
            nShowIdx = nShowIdx + 1
        end
    end

    for i=nShowIdx,6 do
        local numPanel = self[tostring(i)]
        if numPanel then
            WidgetUtils.Collapsed(numPanel)
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
    local symbolPanel = self["Symbol"..nPos]
    local btnPanel = self["Btn"..nPos]
    if not  numPanel or not symbolPanel then return end

    --价格
    local priceInfo = IBLogic.GetRealPrice(tbConfig)
    if priceInfo and priceInfo[2] and priceInfo[2] > 0 then
        WidgetUtils.SelfHitTestInvisible(symbolPanel)
        local _,sIcon,nPrice = IBLogic.GetPriceInfo(priceInfo)
        if sIcon then
            symbolPanel:SetText(sIcon)
        end
        if nPrice then
            numPanel:SetText(NumberToString(nPrice))
        end
    else    ---免费
        WidgetUtils.Collapsed(symbolPanel)
        numPanel:SetText(Text("ui.TxtFree"))
    end

    BtnClearEvent(btnPanel)
    BtnAddEvent(btnPanel, function()
        self:ClickMallTips(tbConfig)
    end)

    return true
end

function tbClass:ClickMallTips(tbConfig)
    if not tbConfig then return end

    if tbConfig.nLimitType > 0 and tbConfig.nLimitNum ~= -1 then
        if IBLogic.GetBuyNum(tbConfig.nGoodsId) >= tbConfig.nLimitNum then
            UI.ShowTip("ui.TxtSellOut")
            return
        end
    end

    if tbConfig.nAddiction > 0 then
        UI.Open("MessageBox", Text("ui.WarningTips"),
            function()
                IBLogic.BuyIbGoods(tbConfig.nGoodsId)
            end
        )
    else
        IBLogic.BuyIbGoods(tbConfig.nGoodsId)
    end
end

return tbClass
