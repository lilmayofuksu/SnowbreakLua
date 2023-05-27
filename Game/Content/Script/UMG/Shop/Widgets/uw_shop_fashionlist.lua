-- ========================================================
-- @File    : uw_shop_fashionlist.lua
-- @Brief   : 商城界面- 皮肤界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self.TileView:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.TileView)

    BtnAddEvent(self.BtnGoChange, function()
        self:GotoBuy()
    end)

    BtnAddEvent(self.BtnBuy, function()
       self:GotoBuy()
    end)
end

--显示商城
function tbClass:ShowMallInfo(Data)
    local tbConfig = Data and Data.tbConfig
    if not tbConfig then 
        self:ShowEmpty()
        return 
    end

    self:ShowTileView(tbConfig, Data)
end

--显示右上角列表
function tbClass:ShowTileView(tbConfig, Data)
    if not tbConfig then return end

    local tbgoods = IBLogic.GetIBShowGoods(tbConfig.nShopId)
    self:DoClearListItems(self.TileView)
    local nGetIdx = 0
    self.tbAllShowList = {}
    for i, config in ipairs(tbgoods) do
        local tbData = {bMall = true, tbConfig = config}
        tbData.doSelect = function(nGoodsId)
            self:DoMainSelect(nGoodsId)
        end

        local pObj = self.Factory:Create(tbData)
        self.TileView:AddItem(pObj)

        self.tbAllShowList[config.nGoodsId] = pObj

        if Data.nSelectGoodsId and Data.nSelectGoodsId == config.nGoodsId then
            nGetIdx = i
        end
    end

    if nGetIdx == 0 then
        self:DoMainSelect(tbgoods[1].nGoodsId)
    else
        self:DoMainSelect(tbgoods[nGetIdx].nGoodsId)
    end

    if nGetIdx == #tbgoods and nGetIdx > 1 then
        nGetIdx = nGetIdx -1
    end
    self.TileView:ScrollIndexIntoView(nGetIdx)
end

--清空
function tbClass:ShowEmpty()
    WidgetUtils.Collapsed(self.PanelLimitTime)
    WidgetUtils.Collapsed(self.PanelLimitTimeSale)
    WidgetUtils.Collapsed(self.CurrencyOne)
    WidgetUtils.Collapsed(self.PanelInfo)
    WidgetUtils.Collapsed(self.PanelGift)
    WidgetUtils.Collapsed(self.ImgFashionPose)
end

--显示主要界面
function tbClass:ShowMain(tbConfig)
    if not tbConfig then 
        self:ShowEmpty()
        return 
    end

    local tbItemList = IBLogic.GetSkinItem(tbConfig)
    if not tbItemList or #tbItemList == 0 then 
        self:ShowEmpty()
        return 
    end

    local tbSkinItem = tbItemList[1]
    if not tbSkinItem or tbSkinItem[1] ~= Item.TYPE_CARD_SKIN then 
        self:ShowEmpty()
        return 
    end

    self.tbSkinItem = tbSkinItem
    self:ShowTime(tbConfig, tbSkinItem)
    local isDiscount = self:ShowMoney(tbConfig, tbSkinItem)
    self:ShowPanelInfo(tbConfig, tbSkinItem)
    self:ShowFlagInfo(1, tbConfig.nOffRate, isDiscount)
    self:ShowLimitTime(tbConfig)
    self:ShowPanelGift(tbItemList, Fashion.CheckSkinItem(tbSkinItem))
end

--显示时间
function tbClass:ShowTime(tbConfig, tbSkinItem)
    if not tbConfig then return end

    if  tbSkinItem and Fashion.CheckSkinItem(tbSkinItem) then --已经拥有
        WidgetUtils.Collapsed(self.CanvasPanel_200)
        return
    end

    local doEndTime = function()
        local sUI = UI.GetUI("Mall")
        if not sUI or not sUI:IsOpen() then
           return
        end
         sUI:OnByGoodsUpdate()
    end

    local nowTime = GetTime()
    if tbConfig.nEndTime > 0 and tbConfig.nEndTime > nowTime then
        WidgetUtils.SelfHitTestInvisible(self.CanvasPanel_200)
        self.PanelTime:ShowNormal(tbConfig.nEndTime, doEndTime, nil, true, {{0,0,0,0.6}, {0,0,0,1}})
    elseif tbConfig.nOffEndTime > 0 and tbConfig.nOffEndTime > nowTime then
        WidgetUtils.SelfHitTestInvisible(self.CanvasPanel_200)
        self.PanelTime:ShowNormal(tbConfig.nEndTime, doEndTime, nil, true, {{0,0,0,0.6}, {0,0,0,1}})
    else
        WidgetUtils.Collapsed(self.CanvasPanel_200)
    end
end

--显示价格控件
function tbClass:ShowMoney(tbConfig, tbSkinItem)
    if not tbConfig or not tbSkinItem then return end

    WidgetUtils.SelfHitTestInvisible(self.CurrencyOne)
    WidgetUtils.Collapsed(self.GoChange)

    if  Fashion.CheckSkinItem(tbSkinItem) then --已经拥有
        WidgetUtils.Collapsed(self.PanelGoBuy)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.PanelGoBuy)
    
    --价格
    local isDiscount = false  --是否有优惠
    local priceInfo = IBLogic.GetRealPrice(tbConfig)
    local nPrePrice1 = 0
    if priceInfo then
        priceInfo = {priceInfo}
    end

    if tbConfig.tbCost and #tbConfig.tbCost > 0 then
        nPrePrice1 = tbConfig.tbCost[#tbConfig.tbCost]
    end

    return self:ShowPriceMain(priceInfo, nPrePrice1)
end

--显示价格
function tbClass:ShowPriceMain(tbPriceInfo, nPrePrice1)
    if not tbPriceInfo then --免费?
        WidgetUtils.Collapsed(self.Discount1_1)
        WidgetUtils.Collapsed(self.IconCurrency1_1)
        WidgetUtils.Collapsed(self.TxtMoney)
        self.TxtNum1_1:SetText(Text("ui.TxtFree"))
        self.TxtNum1_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0.96, 0.87, 0.7, 1))
        return false
    end

    nPrePrice1 = nPrePrice1 or 0
    local isDiscount = false  --是否有优惠
    local icon1, haveNum1, disPrice1, bReal = self:GetShowCash(tbPriceInfo[1])

    if bReal then
        WidgetUtils.HitTestInvisible(self.TxtMoney)
        WidgetUtils.Collapsed(self.IconCurrency1_1)
        self.TxtMoney:SetText(icon1)
    else
        WidgetUtils.HitTestInvisible(self.IconCurrency1_1)
        WidgetUtils.Collapsed(self.TxtMoney)

        SetTexture(self.IconCurrency1_1, icon1)
    end

    self.TxtNum1_1:SetText(NumberToString(disPrice1))
    if disPrice1 < nPrePrice1 then
        isDiscount = true
        WidgetUtils.Visible(self.Discount1_1)
        self.PreNum1_1:SetText(NumberToString(nPrePrice1))
    else
        WidgetUtils.Collapsed(self.Discount1_1)
    end

    local tbPanel = {self.TxtNum1_1, self.PreNum1_1}
    local tbColor = { {0.96, 0.87, 0.7, 1}, {0.97, 0.97, 1, 0.8}}
    if haveNum1 < disPrice1 then --代币1不足
        tbColor = { {1, 0, 0, 1}, {1, 0, 0, 0.6}}
    end

    for i,v in ipairs(tbPanel) do
        v:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(table.unpack(tbColor[i])))
    end

    return isDiscount
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

--显示皮肤信息
function tbClass:ShowPanelInfo(tbConfig, tbSkinItem)
    if not tbConfig or not tbSkinItem then return end

    WidgetUtils.HitTestInvisible(self.PanelInfo)
    local doHide = function() 
        WidgetUtils.Collapsed(self.TxtGirlName)
        WidgetUtils.Collapsed(self.TxtName)
    end

    local iteminfo = UE4.UItem.FindTemplate(tbSkinItem[1], tbSkinItem[2], tbSkinItem[3], tbSkinItem[4])
    if not iteminfo or iteminfo.Genre == 0 then
        doHide()
        return
    end

    self.TxtName:SetText(Text(iteminfo.I18N))
    WidgetUtils.HitTestInvisible(self.ImgFashionPose)
    SetTexture(self.ImgFashionPose, iteminfo.Icon)

    local CardInfo = UE4.UItem.FindTemplate(1, tbSkinItem[2], tbSkinItem[3], 1)
    if CardInfo  then
        self.TxtGirlName:SetText(Text(CardInfo.I18N .. "_suits"))
    end
end

function tbClass:ShowFlagInfo(nDiscountType, nDiscount, isDiscount)
    if nDiscount and isDiscount then  -- 折扣特惠
        WidgetUtils.Visible(self.SpecialTag)
        if nDiscountType == 1 then --折扣
            WidgetUtils.Visible(self.TagDiscount)
            WidgetUtils.Collapsed(self.TagHot)
            self.TextDiscount2:SetText(string.format(Text("ui.TxtTagDiscount"), TackleDecimal(nDiscount/10)))
        elseif nDiscountType == 2 then  --特惠
            WidgetUtils.Visible(self.TagHot)
            WidgetUtils.Collapsed(self.TagDiscount)
        end
    else
        WidgetUtils.Collapsed(self.SpecialTag)
    end
end

function tbClass:ShowLimitTime(tbConfig)
    if not tbConfig then 
        WidgetUtils.Collapsed(self.LimitTime)
        return
    end

    if tbConfig.nOffRate > 0 and IsInTime(tbConfig.nOffStartTime, tbConfig.nOffEndTime) then
        WidgetUtils.HitTestInvisible(self.LimitTime)
    elseif tbConfig.nEndTime > 0 and IsInTime(tbConfig.nStartTime, tbConfig.nEndTime) then
        WidgetUtils.HitTestInvisible(self.LimitTime)
    else
        WidgetUtils.Collapsed(self.LimitTime)
    end
end

function tbClass:ShowPanelGift(tbItemList, bGet)
    if not tbItemList or #tbItemList < 1 then
        WidgetUtils.Collapsed(self.PanelGift)
        return
    end

    WidgetUtils.HitTestInvisible(self.PanelGift)

    self:DoClearListItems(self.ListGiftItem)
    for i=2,#tbItemList do
        local tbItem = tbItemList[i]
        local cfg = {G = tbItem[1], D = tbItem[2], P = tbItem[3], L = tbItem[4], N = tbItem[5], bGeted = bGet}
        local pObj = self.Factory:Create(cfg)
        self.ListGiftItem:AddItem(pObj)
    end
end

function tbClass:DoMainSelect(nGoodsId)
    if not nGoodsId then return end

    local pObj = self.tbAllShowList[nGoodsId]
    if not pObj or not pObj.Data then return end

    local tbItem = pObj.Data.tbConfig
    if not tbItem then return end

    if self.nShowGoodsId and self.tbAllShowList[self.nShowGoodsId] then
        if self.tbAllShowList[self.nShowGoodsId].Data.ShowSelectFunc then
            self.tbAllShowList[self.nShowGoodsId].Data.ShowSelectFunc(false)
        end
    end

    self.nShowGoodsId = nGoodsId
    pObj.Data.bShow = true
    self:ShowMain(tbItem)

    if pObj.Data.ShowSelectFunc then
        pObj.Data.ShowSelectFunc(true)
    end
    self:PlayAnimation(self.role_select)
end

function tbClass:GotoBuy()
    if not self.nShowGoodsId then return end

    local pObj = self.tbAllShowList[self.nShowGoodsId]
    if not pObj or not pObj.Data then return end

    local tbItem = pObj.Data.tbConfig
    if not tbItem then return end

    if not self.tbSkinItem then return end

    local bUnlock, tbDes = Condition.Check(tbItem.tbCondition)
    if not bUnlock then
        if tbDes and #tbDes >= 1 then
            UI.ShowTip(tbDes[1])
        end
        return
    end

    local tbParam = {
        CharacterTemplate = {Genre = 1, Detail = self.tbSkinItem[2], Particular = self.tbSkinItem[3], Level = 1},
        SkinIndex = self.tbSkinItem[4],
        tbMallConfig = tbItem,
    }

    if Fashion.CheckSkinItem(self.tbSkinItem) then
        --如果已购买, 进入对应界面更换
        UI.Open("RoleFashion", tbParam)
        return
    end

    local nBuyNum = IBLogic.GetBuyNum(tbItem.nGoodsId)
    if tbItem.nLimitType > 0 and tbItem.nLimitTimes > 0 then
        if nBuyNum >= tbItem.nLimitTimes then
            UI.ShowTip(Text("ui.TxtSellOut"))
            return
        end
    end

    UI.Open("RoleFashionPreview", tbParam)
end

return tbClass
