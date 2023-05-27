-- ========================================================
-- @File    : uw_mall_tips.lua
-- @Brief   : 商城商品出售确认界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.ListFactory = Model.Use(self);

    BtnClearEvent(self.BtnClose)
    BtnAddEvent(self.BtnClose, function() self.tbGoodsInfo = nil; WidgetUtils.Collapsed(self) end)

    BtnClearEvent(self.BtnPurchase)
    BtnAddEvent(self.BtnPurchase, function()
        self:DoPurchase()
    end)

    BtnClearEvent(self.BtnRules)
    BtnAddEvent(self.BtnRules, function()
        self:DoShowRules(not self.bShowRules)
    end)
end

--打开显示
function tbClass:OnOpen(tbData)
    if not tbData then
        return
    end

    self.tbGoodsInfo = tbData.tbConfig
    self:ShowLeft()
    self:ShowRight()
    self:PlayAnimation(self.AllEnter)
end

--显示左边信息
function tbClass:ShowLeft()
    if not self.tbGoodsInfo then
        WidgetUtils.Collapsed(self.Left)
        return
    end

    self:ShowLimitInfo()
    self:ShowOffFlag()

    local iteminfo = UE4.UItem.FindTemplate(table.unpack(self.tbGoodsInfo.tbItem, 1, 4))
    if not iteminfo or iteminfo.Genre == 0 then
        WidgetUtils.Collapsed(self.GiftIcon)
    else
        SetTexture(self.GiftIcon, iteminfo.Icon)
    end
end

--显示限购信息
function tbClass:ShowLimitInfo()
    if not self.tbGoodsInfo then 
        WidgetUtils.Collapsed(self.HorizontalBox_836)
        WidgetUtils.Collapsed(self.BgLimit)
        return 
    end

    if self.tbGoodsInfo.nLimitTimes and self.tbGoodsInfo.nLimitTimes == 0 then
        WidgetUtils.Collapsed(self.HorizontalBox_836)
        WidgetUtils.Collapsed(self.BgLimit)
        return
    end

    WidgetUtils.HitTestInvisible(self.HorizontalBox_836)
    WidgetUtils.HitTestInvisible(self.BgLimit)

    if self.tbGoodsInfo.nLimitType == 1 then
        self.TxtLimit:SetText(Text("ui.TxtLimitToday"))
    elseif self.tbGoodsInfo.nLimitType == 2 then
        self.TxtLimit:SetText(Text("ui.TxtLimitWeek"))
    elseif self.tbGoodsInfo.nLimitType == 3 then
        self.TxtLimit:SetText(Text("ui.TxtLimitMonth"))
    else
        self.TxtLimit:SetText(Text("ui.TxtLimitBuy"))
    end

    self.maxBuyNum = self.tbGoodsInfo.nLimitTimes
    local buyNum = IBLogic.GetBuyNum(self.tbGoodsInfo.nGoodsId)
    if buyNum > self.maxBuyNum then
        buyNum = self.maxBuyNum
    end

    self.Num1:SetText(self.maxBuyNum - buyNum)
    self.Num2:SetText(self.maxBuyNum)
end

--显示打折标签
function tbClass:ShowOffFlag()
    if not self.tbGoodsInfo then 
        WidgetUtils.Collapsed(self.TagSale)
        return 
    end

    if self.tbGoodsInfo.nOffRate <= 0 or not self.tbGoodsInfo.tbCost or #self.tbGoodsInfo.tbCost < 2 then
        WidgetUtils.Collapsed(self.TagSale)
        return
    end

    if not IsInTime(self.tbGoodsInfo.nOffStartTime, self.tbGoodsInfo.nOffEndTime) then
        WidgetUtils.Collapsed(self.TagSale)
        return
    end

    WidgetUtils.HitTestInvisible(self.TagSale)
    self.Percent:SetText(string.format("-%d%%", self.tbGoodsInfo.nOffRate))
end

--显示右边部分
function tbClass:ShowRight()
    if not self.tbGoodsInfo then 
        WidgetUtils.Collapsed(self.Right)
        return 
    end

    local iteminfo = UE4.UItem.FindTemplate(table.unpack(self.tbGoodsInfo.tbItem, 1, 4))
    if not iteminfo or iteminfo.Genre == 0 then
        WidgetUtils.Collapsed(self.GiftIcon)
        self.BoxName:SetText("")
    else
        SetTexture(self.GiftIcon, iteminfo.Icon)
        self.BoxName:SetText(Text(iteminfo.I18N))
    end

    --价格
    self:ShowMoney()
    --显示规则
    self:DoShowRules(false, iteminfo)
end

--显示规则
function tbClass:DoShowRules(bShow, iteminfo)
    if not iteminfo then
        iteminfo = UE4.UItem.FindTemplate(table.unpack(self.tbGoodsInfo.tbItem, 1, 4))
    end

    if bShow then
        WidgetUtils.HitTestInvisible(self.Rules)
        self.TxtRule:SetText(Text(iteminfo.I18N .. "_des"))
        self.bShowRules = true
        self:ShowRewards(nil)
        self:ShowDailyRewards(nil)
        WidgetUtils.Visible(self.BtnRules)
        return
    end

    --立即获得
    local bRet = self:ShowRewards(iteminfo)
    --每日获得
    local bRet1 = self:ShowDailyRewards(iteminfo)
    --规则
    if iteminfo and not bRet and not bRet1 then
        WidgetUtils.Visible(self.BtnRules)
        WidgetUtils.HitTestInvisible(self.Rules)
        self.TxtRule:SetText(Text(iteminfo.I18N .. "_des"))
        self.bShowRules = true
    else
        WidgetUtils.Collapsed(self.Rules)
        self.bShowRules = false
    end
end

function tbClass:ShowRewards(iteminfo)
    if not iteminfo or iteminfo.Genre == 0 then
        WidgetUtils.Collapsed(self.Rewards)
        return
    end

    if iteminfo.LuaType ~= "itembox" and iteminfo.LuaType ~= "cyclegift_box" then
        WidgetUtils.Collapsed(self.Rewards)
        return
    end

    if not iteminfo.Param1 then
        WidgetUtils.Collapsed(self.Rewards)
        return
    end

    local tbRewards = self:GetAllItemList(iteminfo)
    if not tbRewards or #tbRewards == 0 then
        WidgetUtils.Collapsed(self.Rewards)
        return
    end

    WidgetUtils.HitTestInvisible(self.Rewards)

    self.Rewards:OnOpen(tbRewards, "ui.TxtMallGift1")
    return true
end

function tbClass:ShowDailyRewards(iteminfo)
    WidgetUtils.Collapsed(self.BtnRules)
    if not iteminfo or iteminfo.Genre == 0 then
        WidgetUtils.Collapsed(self.DailyRewards)
        return
    end

    if not iteminfo.Param1 then
        WidgetUtils.Collapsed(self.DailyRewards)
        return
    end

    if iteminfo.LuaType ~= "itembox" and iteminfo.LuaType ~= "cyclegift_box" then
        WidgetUtils.Collapsed(self.DailyRewards)
        return
    end

    local _,tbRewards = self:GetAllItemList(iteminfo)
    if not tbRewards or #tbRewards == 0 then
        WidgetUtils.Collapsed(self.DailyRewards)
        return
    end

    WidgetUtils.HitTestInvisible(self.DailyRewards)
    WidgetUtils.Visible(self.BtnRules)

    self.DailyRewards:OnOpen(tbRewards, "ui.TxtMallGift2")
    return true
end

--获取物品列表
function tbClass:GetAllItemList(tbData)
    if not tbData then return end

    if tbData.LuaType == "cyclegift_box" and tbData.Param1 then
        return CycleGiftLogic:GetCycleItemList(tbData)
    end

    if tbData.LuaType ~= "itembox" or not tbData.Param1 then
        return
    end

    local tbConfig = Item.tbBox[tbData.Param1]
    if not tbConfig then 
        return
    end

    local tbItem = {}
    local tbRetDaily = {}
    for _, tbInfo in pairs(tbConfig) do
        for _, info in pairs(tbInfo) do
            for _, item in ipairs(info) do
                local tbItemInfo = UE4.UItem.FindTemplate(item.tbGDPLN[1], item.tbGDPLN[2], item.tbGDPLN[3], item.tbGDPLN[4])
                if tbItemInfo and tbItemInfo.LuaType == "cyclegift_box" and tbItemInfo.Param1 then
                    local tbNowList,tbDailyList  = CycleGiftLogic:GetCycleItemList(tbItemInfo)
                    if tbNowList and #tbNowList > 0 then
                        for i,v in ipairs(tbNowList) do
                            table.insert(tbItem, v)
                        end
                    end

                    if tbDailyList and #tbDailyList > 0 then
                        for i,v in ipairs(tbDailyList) do
                            table.insert(tbRetDaily, v)
                        end
                    end
                else
                    table.insert(tbItem, item.tbGDPLN)
                end
            end
        end
    end
    return tbItem, tbRetDaily
end

--显示价格
function tbClass:ShowMoney()
    if not self.tbGoodsInfo then return end

    local tbColor = {0.96, 0.87, 0.7, 1}
    local priceInfo = IBLogic.GetRealPrice(self.tbGoodsInfo)
    if not priceInfo then --免费?
        WidgetUtils.Collapsed(self.Symbol)
        WidgetUtils.Collapsed(self.IconCurrency)
        self.Num:SetText(Text("ui.TxtFree"))
        self.Num:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(table.unpack(tbColor)))
        return false
    end

    local nPrePrice1 = 0
    if self.tbGoodsInfo.tbCost and #self.tbGoodsInfo.tbCost > 0 then
        nPrePrice1 = self.tbGoodsInfo.tbCost[#self.tbGoodsInfo.tbCost]
    end

    local icon1, haveNum1, disPrice1, bReal = self:GetShowCash(priceInfo)

    if haveNum1 < disPrice1 then --代币1不足
        tbColor = {1, 0, 0, 1}
    end

    if bReal then
        WidgetUtils.SelfHitTestInvisible(self.Symbol)
        WidgetUtils.Collapsed(self.IconCurrency)
        self.Symbol:SetText(icon1)
    else
        WidgetUtils.SelfHitTestInvisible(self.IconCurrency)
        WidgetUtils.Collapsed(self.Symbol)
        SetTexture(self.IconCurrency, icon1)
    end
    self.Num:SetText(NumberToString(disPrice1))
    self.Num:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(table.unpack(tbColor)))
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

---价格检查
function tbClass:CheckPrice()
    local priceInfo = IBLogic.GetRealPrice(self.tbGoodsInfo)
    if priceInfo then
        priceInfo = {priceInfo}
    end

    if not priceInfo then return true end

    if self.tbGoodsInfo.nCalculation == 1 then
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
    local nLimitHaveNum = IBLogic.GetLimitHaveNum(self.tbGoodsInfo)
    if nLimitHaveNum and nLimitHaveNum > 0 then
        if self:GetNum(self.tbGoodsInfo) >= nLimitHaveNum then
            return false, string.format(Text("ui.Max_Limit_Have"), nLimitHaveNum)
        end
    end
    return true
end

--购买
function tbClass:DoPurchase()
     if not self.tbGoodsInfo then return end

    local bUnlock, tbDes = Condition.Check(self.tbGoodsInfo.tbCondition)
    if not bUnlock then
        if tbDes and #tbDes >= 1 then
            UI.ShowTip(tbDes[1])
        end
        return
    end

    local nStartTime = self.tbGoodsInfo.nStartTime
    local nEndTime = self.tbGoodsInfo.nEndTime
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
        if self.tbGoodsInfo.nAddiction > 0 then
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
        UI.Open("MessageBox", string.format(Text("tip.exchange_jump_mall"), Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Gold).sName)),
            function() --跳转数据金商店
                CashExchange.ShowUIExchange(Cash.MoneyType_Gold)
            end
        )
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
    if IBLogic.CheckProductSellOut(self.tbGoodsInfo.nGoodsId) then 
        UI.ShowTip("tip.Mall_Limit_Buy")
        return 
    end

    IBLogic.DoBuyProduct(self.tbGoodsInfo.nType, self.tbGoodsInfo.nGoodsId)
    self.tbGoodsInfo = nil
    WidgetUtils.Collapsed(self)
end

return tbClass;