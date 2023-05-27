-- ========================================================
-- @File    : umg_common_purchase_exchange.lua
-- @Brief   : 置换界面 PurchaseExchange
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(
        self.BtnNo,
        function()
            UI.Close(self)
        end
    )
    BtnAddEvent(
        self.BtnOK,
        function()
            if self.tbInfo and self.tbInfo.bMall then
                self:DoMallBuy()
                UI.Close(self)
                return
            end

            if self.tbInfo.tbExchange.nCount then
                if self.tbInfo.tbLimit and self.tbInfo.tbLimit[1] >= self.tbInfo.tbLimit[2] then
                    return UI.ShowTip("tip.exchange_cash_max")
                end

                if not CashExchange.ShowCheckExchange(self.tbInfo.tbExchange.nCashID, self.tbInfo.tbExchange.nCount, function() UI.Close(self) end, "tip.cash_not_enough") then
                    return
                end

                CashExchange.Exchange(
                    self.tbInfo.tbExchange.nCashID,
                    (self.tbInfo.tbExchange.nCount or 0) * (self.nCount or 0),
                    self.tbInfo.tbExhcangTarget.nCashID,
                    function()
                        if self.tbInfo.funBack then
                            self.tbInfo.funBack()
                        end
                        UI.Close(self)
                        EventSystem.Remove(self.nServerErrorEvent)
                    end
                )
                self.nServerErrorEvent =
                    EventSystem.On(
                    Event.ShowPlayerMessage,
                    function()
                        UI.CloseConnection()
                        UI.Close(self)
                    end,
                    true
                )
            else
                me:UseItem(self.tbInfo.tbExchange.pItem:Id(), self.nCount)
                self:UseItemCallBack(self.tbInfo.tbExchange.pItem, self.nCount)
            end
        end
    )
    BtnAddEvent(
        self.BtnReduce,
        function()
            self:DecCount()
        end
    )
    self.BtnReduce.OnLongPressed:Add(
        self,
        function()
            self:DecCount()
        end
    )
    BtnAddEvent(
        self.BtnAdd,
        function()
            self:AddCount()
        end
    )
    self.BtnAdd.OnLongPressed:Add(
        self,
        function()
            self:AddCount()
        end
    )
    BtnAddEvent(
        self.BtnMax,
        function()
            local nMax = 0
            if self.tbInfo.tbExchange.nCashID then
                nMax = Cash.GetMoneyCount(self.tbInfo.tbExchange.nCashID)
                nMax = nMax // self.tbInfo.tbExchange.nCount
            else
                nMax = self.tbInfo.tbExchange.pItem:Count()
            end

            if nMax <= 0 then
                nMax = 1
            end
            self:SetCount(nMax)
        end
    )
end

function tbClass:OnOpen(tbInfo)
    if not tbInfo then return end 

    self.tbInfo = tbInfo
    if self.tbInfo.bMall then
        self:ShowMall()
    else
        self:ShowNormal()
    end
end

function tbClass:OnClose()
    EventSystem.Remove(self.nServerErrorEvent)
end

--普通显示
function tbClass:ShowNormal()
    self:SetItem(self.Item1, self.tbInfo.tbExchange)
    self:SetItem(self.Item2, self.tbInfo.tbExhcangTarget)

    if self.tbInfo.nRate and self.tbInfo.bMutable then
        WidgetUtils.Visible(self.Num)
    else
        WidgetUtils.Collapsed(self.Num)
    end
    if self.tbInfo.tbLimit then
        WidgetUtils.Visible(self.Limit)
        self.TxtLimitSum:SetText(string.format("%d/%d", self.tbInfo.tbLimit[1], self.tbInfo.tbLimit[2]))
    else
        WidgetUtils.Collapsed(self.Limit)
    end

    self:SetCount(1)
end

function tbClass:SetItem(pItem, tbInfo)
    if tbInfo.nCashID then
        pItem:Display({nCashType = tbInfo.nCashID, nNum = tbInfo.nCount})
    else
        pItem:Display(tbInfo)
    end
end

function tbClass:SetCount(nCount)
    self.nCount = nCount

    local nExtra = self.tbInfo.nExtra or 0
    local nVal = self.tbInfo.tbExhcangTarget.nCount * nCount  + nExtra
    self.Item2.TxtNumber:SetText(tostring(nVal))
    self.TextNum:SetText(nCount)

    local nExchange
    if self.tbInfo.tbExchange.nCount then
        nExchange = self.tbInfo.tbExchange.nCount * nCount
    else
        nExchange = nCount
    end
    self.Item1.TxtNumber:SetText(tostring(nExchange))

    local sExchange
    if self.tbInfo.tbExchange.nCashID then
        sExchange = Text(Cash.GetMoneyCfgInfo(self.tbInfo.tbExchange.nCashID).sName)
    else
        sExchange = Text(self.tbInfo.tbExchange.pTemp.I18N)
    end

    local sTarget = Text(Cash.GetMoneyCfgInfo(self.tbInfo.tbExhcangTarget.nCashID).sName)
    local sTip = string.format(Text("ui.exchange_tip"), nExchange..sExchange, nVal..sTarget)
    self.TextTop:SetText(sTip)
end

function tbClass:AddCount()
    local nMax = 0
    if self.tbInfo.tbExchange.nCashID then
        nMax = Cash.GetMoneyCount(self.tbInfo.tbExchange.nCashID)
        nMax = nMax // self.tbInfo.tbExchange.nCount
    else
        nMax = self.tbInfo.tbExchange.pItem:Count()
    end

    if self.nCount then
        if self.nCount < nMax then
            self:SetCount(self.nCount + 1)
        else
            UI.ShowTip("tip.shop_max")
        end
    end
end

function tbClass:DecCount()
    if self.nCount then
        if self.nCount > 1 then
            self:SetCount(self.nCount - 1)
        else
            UI.ShowTip("tip.shop_min")
        end        
    end
end

--服务器 Item::Use 中先使用道具（调用Lua的onUse）再扣减数量
--客户端收到onUse中的回包时还没同步到最新数据
function tbClass:UseItemCallBack(pItem,nUseCount)
    UI.ShowConnection()
    if pItem:Count() > nUseCount then

        self.nGetBoxItemEvent = 
            EventSystem.On(
            Event.GetBoxItem,
            function(InItem)
                print("GetBoxItem UpdatePage callBack")
                UI.CloseConnection()
                UI.Close(self)
                EventSystem.Remove(self.nServerErrorEvent)
                EventSystem.Remove(self.nGetBoxItemEvent)

                local BagUI = UI.GetUI("Bag")
                if BagUI then
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {
                        BagUI,
                        function()
                            local BagUI = UI.GetUI("Bag")
                            if BagUI then
                                BagUI:UpdatePage()
                            end
                        end
                    },
                    0.05,
                    false
                    )
                end
            end,
            true
        )
    else
        print("set OnRecycleEnd callback")
        self.nGetBoxItemEvent = 
            EventSystem.On(
            Event.GetBoxItem,
            function(InItem)
                print("GetBoxItem OnRecycleEnd callBack")
                UI.CloseConnection()
                UI.Close(self)
                EventSystem.Remove(self.nServerErrorEvent)
                EventSystem.Remove(self.nGetBoxItemEvent)

                local BagUI = UI.GetUI("Bag")
                if BagUI then
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {
                        BagUI,
                        function()
                            local BagUI = UI.GetUI("Bag")
                            if BagUI then
                                BagUI:OnRecycleEnd()
                            end
                        end
                    },
                    0.05,
                    false
                    )
                end
            end,
            true
        )
    end
end


----商城借用界面
function tbClass:ShowMall()
    WidgetUtils.Collapsed(self.Limit)
    WidgetUtils.Collapsed(self.Num)

    self:SetItem(self.Item1, self.tbInfo.tbExchange)
    self:SetItem(self.Item2, self.tbInfo.tbExhcangTarget)

    self:SetCount(1)
end

--商城确认
function tbClass:DoMallBuy()
    if not self.tbInfo.nGoodsId then
        UI.ShowTip("tip.BadIBGoodId")
        return
    end

    if not CashExchange.ShowCheckExchange(self.tbInfo.tbExchange.nCashID, self.tbInfo.tbExchange.nCount, function() UI.Close(self) end, "tip.cash_not_enough") then
        return
    end

    IBLogic.BuyIbGoods(self.tbInfo.nGoodsId, IBLogic.Type_IBGold)
end

return tbClass
