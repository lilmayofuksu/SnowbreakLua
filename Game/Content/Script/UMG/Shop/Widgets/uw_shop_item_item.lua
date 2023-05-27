-- ========================================================
-- @File    : uw_shop_item_item.lua
-- @Brief   : 商店界面-商品
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.ButtonTips, function()
        if not self.tbParam then return end

        --如果是时装,进入对应界面再购买
        if self.tbParam.tbGDPLN[1] == 7 then
            local tbParam = {
                CharacterTemplate = {Genre = 1, Detail = self.tbParam.tbGDPLN[2], Particular = self.tbParam.tbGDPLN[3], Level = 1},
                SkinIndex = self.tbParam.tbGDPLN[4],
            }
            UI.Open("RoleFashion", tbParam)
            return
        elseif self.tbParam.tbGDPLN[1] == Item.TYPE_SUPPLIES and self.tbParam.tbGDPLN[2] == 4 and ShopLogic.GetFragmentLimit(self.tbParam.nShopId) then
            ---如果是SSR角色碎片 判断是否拥有角色
            local CardInfo, CardGDPL = Item.Piece2Character(self.tbParam.tbGDPLN[1], self.tbParam.tbGDPLN[2], self.tbParam.tbGDPLN[3], self.tbParam.tbGDPLN[4])
            if CardInfo and CardInfo.Color==5 and CardGDPL then
                local Card = RoleCard.GetItem(CardGDPL)
                if not Card then
                    UI.ShowTip("tip.shop.RoleLocked")
                    return
                end
                if RBreak.IsLimit(Card) then
                    UI.ShowTip("tip.shop.RoleFull")
                    return
                end
            end
        end
        if self.tbParam.nLimitType > 0 and self.tbParam.nLimitNum ~= -1 then
            if ShopLogic.GetBuyNum(self.tbParam.nGoodsId) >= self.tbParam.nLimitNum then
                UI.ShowTip(Text("ui.TxtSellOut"))
                return
            end
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
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data

    --限购
    local buyNum = ShopLogic.GetBuyNum(self.tbParam.nGoodsId)
    if self.tbParam.nLimitNum < 0 then
        WidgetUtils.Collapsed(self.LimitNum)
    else
        WidgetUtils.Visible(self.LimitNum)
        if self.TxtLimitNum then
            self.TxtLimitNum:SetText(self.tbParam.nLimitNum - buyNum .. "/" .. self.tbParam.nLimitNum)
            if self.tbParam.nLimitNum - buyNum == 0 then
                self.TxtLimitNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1))
            else
                self.TxtLimitNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0.005605, 0.005605, 0.0185, 1))
            end
        end
    end

    --图标、名字
    local iteminfo = UE4.UItem.FindTemplate(self.tbParam.tbGDPLN[1], self.tbParam.tbGDPLN[2], self.tbParam.tbGDPLN[3], self.tbParam.tbGDPLN[4])
    if iteminfo then
        self.TxtName:SetText(Text(iteminfo.I18N))

        if iteminfo.Genre == 2 then --武器类
            WidgetUtils.Collapsed(self.Icon)
            WidgetUtils.HitTestInvisible(self.WeaponMask)
            SetTexture(self.Imgweapon2, iteminfo.Icon)
        else    --其他类
            WidgetUtils.Collapsed(self.WeaponMask)
            WidgetUtils.HitTestInvisible(self.Icon)
            SetTexture(self.Icon, iteminfo.Icon)
        end

        if iteminfo.Genre == 2 then --武器类
            WidgetUtils.HitTestInvisible(self.PanelType)
            WidgetUtils.HitTestInvisible(self.ImgType)
            WidgetUtils.Collapsed(self.ImgTypeLogistics)
            SetTexture(self.ImgType, Item.WeaponTypeIcon[iteminfo.Detail])
        elseif iteminfo.Genre == 3 then --后勤类
            WidgetUtils.HitTestInvisible(self.PanelType)
            WidgetUtils.HitTestInvisible(self.ImgTypeLogistics)
            WidgetUtils.Collapsed(self.ImgType)
            SetTexture(self.ImgTypeLogistics, Item.SupportTypeIcon[iteminfo.Detail])
        else
            WidgetUtils.Collapsed(self.PanelType)
        end

        if iteminfo.Genre == 7 then
            local CardInfo = UE4.UItem.FindTemplate(1, self.tbParam.tbGDPLN[2], self.tbParam.tbGDPLN[3], 1)
            if CardInfo and self.TxtName_1 then
                self.TxtName_1:SetText(Text(CardInfo.I18N))
            end
        end

        --角色碎片
        WidgetUtils.Collapsed(self.RoleExceed)
        if iteminfo.Genre == Item.TYPE_SUPPLIES and iteminfo.Detail == 4 then
            WidgetUtils.HitTestInvisible(self.PanelPiece)
            SetTexture(self.ImgPiece, iteminfo.EXIcon)
            self:ShowShadowHex(iteminfo.Color)

            if ShopLogic.GetFragmentLimit(self.tbParam.nShopId) then
                local CardInfo, CardGDPL = Item.Piece2Character(iteminfo.Genre, iteminfo.Detail, iteminfo.Particular, iteminfo.Level)
                if CardInfo and CardInfo.Color==5 and CardGDPL then
                    local Card = RoleCard.GetItem(CardGDPL)
                    if not Card then
                        WidgetUtils.HitTestInvisible(self.RoleExceed)
                        self.TxtExceed:SetText("shop.RoleLocked")
                    elseif RBreak.IsLimit(Card) then
                        WidgetUtils.HitTestInvisible(self.RoleExceed)
                        self.TxtExceed:SetText("shop.RoleFull")
                    end
                end
            end
        else
            WidgetUtils.Collapsed(self.PanelPiece)
        end

        --品质条
        SetTexture(self.Rarity, Item.ItemShopColorIcon[iteminfo.Color])
        SetTexture(self.Rarity2, Item.ItemShopColorIcon2[iteminfo.Color])

        --Logo
        if iteminfo.Genre >= 1 and iteminfo.Genre <= 3 then
            WidgetUtils.HitTestInvisible(self.Logo)
            SetTexture(self.Logo, iteminfo.Icon)
        else
            WidgetUtils.Collapsed(self.Logo)
        end
    end
    if self.TxtNum then
        self.TxtNum:SetText("X" .. (self.tbParam.tbGDPLN[5] or 1))
    end

    --价格
    local isDiscount = false  --是否有优惠
    local priceInfo = ShopLogic.GetBuyPrice(self.tbParam.nGoodsId, 1)
    if priceInfo then
        local nPrePrice1 = self.tbParam.tbPrice1[#self.tbParam.tbPrice1]
        local nPrePrice2 = 0
        if self.tbParam.tbPrice2 then
            nPrePrice2 = self.tbParam.tbPrice2[#self.tbParam.tbPrice2]
        end
        local icon1 = nil
        local havenum1 = 0
        local disPrice1 = priceInfo[1][#priceInfo[1]]
        if #priceInfo[1] >= 5 then
            local temp = UE4.UItem.FindTemplate(priceInfo[1][1], priceInfo[1][2], priceInfo[1][3], priceInfo[1][4])
            icon1 = temp.Icon
            havenum1 = me:GetItemCount(priceInfo[1][1], priceInfo[1][2], priceInfo[1][3], priceInfo[1][4])
        else
            icon1, _, havenum1 = Cash.GetMoneyInfo(priceInfo[1][1])
        end
        if self.tbParam.nCalculation == 1 and priceInfo[2] then -- 代币二选一
            WidgetUtils.Collapsed(self.Normal)
            WidgetUtils.Visible(self.Choice)
            local icon2 = nil
            local havenum2 = 0
            local disPrice2 = priceInfo[2][#priceInfo[2]]
            if #priceInfo[2] >= 5 then
                local temp = UE4.UItem.FindTemplate(priceInfo[2][1], priceInfo[2][2], priceInfo[2][3], priceInfo[2][4])
                icon2 = temp.Icon
                havenum2 = me:GetItemCount(priceInfo[2][1], priceInfo[2][2], priceInfo[2][3], priceInfo[2][4])
            else
                icon2, _, havenum2 = Cash.GetMoneyInfo(priceInfo[1][1])
            end
            SetTexture(self.IconCurrency1, icon1)
            SetTexture(self.IconCurrency2, icon2)
            self.TxtNum1:SetText(disPrice1)
            self.TxtNum2:SetText(disPrice2)
            if disPrice1 < nPrePrice1 then
                isDiscount = true
                WidgetUtils.Visible(self.Discount1)
                self.PreNum1:SetText(nPrePrice1)
            else
                WidgetUtils.Collapsed(self.Discount1)
            end
            if disPrice2 < nPrePrice2 then
                isDiscount = true
                WidgetUtils.Visible(self.Discount2)
                self.PreNum2:SetText(nPrePrice2)
            else
                WidgetUtils.Collapsed(self.Discount2)
            end
            if havenum1 < disPrice1 then --代币1不足
                self.TxtNum1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1))
                self.PreNum1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 0.6))
                self.Line2:SetColorAndOpacity(UE4.FLinearColor(1, 0, 0, 0.6))
            else
                self.TxtNum1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
                self.PreNum1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 0.6))
                self.Line2:SetColorAndOpacity(UE4.FLinearColor(0, 0, 0, 0.6))
            end
            if havenum2 < disPrice2 then --代币2不足
                self.TxtNum2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1))
                self.PreNum2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 0.6))
                self.Line2_1:SetColorAndOpacity(UE4.FLinearColor(1, 0, 0, 0.6))
            else
                self.TxtNum2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
                self.PreNum2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 0.6))
                self.Line2_1:SetColorAndOpacity(UE4.FLinearColor(0, 0, 0, 0.6))
            end
        else
            WidgetUtils.Collapsed(self.Choice)
            WidgetUtils.Visible(self.Normal)
            if self.tbParam.nCalculation == 2 and priceInfo[2] then -- 消耗两种代币
                local icon2 = nil
                local havenum2 = 0
                local disPrice2 = priceInfo[2][#priceInfo[2]]
                if #priceInfo[2] >= 5 then
                    local temp = UE4.UItem.FindTemplate(priceInfo[2][1], priceInfo[2][2], priceInfo[2][3], priceInfo[2][4])
                    icon2 = temp.Icon
                    havenum2 = me:GetItemCount(priceInfo[2][1], priceInfo[2][2], priceInfo[2][3], priceInfo[2][4])
                else
                    icon2, _, havenum2 = Cash.GetMoneyInfo(priceInfo[1][1])
                end
                WidgetUtils.Collapsed(self.CurrencyOne)
                WidgetUtils.Visible(self.CurrencyTwo)
                SetTexture(self.IconCurrency1_2, icon1)
                SetTexture(self.IconCurrency1_3, icon2)
                self.TxtNum1_2:SetText(disPrice1)
                self.TxtNum1_3:SetText(disPrice2)
                if disPrice1 < nPrePrice1 then
                    isDiscount = true
                    WidgetUtils.Visible(self.Two_1)
                    self.PreNum1_3:SetText(nPrePrice1)
                else
                    WidgetUtils.Collapsed(self.Two_1)
                end
                if disPrice2 < nPrePrice2 then
                    isDiscount = true
                    WidgetUtils.Visible(self.Two_2)
                    self.PreNum1_2:SetText(nPrePrice2)
                else
                    WidgetUtils.Collapsed(self.Two_2)
                end
                if havenum1 < disPrice1 then --代币1不足
                    self.TxtNum1_2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1))
                    self.PreNum1_3:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 0.6))
                    self.Line2_3:SetColorAndOpacity(UE4.FLinearColor(1, 0, 0, 0.6))
                else
                    self.TxtNum1_2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
                    self.PreNum1_3:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 0.6))
                    self.Line2_3:SetColorAndOpacity(UE4.FLinearColor(0, 0, 0, 0.6))
                end
                if havenum2 < disPrice2 then --代币2不足
                    self.TxtNum1_3:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1))
                    self.PreNum1_2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 0.6))
                    self.Line2_2:SetColorAndOpacity(UE4.FLinearColor(1, 0, 0, 0.6))
                else
                    self.TxtNum1_3:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
                    self.PreNum1_2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 0.6))
                    self.Line2_2:SetColorAndOpacity(UE4.FLinearColor(0, 0, 0, 0.6))
                end
            else    --消耗代币一
                WidgetUtils.Collapsed(self.CurrencyTwo)
                WidgetUtils.Visible(self.CurrencyOne)
                WidgetUtils.HitTestInvisible(self.IconCurrency1_1)
                SetTexture(self.IconCurrency1_1, icon1)
                self.TxtNum1_1:SetText(disPrice1)
                if iteminfo.Genre == 7 then
                    self.TxtNum1:SetText(disPrice1)
                end
                if disPrice1 < nPrePrice1 then
                    isDiscount = true
                    WidgetUtils.Visible(self.Discount1_1)
                    self.PreNum1_1:SetText(nPrePrice1)
                    if iteminfo.Genre == 7 then
                        self.PreNum1:SetText(nPrePrice1)
                    end
                else
                    WidgetUtils.Collapsed(self.Discount1_1)
                end
                if havenum1 < disPrice1 then --代币1不足
                    if iteminfo.Genre == 7 then
                        self.TxtNum1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1))
                        self.TxtNum1_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1))
                        self.PreNum1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 0.6))
                        self.Line2:SetColorAndOpacity(UE4.FLinearColor(1, 0, 0, 0.6))
                    else
                        self.TxtNum1_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1))
                        self.PreNum1_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 0.6))
                        self.Line2_5:SetColorAndOpacity(UE4.FLinearColor(1, 0, 0, 0.6))
                    end
                else
                    if iteminfo.Genre == 7 then
                        self.TxtNum1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
                        self.PreNum1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 0.6))
                        self.Line2:SetColorAndOpacity(UE4.FLinearColor(0, 0, 0, 0.6))
                    else
                        self.TxtNum1_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
                        self.PreNum1_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 0.6))
                        self.Line2_5:SetColorAndOpacity(UE4.FLinearColor(0, 0, 0, 0.6))
                    end
                end
            end
        end
    else    ---免费
        WidgetUtils.Collapsed(self.Choice)
        WidgetUtils.Visible(self.Normal)
        WidgetUtils.Collapsed(self.CurrencyTwo)
        WidgetUtils.Visible(self.CurrencyOne)
        WidgetUtils.Collapsed(self.Discount1_1)
        WidgetUtils.Collapsed(self.IconCurrency1_1)
        self.TxtNum1_1:SetText(Text("ui.TxtFree"))
        self.TxtNum1_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
    end

    --标签信息
    local _, discount = ShopLogic.GetOnLineGoodsInfo(self.tbParam.nGoodsId)
    if self.tbParam.nLimitType > 0 and self.tbParam.nLimitNum ~= -1 and buyNum >= self.tbParam.nLimitNum then   --售罄
        WidgetUtils.Visible(self.SoldOut)
    elseif iteminfo.Genre == 7 and Fashion.CheckSkinItem(self.tbParam.tbGDPLN) then --时装道具只能拥有一个
        WidgetUtils.Visible(self.SoldOut)
    else
        WidgetUtils.Collapsed(self.SoldOut)
    end
    if discount and discount > 0 and self.tbParam.tbDiscount and self.tbParam.tbDiscount[discount] and isDiscount then  -- 折扣特惠
        WidgetUtils.Visible(self.SpecialTag)
        local discountinfo = self.tbParam.tbDiscount[discount]
        if self.tbParam.nDiscountType == 1 then --折扣
            self.LimitedTimeDiscount = true
            WidgetUtils.Visible(self.TagDiscount)
            WidgetUtils.Collapsed(self.TagHot)
            if iteminfo.Genre == 7 then
                WidgetUtils.SelfHitTestInvisible(self.Price)
                WidgetUtils.Collapsed(self.CurrencyOne)
            end
            self.TextDiscount2:SetText(string.format(Text("ui.TxtTagDiscount"), TackleDecimal(discountinfo[2]/10)))
        elseif self.tbParam.nDiscountType == 2 then  --特惠
            WidgetUtils.Visible(self.TagHot)
            WidgetUtils.Collapsed(self.TagDiscount)
        end
    else
        WidgetUtils.Collapsed(self.SpecialTag)
    end
    if self.tbParam.nEnd > 0 then  --限时
        --如果是限时折扣
        if self.TextTimeLimitType then
            if self.LimitedTimeDiscount then
                self.TextTimeLimitType:SetText(Text("ui.TxtFashionTip2"))
            else
                self.TextTimeLimitType:SetText(Text("ui.TxtFashionTip1"))
            end
        end

        local seconds = math.ceil(self.tbParam.nEnd - GetTime())
        if seconds > 0 then
            WidgetUtils.Visible(self.LimitTime)
            local hour = math.floor(seconds / 3600)
            if hour >= 24 then  --天
                self.TxtCompany:SetText(string.format(Text("ui.TxtDungeonsTowerTime0"), math.ceil(hour / 24)))
            else  --小时:分钟
                local min = math.ceil((seconds % 3600) / 60)
                local second = seconds % 60
                self.TxtCompany:SetText(string.format("%02d:%02d:%02d", hour, min, second))
            end
        else
            WidgetUtils.Collapsed(self.LimitTime)
        end
    else
        WidgetUtils.Collapsed(self.LimitTime)
    end
end


function tbClass:Tick(MyGeometry, InDeltaTime)
    if self.tbParam.nEnd <= 0 then return end

    if not self.detime then self.detime = 0 end
    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end
    self.detime = 0

    local seconds = math.ceil(self.tbParam.nEnd - GetTime())
    if seconds > 0 then
        local hour = math.floor(seconds / 3600)
        if hour >= 24 then  --天
            self.TxtCompany:SetText(string.format(Text("ui.TxtDungeonsTowerTime0"), math.ceil(hour / 24)))
        else  --小时:分钟
            local min = math.ceil((seconds % 3600) / 60)
            local second = seconds % 60
            self.TxtCompany:SetText(string.format("%02d:%02d:%02d", hour, min, second))
        end
    else
        if self.tbParam.nDiscountType > 0 and self.tbParam.tbDiscount then
            local _, discount = ShopLogic.GetOnLineGoodsInfo(self.tbParam.nGoodsId)
            if discount > 0 then    --折扣过期需要刷新
                ShopLogic.GetGoodsList(self.tbParam.nShopId)
            end
        else    --商品过期需要刷新
            ShopLogic.GetGoodsList(self.tbParam.nShopId)
        end
    end
end

function tbClass:ShowShadowHex(InColor)
    local  HexColor = Color.tbShadowHex[InColor]
    self.ImgPieceQuality:SetColorAndOpacity(UE4.FLinearColor(HexColor.R,HexColor.G,HexColor.B,HexColor.A))

end

return tbClass
