-- ========================================================
-- @File    : uw_shop_itemfashion.lua
-- @Brief   : 商城界面-皮肤商品
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.ButtonTips, function()
        self:DoClickShow()
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    if not pObj or not pObj.Data then return end

    self.bMall = pObj.Data.bMall
    self.tbParam = pObj.Data.tbConfig
    self.doSelectFunc = pObj.Data.doSelect
    pObj.Data.ShowSelectFunc = function(bShow)   
        if bShow then
            WidgetUtils.SelfHitTestInvisible(self.PanelSelect)
        else
            WidgetUtils.Collapsed(self.PanelSelect)
        end
        pObj.Data.bShow = bShow
    end

    pObj.Data.ShowSelectFunc(pObj.Data.bShow)

    local tbItemList = IBLogic.GetSkinItem(self.tbParam)
    if not tbItemList or #tbItemList == 0 then 
        return
    end

    local tbSkinItem = tbItemList[1]
    if not tbSkinItem or tbSkinItem[1] ~= Item.TYPE_CARD_SKIN then 
        return 
    end

    self:ShowMallItem(tbSkinItem)
end

--显示商城物品
function tbClass:ShowMallItem(tbSkinItem)
   --限购
    local buyNum = IBLogic.GetBuyNum(self.tbParam.nGoodsId)

    --图标、名字
    self:ShowItemInfo(tbSkinItem)

    local iteminfo = UE4.UItem.FindTemplate(tbSkinItem[1], tbSkinItem[2], tbSkinItem[3], tbSkinItem[4])
    --价格
    local isDiscount = false  --是否有优惠
    local priceInfo = IBLogic.GetRealPrice(self.tbParam)
    local nPrePrice1 = 0
    local nPrePrice2 = 0
    if priceInfo then
        priceInfo = {priceInfo}
    end

    if self.tbParam.tbCost and #self.tbParam.tbCost > 0 then
        nPrePrice1 = self.tbParam.tbCost[#self.tbParam.tbCost]
    end

    --售卖完了
    self:ShowSoldout(buyNum, self.tbParam.nLimitType, self.tbParam.nLimitTimes, iteminfo, tbSkinItem)
end

function tbClass:ShowShadowHex(InColor)
    local  HexColor = Color.tbShadowHex[InColor]
    self.ImgPieceQuality:SetColorAndOpacity(UE4.FLinearColor(HexColor.R,HexColor.G,HexColor.B,HexColor.A))
end

---显示下次刷新时间
function tbClass:UpdateRefreshTime()
    local nowTime = GetTime()
    if not WidgetUtils.IsVisible(self.SoldOut) and self.tbParam.nEndTime > 0 and self.tbParam.nEndTime > nowTime then
        WidgetUtils.SelfHitTestInvisible(self.PanelTime)
        self.PanelTime:ShowNormal(self.tbParam.nEndTime, nil, nil, true, {{0,0,0,0.6}, {0,0,0,1}})
    elseif not WidgetUtils.IsVisible(self.SoldOut) and self.tbParam.nOffEndTime > 0 and self.tbParam.nOffEndTime > nowTime then
        WidgetUtils.SelfHitTestInvisible(self.PanelTime)
        self.PanelTime:ShowNormal(self.tbParam.nEndTime, nil, nil, true, {{0,0,0,0.6}, {0,0,0,1}})
    else
        WidgetUtils.Collapsed(self.PanelTime)
    end
end

--------显示细分
--限购数量
function tbClass:ShowLimitInfo(nBuyNum, nLimitNum)
    nBuyNum = nBuyNum or 0
    if not nLimitNum or nLimitNum <= 0 then 
        WidgetUtils.Collapsed(self.LimitNum)
        return 
    end

    WidgetUtils.SelfHitTestInvisible(self.LimitNum)
    if self.TxtLimitNum then
        self.TxtLimitNum:SetText(nLimitNum - nBuyNum .. "/" .. nLimitNum)
        if nLimitNum - nBuyNum == 0 then
            self.TxtLimitNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1))
        else
            self.TxtLimitNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
        end
    end
end

--显示条件信息
function tbClass:ShowCondition(tbCondition)
    if not tbCondition then 
        WidgetUtils.Collapsed(self.PanelLock)
        return
    end

    local bUnlock, tbDes = Condition.Check(tbCondition)
    if bUnlock then
        WidgetUtils.Collapsed(self.PanelLock)
    else
        WidgetUtils.HitTestInvisible(self.PanelLock)
        if tbDes and #tbDes >= 1 then
            self.TxtCondition:SetText(tbDes[1])
        else
            self.TxtCondition:SetText("")
        end
    end
end

--显示名字等物品信息
function tbClass:ShowItemInfo(tbGDPLN)
    WidgetUtils.Collapsed(self.NewTag)
    local doHide = function() 
        WidgetUtils.Collapsed(self.Icon)
    end

    if not tbGDPLN or #tbGDPLN < 5 then 
        doHide()
        return
    end

    --图标、名字
    local iteminfo = UE4.UItem.FindTemplate(tbGDPLN[1], tbGDPLN[2], tbGDPLN[3], tbGDPLN[4])
    if not iteminfo or iteminfo.Genre == 0 then
        doHide()
        return
    end

    WidgetUtils.HitTestInvisible(self.Icon)
    SetTexture(self.Icon, iteminfo.Icon)
end

--获取代币的显示信息
function tbClass:GetShowCash(tbPriceInfo)
    if not tbPriceInfo then return end

    local nPriceNum = tbPriceInfo and #tbPriceInfo
    if nPriceNum == 0 then
        return
    end

    local icon = nil
    local havenum = 0
    if nPriceNum >= 5 then
        local temp = UE4.UItem.FindTemplate(tbPriceInfo[1], tbPriceInfo[2], tbPriceInfo[3], tbPriceInfo[4])
        icon = temp.Icon
        havenum = me:GetItemCount(tbPriceInfo[1], tbPriceInfo[2], tbPriceInfo[3], tbPriceInfo[4])
    else
        if tbPriceInfo[1] == Cash.MoneyType_RMB then
            local _,sIcon, nNeed = IBLogic.GetMoneyFormat(tbPriceInfo[2], 2)
            if sIcon and nNeed then
                return sIcon, nNeed, nNeed, true
            end
        else
            icon, _, havenum = Cash.GetMoneyInfo(tbPriceInfo[1])
        end
    end

    return icon, havenum, tbPriceInfo[nPriceNum]
end

--显示售罄
function tbClass:ShowSoldout(nBuyNum, nLimitType, nLimitNum, tbItemInfo, tbGDPLN, nTips)
    nBuyNum = nBuyNum or 999999
    nLimitType = nLimitType or 0
    nLimitNum = nLimitNum or 0
    if tbItemInfo and tbItemInfo.Genre == Item.TYPE_CARD_SKIN and Fashion.CheckSkinItem(tbGDPLN) then --时装道具只能拥有一个
        WidgetUtils.Collapsed(self.SpecialTag)
        WidgetUtils.Collapsed(self.Charge)
        WidgetUtils.Visible(self.SoldOut)
    elseif nLimitType > 0 and nLimitNum ~= -1 and nBuyNum >= nLimitNum then   --售罄
        WidgetUtils.Collapsed(self.SpecialTag)
        WidgetUtils.Collapsed(self.Charge)
        WidgetUtils.Visible(self.SoldOut)   --显示售罄标签
    else
        WidgetUtils.Collapsed(self.SoldOut)
    end
end

--点击商品
function tbClass:DoClickShow()
    if self.doSelectFunc then
        self.doSelectFunc(self.tbParam.nGoodsId)
    end
end

return tbClass
