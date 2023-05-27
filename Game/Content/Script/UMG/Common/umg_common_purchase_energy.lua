-- ========================================================
-- @File    : umg_common_purchase_energy.lua
-- @Brief   : 使用道具补充体力弹窗
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

-- 大中小体力药
tbClass.tbEnergyBoxInfo = {
    {4, 2, 1, 2},
    {4, 2, 1, 3},
    {4, 2, 1, 4}
}

function tbClass:OnInit()
    self.Factory = Model.Use(self)

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
            if self.tbSelected.N == 0 then
                return UI.ShowTip("tip.NotEnoughItem") 
            end
            if self.tbSelected.nCount == self.tbSelected.N then
                return UI.ShowTip("tip.shop_max")
            end
            self.tbSelected.nCount = self.tbSelected.N
            self.TextNum:SetText(tostring(self.tbSelected.nCount))
            local n = self.tbSelected.nCount * self.tbSelected.pTemp.Param1
            self.TextTop:SetText(
                string.format(
                    Text("ui.exchange_tip"),
                    self.tbSelected.nCount .. Text(self.tbSelected.pTemp.I18N),
                    n .. Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Vigour).sName)
                )
            )
            self.TxtNum:SetText(string.format("X%d", n))
            self.tbSelected.tbNum[1] = self.tbSelected.nCount
            EventSystem.TriggerTarget(self.tbSelected, "SET_NUM")
        end
    )
    BtnAddEvent(
        self.BtnNo,
        function()
            UI.Close(self)
        end
    )
    BtnAddEvent(
        self.BtnOK,
        function()
            if not self.tbSelected then
                return
            end
            if self.openType == "Energy" then
                if self.tbSelected.nCashType then
                    if self.tbSelected.tbLimit[1] >= self.tbSelected.tbLimit[2] then
                        return UI.ShowTip("tip.exchange_vigor_max")
                    end

                    if not CashExchange.ShowCheckExchange(Cash.MoneyType_Gold, self.tbSelected.tbNum[1], function() UI.Close(self) end, "tip.cash_not_enough") then
                        return
                    end

                    UI.ShowConnection()
                    CashExchange.Exchange(self.tbSelected.nCashType, self.tbSelected.tbNum[1], Cash.MoneyType_Vigour, function()
                        Adjust.DoRecord("kfx199")
                        UI.Close(self)
                        UI.CloseConnection()
                    end)
                else
                    if self.tbSelected.N < self.tbSelected.nCount then
                        return UI.ShowTip("tip.NotEnoughItem")
                    end
                    local pItemList = UE4.TArray(UE4.UItem)
                    me:GetItems(pItemList)
                    local pUseItem = self.tbSelected.pItem
                    if not pUseItem then
                        for i = 1, pItemList:Length() do
                            local pItem = pItemList:Get(i)
                            if self.tbSelected.G == pItem:Genre() and self.tbSelected.D == pItem:Detail() and self.tbSelected.P == pItem:Particular() and self.tbSelected.L == pItem:Level() then
                                pUseItem = pItem
                            end
                        end
                    end
                    if self.tbSelected.nExpiration and self.tbSelected.nExpiration <= GetTime() then
                        return UI.ShowTip("tip.ItemExpirated")
                    end
                    me:UseItem(pUseItem:Id(), self.tbSelected.nCount)
                    self:UseItemCallBack(pUseItem,self.tbSelected.nCount)
                end
            elseif self.openType == "OpenBox" then
                local cmd = {
                    Id = self.tbSelected.pItem:Id(),
                    Count = self.tbSelected.nCount
                }
                me:CallGS("Item_OpenBox", json.encode(cmd))
                self:UseItemCallBack(self.tbSelected.pItem,self.tbSelected.nCount)
            elseif self.openType == "UseItem" then
                me:UseItem(self.tbSelected.pItem:Id(), self.tbSelected.nCount)
                self:UseItemCallBack(self.tbSelected.pItem,self.tbSelected.nCount)
            end
            
            self.nServerErrorEvent =
                EventSystem.On(
                Event.ShowPlayerMessage,
                function()
                    UI.CloseConnection()
                    UI.Close(self)
                end,
                true
            )
        end
    )
end

---@param nNeed number 需要多少体力,默认为最小体力
---@param openType
---@param pItem
function tbClass:OnOpen(openType,pItem)
    self:DoClearListItems(self.List)
    self.openType = openType
    if openType == "OpenBox" then
        self:OpenBox(pItem)
    elseif openType == "Energy" then
        self:PurchaseEnergy()
    elseif openType == "UseItem" then
        self:UseItem(pItem)
    end    
end

function tbClass:UseItem(pItem)
    local info = UE4.UItem.FindTemplate(pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level())

    self.tbSelected = {}
    self.TextNum:SetText(1)
    local tbData = {
                G = pItem:Genre(),
                D = pItem:Detail(),
                P = pItem:Particular(),
                L = pItem:Level(),
                N = pItem:Count(),
                pTemp = info,
                pItem = pItem,
                bInfoSP = true,
                fCustomEvent = function()
                    -- if self.tbSelected then
                        -- self.tbSelected.bSelected = false
                        -- self.tbSelected:SetSelected()
                    -- end
                    -- self.tbSelected = tbBox
                    -- self.tbSelected.tbSubUI.bSelected = true
                    -- self.tbSelected.tbSubUI:SetSelected()
                end
            }
    if tbData.N > 0 then
        tbData.nMaxCount = tbData.N
    else
        tbData.nMaxCount = 1
    end

    tbData.tbNum = {1, tbData.N}

    self.tbSelected = tbData
    self.tbSelected.bSelected = true
    self.tbSelected.nCount = 1

    local n = self.tbSelected.nCount * self.tbSelected.pTemp.Param1
    local sTip = string.format(
        Text("ui.exchange_tip"),
        self.tbSelected.nCount .. Text(self.tbSelected.pTemp.I18N), n .. Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Vigour).sName)
    )

    WidgetUtils.Collapsed(self.TxtRecover)
    
    self.TextTop:SetText(sTip)
    self.List:AddItem(self.Factory:Create(tbData))

end

function tbClass:OpenBox(pItem)
    local info = UE4.UItem.FindTemplate(pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level())
    local sTip =
        string.format(
        Text("ui.openbox"),
        Text(info.I18N)
    )
    local tbData = {
            G = pItem:Genre(),
            D = pItem:Detail(),
            P = pItem:Particular(),
            L = pItem:Level(),
            N = pItem:Count(),
            pTemp = info,
            pItem = pItem
        }
    if tbData.N > 0 then
        tbData.nMaxCount = tbData.N
    else
        tbData.nMaxCount = 1
    end
    self.tbSelected = tbData
    -- self.tbSelected.pItem = pItem
    self.tbSelected.nCount = 1
    self.TextTop:SetText(sTip)
    self.TextNum:SetText(1)
    
    -- self.tbSelected.tbSubUI=tbData
    self.tbSelected.bSelected = true
    self.List:AddItem(self.Factory:Create(tbData))

end

function tbClass:PurchaseEnergy()
    self.tbPurchaseBox = {}

    self.TxtName:SetText(Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Vigour).sName))
    self.List:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)

    -- 数据金置换
    local tbVigorExchange = {nCashType = Cash.MoneyType_Gold, nNum = Cash.GetMoneyCount(Cash.MoneyType_Gold)}
    table.insert(self.tbPurchaseBox, tbVigorExchange)
    local tbVigorExchangeCfg = CashExchange.GetInfo[Cash.MoneyType_Vigour]()
    if tbVigorExchangeCfg then
        tbVigorExchange.tbNum = {tbVigorExchangeCfg.tbExchange.nCount, Cash.GetMoneyCount(Cash.MoneyType_Gold)}
        tbVigorExchange.nVigor = tbVigorExchangeCfg.tbExhcangTarget.nCount
        tbVigorExchange.tbLimit = tbVigorExchangeCfg.tbLimit
    else
        local tbCfg = CashExchange.tbConfig[Cash.MoneyType_Vigour]
        tbVigorExchange.tbNum = {tbCfg[tbCfg.nMax].nCost, Cash.GetMoneyCount(Cash.MoneyType_Gold)}
        tbVigorExchange.nVigor = tbCfg[tbCfg.nMax].nVigor
        tbVigorExchange.tbLimit = {tbCfg.nMax, tbCfg.nMax}
    end
    tbVigorExchange.fCustomEvent = function()
        if self.tbSelected then
            self.tbSelected.bSelected = false
            if self.tbSelected ~= tbVigorExchange then
                self.tbSelected.tbNum[1] = 1
            end
            EventSystem.TriggerTarget(self.tbSelected, "SET_SELECTED")
        end
        WidgetUtils.Collapsed(self.Count)
        WidgetUtils.Visible(self.LimitNum)
        self.TextTop:SetText(
            string.format(
                Text("ui.exchange_tip"),
                tbVigorExchange.tbNum[1] .. Text(Cash.GetMoneyCfgInfo(tbVigorExchange.nCashType).sName),
                tbVigorExchange.nVigor .. Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Vigour).sName)
            )
        )
        self.TxtNum:SetText(string.format("X%d", tbVigorExchange.nVigor))
        tbVigorExchange.bSelected = true
        tbVigorExchange.bInfoSP = true
        EventSystem.TriggerTarget(tbVigorExchange, "SET_SELECTED")
        self.tbSelected = tbVigorExchange
    end

    -- 体力药
    local tbVigorBox = {
        {4, 2, 1, 5, true},
        {4, 2, 1, 6, true},

        {4, 2, 1, 2},
        {4, 2, 1, 3},
        {4, 2, 1, 4}
    }

    for _, tbGDPL in ipairs(tbVigorBox) do
        local tbTemp = {
            G = tbGDPL[1],
            D = tbGDPL[2],
            P = tbGDPL[3],
            L = tbGDPL[4],
            N = 0,
            tbNum = {1, 0},
            bForceShowNum = true,
            pTemp = UE4.UItem.FindTemplate(tbGDPL[1], tbGDPL[2], tbGDPL[3], tbGDPL[4]),
            bInfoSP = true
        }

        local tbBoxs = {}

        if tbGDPL[5] then
            local pItemList = UE4.TArray(UE4.UItem)
            me:GetItemsByGDPL(tbGDPL[1], tbGDPL[2], tbGDPL[3], tbGDPL[4], pItemList)
            for i = 1, pItemList:Length() do
                local pItem = pItemList:Get(i)
                local tbBox = Copy(tbTemp)
                tbBox.pItem = pItem
                if pItem:Expiration() > 0 then
                    tbBox.nExpiration = pItem:Expiration()
                    tbBox.N = pItem:Count()
                    tbBox.tbNum = {1, tbBox.N}
                    table.insert(tbBoxs, tbBox)
                end
            end
        else
            local tbBox = Copy(tbTemp)
            tbBox.N = me:GetItemCount(table.unpack(tbGDPL))
            tbBox.tbNum = {1, tbBox.N}
            if tbBox.N > 0 then table.insert(tbBoxs, tbBox) end
        end

        for _, tbBox in ipairs(tbBoxs) do
            if tbBox.tbNum[2] > 0 then
                tbBox.nMaxCount = tbBox.tbNum[2]
            else
                tbBox.nMaxCount = 1
            end

            tbBox.fCustomEvent = function()
                if self.tbSelected then
                    self.tbSelected.bSelected = false
                    if self.tbSelected ~= tbVigorExchange then
                        self.tbSelected.tbNum[1] = 1
                    end
                    EventSystem.TriggerTarget(self.tbSelected, "SET_SELECTED")
                end
                WidgetUtils.Visible(self.Count)
                WidgetUtils.Collapsed(self.LimitNum)
                self.TextTop:SetText(
                    string.format(
                        Text("ui.exchange_tip"),
                        1 .. Text(tbBox.pTemp.I18N),
                        tbBox.pTemp.Param1 .. Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Vigour).sName)
                    )
                )
                self.TxtNum:SetText(string.format("X%d", tbBox.pTemp.Param1))
                tbBox.nCount = 1
                self.TextNum:SetText("1")
                tbBox.bSelected = true
                tbBox.tbNum[1] = 1
                EventSystem.TriggerTarget(tbBox, "SET_SELECTED")
                self.tbSelected = tbBox
            end

            table.insert(self.tbPurchaseBox, tbBox)
            if not self.tbSelected then tbBox.fCustomEvent() end -- 先选择兑换第一种体力药
        end
    end

    if not self.tbSelected then tbVigorExchange.fCustomEvent() end -- 什么体力药都没有就选择数据金置换

    for _, tbV in ipairs(self.tbPurchaseBox) do
        self.List:AddItem(self.Factory:Create(tbV))
    end

    -- 设置体力恢复时间
    local funcSetRecoverTime = function()
        if Cash.GetMoneyCount(Cash.MoneyType_Vigour) >= Player.GetMaxVigor(me:Level()) then
            self.TxtRecover:SetContent(Text("ui.TxtPurchaseTip3"))
            return
        end
        local _, nH, nM, nS = TimeDiff(360 + me:LastVigorTime(), GetTime())
        local sText = string.format("%02d:%02d:%02d", nH, nM, nS)
        self.TxtRecover:SetContent(string.format(Text("ui.TxtEnergyRecover"), sText, "1"))
    end
    funcSetRecoverTime()
    self.VigorRecoverTimer =  UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, funcSetRecoverTime}, 1, true);
end

function tbClass:OnClose()
    -- EventSystem.Remove(self.nVigorChangeEvent)
    EventSystem.Remove(self.nServerErrorEvent)
    if self.VigorRecoverTimer then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.VigorRecoverTimer);
    end
end

function tbClass:AddCount()
    if self.tbSelected.N == 0 then
        return UI.ShowTip("tip.NotEnoughItem")
    end

    if self.tbSelected.nCount < self.tbSelected.nMaxCount then
        self.tbSelected.nCount = self.tbSelected.nCount + 1
        self.TextNum:SetText(tostring(self.tbSelected.nCount))
        local n = self.tbSelected.nCount * self.tbSelected.pTemp.Param1
        self.TextTop:SetText(
            string.format(
                Text("ui.exchange_tip"),
                self.tbSelected.nCount .. Text(self.tbSelected.pTemp.I18N),
                n .. Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Vigour).sName)
            )
        )
        self.TxtNum:SetText(string.format("X%d", n))
        self.tbSelected.tbNum[1] = self.tbSelected.nCount
        EventSystem.TriggerTarget(self.tbSelected, "SET_NUM")
    else
        return UI.ShowTip("tip.shop_max")
    end
end

function tbClass:DecCount()
    if self.tbSelected.N == 0 then
        return UI.ShowTip("tip.NotEnoughItem")
    end

    if self.tbSelected.nCount > 1 then
        self.tbSelected.nCount = self.tbSelected.nCount - 1
        self.TextNum:SetText(tostring(self.tbSelected.nCount))
        local n = self.tbSelected.nCount * self.tbSelected.pTemp.Param1
        self.TextTop:SetText(
            string.format(
                Text("ui.exchange_tip"),
                self.tbSelected.nCount .. Text(self.tbSelected.pTemp.I18N),
                n .. Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Vigour).sName)
            )
        )
        self.TxtNum:SetText(string.format("X%d", n))
        self.tbSelected.tbNum[1] = self.tbSelected.nCount
        EventSystem.TriggerTarget(self.tbSelected, "SET_NUM")
    else
        return UI.ShowTip("tip.shop_min")
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


return tbClass
