-- ========================================================
-- @File    : uw_shop_tips.lua
-- @Brief   : 商品出售确认界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.ListFactory = Model.Use(self);
    self:DoClearListItems(self.DropList)
    self:DoClearListItems(self.List)

    BtnClearEvent(self.BtnClose)
    BtnAddEvent(self.BtnClose, function() self.goodsInfo = nil; WidgetUtils.Collapsed(self) end)

    BtnClearEvent(self.BtnMethod)
    BtnAddEvent(self.BtnMethod, function()
        if not self.goodsInfo then return end
        local tbGDPLN = self.goodsInfo.tbGDPLN
        if self.bMall then
            tbGDPLN = self.goodsInfo.tbItem
        end
        if not tbGDPLN then return end

        if tbGDPLN[1] == Item.TYPE_CARD then
            UI.Open("Role", 3, tbGDPLN)
        elseif tbGDPLN[1] == Item.TYPE_CARD_SKIN then
            local tbParam = {
                CharacterTemplate = {Genre = Item.TYPE_CARD, Detail = tbGDPLN[2], Particular = tbGDPLN[3], Level = 1},
                SkinIndex = tbGDPLN[4],
            }
            UI.Open("RoleFashion", tbParam)
        else
            UI.Open("ItemInfo", tbGDPLN[1], tbGDPLN[2], tbGDPLN[3], tbGDPLN[4])
        end
    end)

    BtnClearEvent(self.BtnPurchase)
    BtnAddEvent(self.BtnPurchase, function()
        self:DoPurchase()
    end)

    self.CheckBtn1.OnCheckStateChanged:Add(self, function(_, bChecked)
        if bChecked then
            if self.Payment == 1 then return end
            self.CheckBtn2:SetIsChecked(false)
            self.Payment = 1
        else
            self.CheckBtn1:SetIsChecked(true)
        end
        self:UpdateTotalPriceShow()
    end)
    self.CheckBtn2.OnCheckStateChanged:Add(self, function(_, bChecked)
        if bChecked then
            if self.Payment == 2 then return end
            self.CheckBtn1:SetIsChecked(false)
            self.Payment = 2
        else
            self.CheckBtn2:SetIsChecked(true)
        end
        self:UpdateTotalPriceShow()
    end)

    self.SlateColor1 = UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 1)
    self.SlateColor2 = UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1)
end

--打开显示 商店打开
function tbClass:Init(tbData)
    self:DoShow(tbData)
end

--打开显示
function tbClass:DoShow(tbData)
    if not tbData then
        return
    end

    if tbData.bMall then
        self.bMall = tbData.bMall
        self.goodsInfo = tbData.tbConfig
        self:ShowMallItem()
    else
        self.goodsInfo = tbData
        self:ShowShopItem()
    end
    self:PlayAnimation(self.AllEnter)
end

--显示商店的 商品详情
function tbClass:ShowShopItem()
    if not self.goodsInfo then return end
    --top
    self:ShowTimeLimit(self.goodsInfo.nEnd)
    self:ShowItemContent(self.goodsInfo.tbGDPLN)

    self.UnitPrice = ShopLogic.GetBuyPrice(self.goodsInfo.nGoodsId, 1)
    self:ShowCurrency(self.UnitPrice, self.goodsInfo.nCalculation)

    --down
    self:ShowTotal(self.UnitPrice, self.goodsInfo.nCalculation)
    self:ShowDropList(self.goodsInfo.tbGDPLN)

    local buyNum = ShopLogic.GetBuyNum(self.goodsInfo.nGoodsId)
    self:ShowPanelNum(buyNum, self.goodsInfo.nLimitNum)
    self:UpdatePrice()
    self:ShowBtn()

    self.maxBuyNum = ShopLogic.GetMaxBuyNum(self.goodsInfo.nGoodsId, self.Payment)
    self.selectNum = 1
end

--显示商城的 商品详情
function tbClass:ShowMallItem()
    if not self.goodsInfo then return end
    --top
    self:ShowTimeLimit(self.goodsInfo.nEndTime)
    self:ShowItemContent(self.goodsInfo.tbItem)

    self.UnitPrice = IBLogic.GetRealPrice(self.goodsInfo)
    if self.UnitPrice then
        self.UnitPrice = {self.UnitPrice}
    end
    self:ShowCurrency()

    --down
    self:ShowTotal(self.UnitPrice)
    self:ShowDropList(self.goodsInfo.tbItem)

    local buyNum = IBLogic.GetBuyNum(self.goodsInfo.nGoodsId)
    self:ShowPanelNum(buyNum, self.goodsInfo.nLimitTimes)
    self:UpdatePrice()
    self:ShowBtn()

    self.maxBuyNum = self.goodsInfo.nLimitTimes and self.goodsInfo.nLimitTimes or 0
    self.selectNum = 1
end

---显示细分
--显示右上角PanelTop
---TimeLimit
function tbClass:ShowTimeLimit(nEndTime)
    if nEndTime and nEndTime > 0 and IsInTime(-1, nEndTime) then
        WidgetUtils.Visible(self.TimeLimit)
        local time = os.date("%Y/%m/%d %H:%M", nEndTime)
        self.TxtTime:SetText(Text("ui.TxtTimeEnd") .. time)
    else
        WidgetUtils.Collapsed(self.TimeLimit)
    end
end

--ItemContent
function tbClass:ShowItemContent(tbGDPLN)
    if not tbGDPLN then
        WidgetUtils.Collapsed(self.PanelPiece)
        self.TxtHoldNum:SetText("")
        return
    end

    ---商品拥有数量
    local haveNum = self:GetNum(tbGDPLN)
    self.TxtHoldNum:SetText(Text("ui.TxtHold") .. Item.ConvertNum(haveNum))

    ---商品信息
    local iteminfo = UE4.UItem.FindTemplate(table.unpack(tbGDPLN, 1, 4))
    if not iteminfo or iteminfo.Genre == 0 then
        WidgetUtils.Collapsed(self.PanelPiece)
        return
    end

    ---图标、名字
    if iteminfo.Genre == Item.TYPE_SUPPLIES and iteminfo.Detail == 4 then
        WidgetUtils.HitTestInvisible(self.PanelPiece)
        SetTexture(self.ImgPiece_1, iteminfo.EXIcon)
        self:ShowShadowHex(iteminfo.Color)
    else
        WidgetUtils.Collapsed(self.PanelPiece)
    end

    if iteminfo.Genre == Item.TYPE_WEAPON then
        WidgetUtils.Collapsed(self.Imgsupport)
        WidgetUtils.Collapsed(self.ImgIcon)
        WidgetUtils.Collapsed(self.PanelFashion)
        WidgetUtils.HitTestInvisible(self.Imgweapon)
        WidgetUtils.HitTestInvisible(self.ImgLv)
        WidgetUtils.HitTestInvisible(self.ImgLv_1)
        SetTexture(self.Imgweapon, iteminfo.Icon)
    elseif iteminfo.Genre == Item.TYPE_SUPPORT then
        WidgetUtils.Collapsed(self.Imgweapon)
        WidgetUtils.Collapsed(self.ImgIcon)
        WidgetUtils.Collapsed(self.PanelFashion)
        WidgetUtils.HitTestInvisible(self.Imgsupport)
        WidgetUtils.HitTestInvisible(self.ImgLv)
        WidgetUtils.HitTestInvisible(self.ImgLv_1)
        SetTexture(self.Imgsupport, iteminfo.Icon)
    elseif iteminfo.Genre == Item.TYPE_CARD_SKIN then
        WidgetUtils.Collapsed(self.Imgweapon)
        WidgetUtils.SelfHitTestInvisible(self.ImgIcon)
        WidgetUtils.Collapsed(self.Imgsupport)
        WidgetUtils.Collapsed(self.PanelFashion)

        WidgetUtils.Collapsed(self.ImgLv)
        WidgetUtils.Collapsed(self.ImgLv_1)

        self.ImgIcon.PaintingType = ""
        SetTexture(self.ImgIcon, iteminfo.Icon)
    else
        WidgetUtils.Collapsed(self.Imgsupport)
        WidgetUtils.Collapsed(self.Imgweapon)
        WidgetUtils.Collapsed(self.PanelFashion)
        WidgetUtils.HitTestInvisible(self.ImgIcon)
        WidgetUtils.HitTestInvisible(self.ImgLv)
        WidgetUtils.HitTestInvisible(self.ImgLv_1)
        SetTexture(self.ImgIcon, iteminfo.Icon)
    end

    if iteminfo.Genre == Item.TYPE_SUPPORT then
        WidgetUtils.SelfHitTestInvisible(self.PanelLogistics)
        local sGDPL = string.format("%s-%s-%s-%s", iteminfo.Genre, iteminfo.Detail, iteminfo.Particular, iteminfo.Level)
        local cfg = Logistics.tbLogiData[sGDPL]
        if cfg and cfg.SuitSkillID then
            local tbSkill = Logistics.tbSkillSuitID[cfg.SuitSkillID]
            if tbSkill and tbSkill.TwoSkillID and #tbSkill.TwoSkillID > 0 then
                self.TeamName:SetText(SkillName(tbSkill.TwoSkillID[1]))
            end
        end
        self.List:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
        self:DoClearListItems(self.List)
        for _, cfg in ipairs(Logistics.GetSuitLogisticsCfg(iteminfo.Particular)) do
            local pObj = self.ListFactory:Create(cfg)
            self.List:AddItem(pObj)
        end
        self.text:SetText("")
    else
        WidgetUtils.Collapsed(self.PanelLogistics)
        ---描述  没有描述显示名字
        if Text(iteminfo.I18N .. "_des") == iteminfo.I18N .. "_des" then
            self.text:SetText(Text(iteminfo.I18N))
        else
            self.text:SetText(Text(iteminfo.I18N .. "_des"))
        end
    end

    SetTexture(self.ImgLv, Item.ItemShopColorIcon[iteminfo.Color])
    SetTexture(self.ImgLv_1, Item.ItemShopChangeColorIcon[iteminfo.Color])
    self.TxtName:SetText(string.format("%sX%d", Text(iteminfo.I18N), tbGDPLN[5] or 1))

    --logo
    if iteminfo.Genre <= Item.TYPE_SUPPORT then--角色 武器 后勤才有logo
        WidgetUtils.HitTestInvisible(self.Logo)
        SetTexture(self.Logo, iteminfo.Icon)
    else
        WidgetUtils.Collapsed(self.Logo)
    end

    --武器类型
    if iteminfo.Genre == Item.TYPE_WEAPON then
        WidgetUtils.HitTestInvisible(self.PanelType)
        SetTexture(self.ImgType, Item.WeaponTypeIcon[iteminfo.Detail])
    else
        WidgetUtils.Collapsed(self.PanelType)
    end
end

--Attribute 已隐藏 未勾选
--Currency {Choice 隐藏  Normal显示}
function tbClass:ShowCurrency(tbPriceInfo, nCalculation)
    WidgetUtils.Collapsed(self.Choice)
    if not tbPriceInfo then
        WidgetUtils.Collapsed(self.Normal)

        WidgetUtils.Collapsed(self.CurrencyOne)
        WidgetUtils.Collapsed(self.CurrencyTwo)
        return
    end

    WidgetUtils.HitTestInvisible(self.Normal)

    local icon1, haveNum1, disPrice1,bReal = self:GetShowCash(tbPriceInfo[1])
    if not tbPriceInfo[2] then
        WidgetUtils.Collapsed(self.CurrencyTwo)
        WidgetUtils.HitTestInvisible(self.CurrencyOne)
        if bReal then
            WidgetUtils.HitTestInvisible(self.TxtMoney)
            WidgetUtils.Collapsed(self.IconCurrency3)

            self.TxtMoney:SetText(icon1)
        else
            WidgetUtils.HitTestInvisible(self.IconCurrency3)
            WidgetUtils.Collapsed(self.TxtMoney)

            SetTexture(self.IconCurrency3, icon1)
        end

        self.TxtNum3:SetText(disPrice1)
        return
    end

    local icon2, haveNum2, disPrice2 = self:GetShowCash(tbPriceInfo[2])
    if nCalculation == 1 then
        WidgetUtils.Collapsed(self.CurrencyTwo)
        WidgetUtils.HitTestInvisible(self.CurrencyOne)
        if self.Payment == 2 then
            SetTexture(self.IconCurrency3, icon2)
            self.TxtNum3:SetText(disPrice2)
        else
            SetTexture(self.IconCurrency3, icon1)
            self.TxtNum3:SetText(disPrice1)
        end
    elseif nCalculation == 2 then
        WidgetUtils.Collapsed(self.CurrencyOne)
        WidgetUtils.HitTestInvisible(self.CurrencyTwo)
        SetTexture(self.IconCurrency4_1, icon1)
        self.TxtNum4_1:SetText(disPrice1)
        SetTexture(self.IconCurrency4_2, icon2)
        self.TxtNum4_2:SetText(disPrice2)
    end
end

--显示PanelFashion
function tbClass:ShowPanelFashion()
end

----显示右下角部分
--TotalChoice TotalCurrency
function tbClass:ShowTotal(tbPriceInfo, nCalculation)
    if not tbPriceInfo then
        WidgetUtils.Collapsed(self.TotalChoice)
        WidgetUtils.Visible(self.TotalCurrency)
        WidgetUtils.Collapsed(self.TotalTwo)
        WidgetUtils.Visible(self.TotalOne)
        WidgetUtils.Collapsed(self.IconTotal1)
        self.TxtNum3:SetText(0)
        return
    end

    local icon1, haveNum1, disPrice1,bReal = self:GetShowCash(tbPriceInfo[1])
    if not tbPriceInfo[2] then
        WidgetUtils.Collapsed(self.TotalChoice)
        WidgetUtils.Visible(self.TotalCurrency)
        WidgetUtils.Collapsed(self.TotalTwo)
        WidgetUtils.Visible(self.TotalOne)

        if bReal then
            WidgetUtils.HitTestInvisible(self.TxtMoney_1)
            WidgetUtils.Collapsed(self.IconTotal1)
            self.TxtMoney_1:SetText(icon1)
        else
            WidgetUtils.HitTestInvisible(self.IconTotal1)
            WidgetUtils.Collapsed(self.TxtMoney_1)

            SetTexture(self.IconTotal1, icon1)
        end

        self.TxtTotalNum1:SetText(disPrice1)
        return
    end

    local icon2, haveNum2, disPrice2 = self:GetShowCash(tbPriceInfo[2])
    if nCalculation == 1 then
        WidgetUtils.Collapsed(self.TotalCurrency)
        WidgetUtils.Visible(self.TotalChoice)
        SetTexture(self.CheckIcon1, icon1)
        SetTexture(self.CheckIcon2, icon2)
        self.CheckNum1:SetText(disPrice1)
        self.CheckNum2:SetText(disPrice2)
        if haveNum1 < disPrice1 and haveNum2 >= disPrice2 then
            self.Payment = 2
            self.CheckBtn1:SetIsChecked(false)
            self.CheckBtn2:SetIsChecked(true)
        else
            self.Payment = 1
            self.CheckBtn1:SetIsChecked(true)
            self.CheckBtn2:SetIsChecked(false)
        end
    elseif nCalculation == 2 then
        WidgetUtils.Collapsed(self.TotalChoice)
        WidgetUtils.Visible(self.TotalCurrency)
        WidgetUtils.Collapsed(self.TotalOne)
        WidgetUtils.Visible(self.TotalTwo)
        SetTexture(self.IconTotal2_1, icon1)
        SetTexture(self.IconTotal2_2, icon2)
        self.TxtTotalNum2_1:SetText(disPrice1)
        self.TxtTotalNum2_2:SetText(disPrice2)
    end
end

--ItemList
function tbClass:ShowDropList(tbGDPLN)
    if not tbGDPLN then 
        WidgetUtils.Collapsed(self.DropList)
        WidgetUtils.Visible(self.Num)
        return
    end

    ---商品信息
    local g,d,p,l = table.unpack(tbGDPLN, 1, 4)
    local iteminfo = UE4.UItem.FindTemplate(g,d,p,l)
    if not iteminfo or iteminfo.Genre == 0 then
        WidgetUtils.Collapsed(self.DropList)
        WidgetUtils.Visible(self.Num)
        return
    end

    if iteminfo.LuaType ~= "itembox" or not iteminfo.Param1 then
        WidgetUtils.Collapsed(self.DropList)
        WidgetUtils.Visible(self.Num)
        return
    end

    WidgetUtils.Collapsed(self.Num)
    WidgetUtils.Visible(self.DropList)
    self:DoClearListItems(self.DropList)
    local tbConfig = Item.tbBox[iteminfo.Param1]
    if not tbConfig then 
        return
    end

    local tbitem = {}
    for _, tbInfo in pairs(tbConfig) do
        for _, info in pairs(tbInfo) do
            for _, item in ipairs(info) do
                table.insert(tbitem, item.tbGDPLN)
            end
        end
    end

    for _, item in ipairs(tbitem) do
        local cfg = {G = item[1], D = item[2], P = item[3], L = item[4], N = item[5] or 1}
        local pObj = self.ListFactory:Create(cfg)
        self.DropList:AddItem(pObj)
    end
end

--Unlock  lock的目前无法点进来
--Num
function tbClass:ShowPanelNum(nBuyNum, nLimitNum)
    nLimitNum = nLimitNum or 0
    --- 限购
    if nLimitNum <= 0 then
        WidgetUtils.Collapsed(self.TxtLimit)
        WidgetUtils.Collapsed(self.TxtLimitNum)
    else
        WidgetUtils.Visible(self.TxtLimit)
        WidgetUtils.Visible(self.TxtLimitNum)
        self.TxtLimitNum:SetText(nLimitNum - nBuyNum .. "/" .. nLimitNum)
    end

    self.maxBuyNum = ShopLogic.GetMaxBuyNum(self.goodsInfo.nGoodsId, self.Payment)
    self.selectNum = 1
end

--btn
function tbClass:ShowBtn()
    self.BtnReduce.OnClicked:Clear()
    self.BtnReduce.OnClicked:Add(self, function()
        if self.selectNum <= 1 then
            UI.ShowMessage("tip.shop_min")
            return
        end
        self.selectNum = self.selectNum - 1
        self:UpdatePrice()
    end)
    self.BtnAdd.OnClicked:Clear()
    self.BtnAdd.OnClicked:Add(self, function()
        if self.selectNum >= ShopLogic.MaxBuyNum then
            UI.ShowMessage(Text("tip.Buy.Restriction", ShopLogic.MaxBuyNum))
            return
        end
        if self.selectNum >= self.maxBuyNum then
            UI.ShowMessage("tip.shop_max")
            return
        end
        self.selectNum = self.selectNum + 1
        self:UpdatePrice()
    end)
    self.BtnMax.OnClicked:Clear()
    self.BtnMax.OnClicked:Add(self, function()
        if self.selectNum == ShopLogic.MaxBuyNum then
            UI.ShowMessage(Text("tip.Buy.Restriction", ShopLogic.MaxBuyNum))
            return
        end
        if self.selectNum >= self.maxBuyNum then
            UI.ShowMessage("tip.shop_max")
            return
        end
        if self.maxBuyNum > ShopLogic.MaxBuyNum then
            UI.ShowMessage(Text("tip.Buy.Restriction", ShopLogic.MaxBuyNum))
            self.selectNum = ShopLogic.MaxBuyNum
        else
            self.selectNum = self.maxBuyNum
        end
        self:UpdatePrice()
    end)
end

---切换购买方式后刷新总价显示
function tbClass:UpdateTotalPriceShow()
    if not self.UnitPrice then
        return
    end

    if not self.UnitPrice[2] or  self.goodsInfo.nCalculation ~= 1 then
        return
    end

    local icon1, haveNum1, disPrice1 = self:GetShowCash(self.UnitPrice[1])
    local totalPrice1 = disPrice1 * self.selectNum
    local money1isenough = haveNum1 >= totalPrice1

    local icon2, haveNum2, disPrice2 = self:GetShowCash(tbPriceInfo[2])
    local totalPrice2 = disPrice2 * self.selectNum
    local money2isenough = haveNum2 >= totalPrice2
    if self.Payment == 2 then
        self.TxtNum3:SetText(totalPrice2)
        self.TxtNum3:SetColorAndOpacity(self:GetColor(money2isenough))

        if icon2 then
            SetTexture(self.IconCurrency3, icon2)
        end
    else
        self.TxtNum3:SetText(totalPrice1)
        self.TxtNum3:SetColorAndOpacity(self:GetColor(money1isenough))

        if icon1 then
            SetTexture(self.IconCurrency3, icon1)
        end
    end
end

--价格相关
function tbClass:UpdatePrice()
    self.TextNum:SetText(self.selectNum)
    if not self.UnitPrice then
        self.TxtTotalNum1:SetText(0)
        self.TxtTotalNum1:SetColorAndOpacity(self:GetColor(true))
        return
    end

    local _, haveNum1, disPrice1 = self:GetShowCash(self.UnitPrice[1])
    local totalPrice1 = disPrice1 * self.selectNum
    local money1isenough = haveNum1 >= totalPrice1
    if not self.UnitPrice[2] then
        self.TxtTotalNum1:SetText(totalPrice1)
        self.TxtTotalNum1:SetColorAndOpacity(self:GetColor(money1isenough))
        self.TxtNum3:SetText(totalPrice1)
        self.TxtNum3:SetColorAndOpacity(self:GetColor(money1isenough))
        return
    end

    local _, haveNum2, disPrice2 = self:GetShowCash(tbPriceInfo[2])
    local totalPrice2 = disPrice2 * self.selectNum
    local money2isenough = haveNum2 >= totalPrice2

    if self.goodsInfo.nCalculation == 1 then
        self.CheckNum1:SetText(totalPrice1)
        self.CheckNum1:SetColorAndOpacity(self:GetColor(money1isenough))
        self.CheckNum2:SetText(totalPrice2)
        self.CheckNum2:SetColorAndOpacity(self:GetColor(money2isenough))
    elseif self.goodsInfo.nCalculation == 2 then
        self.TxtTotalNum2_1:SetText(totalPrice1)
        self.TxtTotalNum2_2:SetText(totalPrice2)
        self.TxtTotalNum2_1:SetColorAndOpacity(self:GetColor(money1isenough))
        self.TxtTotalNum2_2:SetColorAndOpacity(self:GetColor(money2isenough))
    end

    if self.goodsInfo.nCalculation == 1 then
        if self.Payment == 2 then
            self.TxtNum3:SetText(totalPrice2)
            self.TxtNum3:SetColorAndOpacity(self:GetColor(money2isenough))
        else
            self.TxtNum3:SetText(totalPrice1)
            self.TxtNum3:SetColorAndOpacity(self:GetColor(money1isenough))
        end
    elseif self.goodsInfo.nCalculation == 2 then
        self.TxtNum4_1:SetText(totalPrice1)
        self.TxtNum4_2:SetText(totalPrice2)
        self.TxtNum4_1:SetColorAndOpacity(self:GetColor(money1isenough))
        self.TxtNum4_2:SetColorAndOpacity(self:GetColor(money2isenough))
    end
end

--刷新
function tbClass:Refresh()
    if self.bMall then
        self:ShowMallItem()
    else
        self:ShowShopItem()
    end
end

--获取拥有数量
function tbClass:GetNum(tbGDPLN)
    local nHaveNum = 0
    if not tbGDPLN then return nHaveNum end

    local g,d,p,l = table.unpack(tbGDPLN, 1, 4)
    if g == 4 and d == 3 and p == 1 and l == 1 then --通用银
        nHaveNum = Cash.GetMoneyCount(Cash.MoneyType_Silver)
    elseif g == 4 and d == 3 and p == 2 and l == 1 then --数据金
        nHaveNum = Cash.GetMoneyCount(Cash.MoneyType_Gold)
    else
        nHaveNum = me:GetItemCount(g,d,p,l)
    end
    return nHaveNum
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

--颜色
function tbClass:GetColor(isenough)
    if isenough then
        return self.SlateColor1
    else
        return self.SlateColor2
    end
end

---价格检查
function tbClass:CheckPrice()
    local priceInfo = nil
    if self.bMall then
        priceInfo = IBLogic.GetRealPrice(self.goodsInfo)
        if priceInfo then
            priceInfo = {priceInfo}
        end
    else
        priceInfo = ShopLogic.GetBuyPrice(self.goodsInfo.nGoodsId, self.selectNum)
    end
    if not priceInfo then return true end

    if self.goodsInfo.nCalculation == 1 then
        if self.Payment and self.Payment == 2 then  --选择消耗代币二
            table.remove(priceInfo, 1)
        else    --选择消耗代币一
            table.remove(priceInfo, 2)
        end
    end

    for _, v in pairs(priceInfo) do
        local havenum = 0
        local disPrice = v[#v]
        if #v >= 5 then
            havenum = me:GetItemCount(v[1], v[2], v[3], v[4])
        else
            if v[1] == Cash.MoneyType_RMB then
                return true
            end

            havenum = Cash.GetMoneyCount(v[1])
        end
        if havenum < disPrice then
            Audio.PlayVoices("NoMoney")
            return false, v[1], v[2]
        end
    end
    return true
end

---拥有数量检查
function tbClass:CheckHaveNum()
    local nLimitHaveNum = 0
    if self.bMall then
        nLimitHaveNum = IBLogic.GetLimitHaveNum(self.goodsInfo)
    else
        nLimitHaveNum = self.goodsInfo.nLimitHaveNum
    end

    if nLimitHaveNum and nLimitHaveNum > 0 then
        if self:GetNum(self.goodsInfo) >= nLimitHaveNum then
            return false, string.format(Text("ui.Max_Limit_Have"), nLimitHaveNum)
        end
    end
    return true
end

function tbClass:ShowShadowHex(InColor)
    local  HexColor = Color.tbShadowHex[InColor]
    self.ImgPieceQuality:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(HexColor.R,HexColor.G,HexColor.B,HexColor.A))
end

--购买
function tbClass:DoPurchase()
     if not self.goodsInfo then return end

    if self.selectNum <= 0 then
        return
    end

    local bUnlock, tbDes = Condition.Check(self.goodsInfo.tbCondition)
    if not bUnlock then
        if tbDes and #tbDes >= 1 then
            UI.ShowTip(tbDes[1])
        end
        return
    end

    local nStartTime = self.goodsInfo.nBegin
    local nEndTime = self.goodsInfo.nEnd
    if self.bMall then
        nStartTime = self.goodsInfo.nStartTime
        nEndTime = self.goodsInfo.nEndTime
    end

    if not IsInTime(nStartTime, nEndTime) then
        UI.ShowTip("tip.ItemExpirated")
        return
    end

    local ok, str = self:CheckHaveNum()
    if not ok then
        return UI.ShowMessage(str)
    end

    local isok, id, num = self:CheckPrice()
    if isok then
        if self.goodsInfo.nAddiction > 0 then
            UI.Open("MessageBox", Text("ui.WarningTips"),
                function()
                    self:DoRealBuy()
                end
            )
        else
            self:DoRealBuy()
        end
        return
    end

    -- 屏蔽数据金的兑换弹窗
    if id == Cash.MoneyType_Gold then   --兑换
        UI.ShowMessage("tip.gold_not_enough")
        -- UI.Open("MessageBox", string.format(Text("tip.exchange_jump_mall"), Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Gold).sName)),
        --     function() --跳转数据金商店
        --         CashExchange.ShowUIExchange(Cash.MoneyType_Gold)
        --     end
        -- )
    elseif id == Cash.MoneyType_Money then   --前往商店比特金购买界面
        UI.Open("MessageBox", string.format(Text("tip.exchange_jump_shop"), Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Money).sName)),
            function() --跳转比特金商店
                CashExchange.ShowUIExchange(Cash.MoneyType_Money)
            end
        )
    else
        UI.ShowMessage("tip.gold_not_enough")
    end
end

--根据
function tbClass:DoRealBuy()
    if self.bMall then
        if IBLogic.CheckProductSellOut(self.goodsInfo.nGoodsId) then 
            UI.ShowTip("tip.Mall_Limit_Buy")
            return 
        end

        IBLogic.DoBuyProduct(self.goodsInfo.nType, self.goodsInfo.nGoodsId)
        return
    end

    ShopLogic.BuyGoods(self.goodsInfo.nGoodsId, self.Payment, self.selectNum)
end

return tbClass;