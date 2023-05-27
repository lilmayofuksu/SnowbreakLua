-- ========================================================
-- @File    : uw_shop_itembox.lua
-- @Brief   : 商店界面-礼包商品
-- ========================================================

local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
    BtnAddEvent(self.ButtonTips, function()
        self:DoBtnTips()
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    if not pObj or not pObj.Data then return end

    if pObj.Data.bMall then
        self.bMall = pObj.Data.bMall
        self.tbParam = pObj.Data.tbConfig
        self:ShowMallItem()
    else
        self.tbParam = pObj.Data
        self:ShowShopItem()
    end
end

--显示商店物品
function tbClass:ShowShopItem()
   --限购
    local buyNum = ShopLogic.GetBuyNum(self.tbParam.nGoodsId)
    self:ShowLimitInfo(buyNum, self.tbParam.nLimitNum)

    --锁定？
    self:ShowCondition(self.tbParam.tbCondition)

    --图标、名字
    self:ShowItemInfo(self.tbParam.tbGDPLN)

    local iteminfo = UE4.UItem.FindTemplate(self.tbParam.tbGDPLN[1], self.tbParam.tbGDPLN[2], self.tbParam.tbGDPLN[3], self.tbParam.tbGDPLN[4])
    --价格
    local isDiscount = false  --是否有优惠
    local priceInfo = ShopLogic.GetBuyPrice(self.tbParam.nGoodsId, 1)
    local nPrePrice1 = 0
    local nPrePrice2 = 0
    if priceInfo then
        nPrePrice1 = self.tbParam.tbPrice1[#self.tbParam.tbPrice1]
        if self.tbParam.tbPrice2 then
            nPrePrice2 = self.tbParam.tbPrice2[#self.tbParam.tbPrice2]
        end
    end
    
     isDiscount = self:ShowPriceMain(priceInfo, nPrePrice1, nPrePrice2, self.tbParam.nCalculation, iteminfo)

    --标签信息  
    self:ShowSoldout(buyNum, self.tbParam.nLimitType, self.tbParam.nLimitNum, iteminfo, self.tbParam.tbGDPLN, self.tbParam.nTips)

    --标签信息
    local _, discount = ShopLogic.GetOnLineGoodsInfo(self.tbParam.nGoodsId)
    self:ShowFlagInfo(self.tbParam.nDiscountType, tbDiscount and tbDiscount[discount], isDiscount)

    --刷新时间
    self:ShowItemTime(self.tbParam.nEnd, self.tbParam.nLimitType)

    --红点标签 目前不显示
    self:ShowRedDot()
end

--显示商城物品
function tbClass:ShowMallItem()
   --限购
    local buyNum = IBLogic.GetBuyNum(self.tbParam.nGoodsId)
    self:ShowLimitInfo(buyNum, self.tbParam.nLimitTimes)

    --锁定？
    self:ShowCondition(self.tbParam.tbCondition)

    --图标、名字
    self:ShowItemInfo(self.tbParam.tbItem)

    local iteminfo = UE4.UItem.FindTemplate(self.tbParam.tbItem[1], self.tbParam.tbItem[2], self.tbParam.tbItem[3], self.tbParam.tbItem[4])
    if self.tbParam.nItemBg > 0 then
        WidgetUtils.HitTestInvisible(self.ImgQuality)
        SetTexture(self.ImgQuality, self.tbParam.nItemBg)
    else
        WidgetUtils.Collapsed(self.ImgQuality)
    end

    --价格
    local isDiscount = false  --是否有优惠
    local priceInfo = IBLogic.GetRealPrice(self.tbParam)
    local nPrePrice1 = 0
    local nPrePrice2 = 0
    if priceInfo then priceInfo = {priceInfo} end
    if self.tbParam.tbCost and #self.tbParam.tbCost > 0 then
        nPrePrice1 = self.tbParam.tbCost[#self.tbParam.tbCost]
    end
    
     isDiscount = self:ShowPriceMain(priceInfo, nPrePrice1, nPrePrice2, nil, iteminfo)

     local nTips = nil
     local nLimitType = self.tbParam.nLimitType
     if self.tbParam.nLimitType > 0 and self.tbParam.nLimitType < 4 then
        nTips = 2
        nLimitType = nLimitType + 1 --+1 是为了商城和商店保持显示时 类型一致
    end
    --标签信息  
    self:ShowSoldout(buyNum, nLimitType, self.tbParam.nLimitTimes, iteminfo, self.tbParam.tbItem, nTips)

    --标签信息
    --self:ShowFlagInfo(1, self.tbParam.nOffRate, isDiscount)

    --刷新时间
    if self.tbParam.nOffRate > 0 and self.tbParam.nOffEndTime > GetTime() then
        self:ShowItemTime(self.tbParam.nOffEndTime, nLimitType)
    else
        self:ShowItemTime(self.tbParam.nEndTime, nLimitType)
    end

    --红点标签
    self:ShowRedDot(self.tbParam)
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.detime then self.detime = 0 end
    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end
    self.detime = 0

    if self.bMall then
        if self.tbParam.nOffRate > 0 and self.tbParam.nOffEndTime > GetTime() then
            self:ShowItemTime(self.tbParam.nOffEndTime, self.tbParam.nLimitType+1)
        else
            self:ShowItemTime(self.tbParam.nEndTime, self.tbParam.nLimitType+1)
        end
    else
        self:ShowItemTime(self.tbParam.nEnd, self.tbParam.nLimitType)
    end
end

--显示倒计时
function tbClass:ShowItemTime(nEndTime, nLimitType)
    if nEndTime and nEndTime > 0 then
        if nEndTime > GetTime() then
            self.bOffEnd = true
            WidgetUtils.HitTestInvisible(self.LimitTime)
            local nDay, nHour, nMin, nSec = TimeDiff(nEndTime - GetTime())
            if nDay > 0 then
                self.TxtCompany:SetText(string.format(Text("ui.TxtDungeonsTowerTime0"), nDay))
            else
                self.TxtCompany:SetText(string.format("%02d:%02d:%02d", nHour, nMin, nSec))
            end
        else
            WidgetUtils.Collapsed(self.LimitTime)
            if not self.bMall and self.bOffEnd then --shop 商品(折扣)过期需要刷新
                self.bOffEnd = false
                ShopLogic.GetGoodsList(self.tbParam.nShopId)
            elseif self.bOffEnd then--需要刷新
                self.bOffEnd = false
                local sUI = UI.GetUI("Mall")
                if sUI then
                    sUI:OnByGoodsUpdate()
                end
            end
        end
    else
        WidgetUtils.Collapsed(self.LimitTime)
    end

    if self.ShowRefreshTime then
        self:UpdateRefreshTime(nLimitType)
    end
end

function tbClass:ShowShadowHex(InColor)
    local  HexColor = Color.tbShadowHex[InColor]
    self.ImgPieceQuality:SetColorAndOpacity(UE4.FLinearColor(HexColor.R,HexColor.G,HexColor.B,HexColor.A))
end

---显示下次刷新时间
function tbClass:UpdateRefreshTime(nLimitType)
    WidgetUtils.Collapsed(self.PanelDate)
    WidgetUtils.Collapsed(self.PanelTime)

    local nowTime = GetTime()
    local NextRefreshTime = GetTimeFor4AM(nowTime, nLimitType - 1)
    if NextRefreshTime > nowTime then
        local nDay, nHour, nMin, nSec = TimeDiff(NextRefreshTime - nowTime)
        if nDay > 0 then
            WidgetUtils.SelfHitTestInvisible(self.PanelDate)
            self.TxtDate:SetText(string.format(Text("ui.TxtDungeonsTowerTime0"), nDay))
        else
            WidgetUtils.SelfHitTestInvisible(self.PanelTime)
            self.TxtTime:SetText(string.format("%02d:%02d:%02d", nHour, nMin, nSec))
        end
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

    if self.bMall then
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
    local doHide = function() 
        WidgetUtils.Collapsed(self.Icon)
        WidgetUtils.Collapsed(self.TxtName)
        WidgetUtils.Collapsed(self.PanelType)
        WidgetUtils.Collapsed(self.WeaponMask)
        WidgetUtils.Collapsed(self.PanelPiece)
        WidgetUtils.Collapsed(self.Logo)
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

    self.TxtName:SetText(Text(iteminfo.I18N))

    if iteminfo.Genre == Item.TYPE_WEAPON then --武器类
        WidgetUtils.Collapsed(self.Icon)
        WidgetUtils.HitTestInvisible(self.WeaponMask)
        WidgetUtils.HitTestInvisible(self.PanelType)
        SetTexture(self.Imgweapon2, iteminfo.Icon)
        SetTexture(self.ImgType, Item.WeaponTypeIcon[iteminfo.Detail])
    else    --其他类
        WidgetUtils.Collapsed(self.PanelType)
        WidgetUtils.Collapsed(self.WeaponMask)
        WidgetUtils.HitTestInvisible(self.Icon)
        SetTexture(self.Icon, iteminfo.Icon)
    end

    --角色碎片
    if iteminfo.Genre == Item.TYPE_SUPPLIES and iteminfo.Detail == Item.TYPE_USEABLE then
        WidgetUtils.HitTestInvisible(self.PanelPiece)
        SetTexture(self.ImgPiece, iteminfo.EXIcon)
        self:ShowShadowHex(iteminfo.Color)
    else
        WidgetUtils.Collapsed(self.PanelPiece)
    end

    --品质条
    --SetTexture(self.Rarity, Item.ItemShopColorIcon[iteminfo.Color])

    --Logo
    if iteminfo.Genre >= Item.TYPE_CARD and iteminfo.Genre <= Item.TYPE_SUPPORT then
        WidgetUtils.HitTestInvisible(self.Logo)
        SetTexture(self.Logo, iteminfo.Icon)
    else
        WidgetUtils.Collapsed(self.Logo)
    end
    
    if self.TxtNum then
        self.TxtNum:SetText("X" .. (tbGDPLN[5] or 1))
    end
end

--显示价格
function tbClass:ShowPriceMain(tbPriceInfo, nPrePrice1, nPrePrice2, nCalculation, iteminfo)
    if not tbPriceInfo then --免费?
        WidgetUtils.Collapsed(self.Choice)
        WidgetUtils.HitTestInvisible(self.Normal)
        WidgetUtils.Collapsed(self.CurrencyTwo)
        WidgetUtils.HitTestInvisible(self.CurrencyOne)
        WidgetUtils.Collapsed(self.Discount1_1)
        WidgetUtils.Collapsed(self.IconCurrency1_1)
        self.TxtNum1_1:SetText(Text("ui.TxtFree"))
        self.TxtNum1_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
        return false
    end

    nPrePrice1 = nPrePrice1 or 0
    nPrePrice2 = nPrePrice2 or 0
    local isDiscount = false  --是否有优惠
    local icon1, haveNum1, disPrice1,bReal = self:GetShowCash(tbPriceInfo[1])
    if nCalculation == 1 and tbPriceInfo[2] then-- 代币二选一
        WidgetUtils.Collapsed(self.Normal)
        WidgetUtils.HitTestInvisible(self.Choice)

        local icon2, haveNum2, disPrice2 = self:GetShowCash(tbPriceInfo[2])

        local tbPanel = {
            ["icon1"] = self.IconCurrency1,
            ["icon2"] = self.IconCurrency2,
            ["disPrice1"] = self.TxtNum1,
            ["disPrice2"] = self.TxtNum2,
            ["Discount1"] = self.Discount1,
            ["Discount2"] = self.Discount2,
            ["PreNum1"] = self.PreNum1,
            ["PreNum2"] = self.PreNum2,
            ["TxtNum1"] = self.TxtNum1,
            ["TxtNum2"] = self.TxtNum2,
            ["PreNum1"] = self.PreNum1,
            ["PreNum2"] = self.PreNum2,
            ["Line1"] = self.Line2,
            ["Line2"] = self.Line2_1,
        }

        local tbData = {
            ["icon1"] = icon1,
            ["icon2"] = icon2,
            ["disPrice1"] = disPrice1,
            ["disPrice2"] = disPrice2,
            ["prePrice1"] = nPrePrice1,
            ["prePrice2"] = nPrePrice2,
            ["havenum1"] = haveNum1,
            ["havenum2"] = haveNum2,
        }
        isDiscount = self:ShowPricePanel(tbPanel, tbData)
        return isDiscount
    end

    WidgetUtils.Collapsed(self.Choice)
    WidgetUtils.HitTestInvisible(self.Normal)
    if nCalculation == 2 and tbPriceInfo[2] then -- 消耗两种代币
        WidgetUtils.Collapsed(self.CurrencyOne)
        WidgetUtils.HitTestInvisible(self.CurrencyTwo)

        local icon2, haveNum2, disPrice2 = self:GetShowCash(tbPriceInfo[2])
        local tbPanel = {
            ["icon1"] = self.IconCurrency1_2,
            ["icon2"] = self.IconCurrency1_3,
            ["disPrice1"] = self.TxtNum1_2,
            ["disPrice2"] = self.TxtNum1_3,
            ["Discount1"] = self.Two_1,
            ["Discount2"] = self.Two_2,
            ["PreNum1"] = self.PreNum1_3,
            ["PreNum2"] = self.PreNum1_2,
            ["TxtNum1"] = self.TxtNum1_2,
            ["TxtNum2"] = self.TxtNum1_3,
            ["PreNum1"] = self.PreNum1_3,
            ["PreNum2"] = self.PreNum1_2,
            ["Line1"] = self.Line2_3,
            ["Line2"] = self.Line2_2,
        }

        local tbData = {
            ["icon1"] = icon1,
            ["icon2"] = icon2,
            ["disPrice1"] = disPrice1,
            ["disPrice2"] = disPrice2,
            ["prePrice1"] = nPrePrice1,
            ["prePrice2"] = nPrePrice2,
            ["havenum1"] = haveNum1,
            ["havenum2"] = haveNum2,
        }
        isDiscount = self:ShowPricePanel(tbPanel, tbData)
        return isDiscount
    end

    --仅消耗代币一
    WidgetUtils.Collapsed(self.CurrencyTwo)
    WidgetUtils.HitTestInvisible(self.CurrencyOne)

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
        if self.bMall then
            WidgetUtils.Collapsed(self.Discount1_1)
        else
            WidgetUtils.HitTestInvisible(self.Discount1_1)
            self.PreNum1_1:SetText(NumberToString(nPrePrice1))
        end
    else
        WidgetUtils.Collapsed(self.Discount1_1)
    end

    local tbPanel = {self.TxtNum1_1, self.PreNum1_1, self.Line2_5}
    local tbColor = { {0.96, 0.87, 0.7, 1}, {0.97, 0.97, 1, 0.8}, {0.97, 0.97, 1, 0.6}}
    if haveNum1 < disPrice1 then --代币1不足
        tbColor = { {1, 0, 0, 1}, {1, 0, 0, 0.6}, {1, 0, 0, 0.6}}
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

--显示价格相关的控件
function tbClass:ShowPricePanel(tbPanel, tbData)
    if not tbPanel or not tbData then return false end

    for i=1,2 do
        local sName = "icon"..i
        if tbData[sName] then
            SetTexture(tbPanel[sName], tbData[sName])
        end
    end

    for i=1,2 do
        local sName = "disPrice"..i
        if tbPanel[sName] and tbData[sName] then
            tbPanel[sName]:SetText(tbData[sName])
        end
    end

    local isDiscount = false
    for i=1,2 do
        local sdisPrice = "disPrice"..i
        local sprePrice = "prePrice"..i
        local sDiscount = "Discount"..i
        local sPreNum = "PreNum"..i 
        if tbData[sdisPrice] and tbData[sprePrice] then
            if tbData[sdisPrice] < tbData[sprePrice] then
                isDiscount = true
                if tbPanel[sDiscount] then
                    WidgetUtils.HitTestInvisible(tbPanel[sDiscount])
                end
                if tbPanel[sPreNum] then
                    tbPanel[sPreNum]:SetText(nPrePrice1)
                end
            elseif tbPanel[sDiscount] then
                WidgetUtils.Collapsed(tbPanel[sDiscount])
            end
        end
    end

    for i=1,2 do
        local sdisPrice = "disPrice"..i
        local shaveNum = "havenum"..i
        local sTxtNum = "TxtNum"..i
        local sPreNum = "PreNum"..i
        local sLine = "Line"..i 
        if tbData[shaveNum] < tbData[sdisPrice] then --代币1不足
            tbPanel[sTxtNum]:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1))
            tbPanel[sPreNum]:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 0.6))
            tbPanel[sLine]:SetColorAndOpacity(UE4.FLinearColor(1, 0, 0, 0.6))
        else
            tbPanel[sTxtNum]:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
            tbPanel[sPreNum]:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 0.6))
            tbPanel[sLine]:SetColorAndOpacity(UE4.FLinearColor(0, 0, 0, 0.6))
        end
    end

    return isDiscount
end

--显示售罄
function tbClass:ShowSoldout(nBuyNum, nLimitType, nLimitNum, tbItemInfo, tbGDPLN, nTips)
    nBuyNum = nBuyNum or 999999
    nLimitType = nLimitType or 0
    nLimitNum = nLimitNum or 0
    WidgetUtils.Collapsed(self.Time)
    WidgetUtils.Collapsed(self.SoldOut)
    self.ShowRefreshTime = false
    if nLimitType > 0 and nLimitNum ~= -1 and nBuyNum >= nLimitNum then   --售罄
        if nTips == 2 and self.Time then --显示下次刷新倒计时
            WidgetUtils.HitTestInvisible(self.Time)
            self.ShowRefreshTime = true
            self:UpdateRefreshTime(nLimitType)
        else
            WidgetUtils.HitTestInvisible(self.SoldOut)   --显示售罄标签
        end
    end
end

------显示标签
function tbClass:ShowFlagInfo(nDiscountType, nDiscount, isDiscount)
    if nDiscount and isDiscount then  -- 折扣特惠
        WidgetUtils.HitTestInvisible(self.SpecialTag)
        if nDiscountType == 1 then --折扣
            self.LimitedTimeDiscount = true
            WidgetUtils.HitTestInvisible(self.TagDiscount)
            WidgetUtils.Collapsed(self.TagHot)
            self.TextDiscount2:SetText(string.format(Text("ui.TxtTagDiscount"), TackleDecimal(nDiscount/10)))
        elseif nDiscountType == 2 then  --特惠
            WidgetUtils.HitTestInvisible(self.TagHot)
            WidgetUtils.Collapsed(self.TagDiscount)
        end
    else
        WidgetUtils.Collapsed(self.SpecialTag)
    end
end

--点击商品
function tbClass:DoBtnTips()
    if not self.tbParam then return end
    local bUnlock, tbDes = Condition.Check(self.tbParam.tbCondition)
    if not bUnlock then
        if tbDes and #tbDes >= 1 then
            UI.ShowTip(tbDes[1])
        end
        return
    end

    local nLimitType = self.tbParam.nLimitType
    local nLimitNum = self.tbParam.nLimitNum
    local nBuyNum = 0
    local nStartTime = self.tbParam.nBegin
    local nEndTime = self.tbParam.nEnd
    if self.bMall then
        nLimitNum = self.tbParam.nLimitTimes
        nBuyNum = IBLogic.GetBuyNum(self.tbParam.nGoodsId)
        nStartTime = self.tbParam.nStartTime
        nEndTime = self.tbParam.nEndTime
    else
        nBuyNum = ShopLogic.GetBuyNum(self.tbParam.nGoodsId)
    end

    local bUnlock, tbDes = Condition.Check(self.tbParam.tbCondition)
    if not bUnlock then
        if tbDes and #tbDes >= 1 then
            UI.ShowTip(tbDes[1])
        end
        return
    end

    if not IsInTime(nStartTime, nEndTime) then
        UI.ShowTip("tip.ItemExpirated")
        return
    end

    if nLimitType > 0 and nLimitNum > 0 then
        if nBuyNum >= nLimitNum then
            UI.ShowTip(Text("ui.TxtSellOut"))
            return
        end
    end

    if self.bMall then
        local sUI = UI.GetUI("Mall")
        if sUI then
            sUI:OpenShopTips(self.tbParam)
        end
        return
    end
  
    local sUI = UI.GetUI("Shop")
    if sUI then
        sUI:OpenShopTips(self.tbParam)
    end

    sUI = UI.GetUI("Activity")
    if sUI then
        sUI:OpenShopTips(self.tbParam)
    end

    sUI = UI.GetUI("Dlc1Shop")
    if sUI then
        sUI:OpenShopTips(self.tbParam)
    end
end

--红点
function tbClass:ShowRedDot(tbGoods)
    WidgetUtils.Collapsed(self.Red)
    if not tbGoods then
        return
    end

    if IBLogic.CheckFreeBox(tbGoods) then
        WidgetUtils.HitTestInvisible(self.Red)
    end
end

return tbClass
