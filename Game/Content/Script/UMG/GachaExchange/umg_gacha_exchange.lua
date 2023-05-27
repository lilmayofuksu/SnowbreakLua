-- ========================================================
-- @File    : umg_gacha_exchange.lua
-- @Brief   : 抽奖兑换
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnCancel, function() UI.Close(self) end)
    BtnAddEvent(self.BtnPurchase, function() 
        if not self.sendCmd then return end

        if not CashExchange.ShowCheckExchange(self.cashId, self.nNeed, function() UI.Close(self) end, "tip.gacha_lackmoney") then
            return
        else
            if not self.sendCmd then return end
            UI.ShowConnection()
            me:CallGS("Item_Exchange", json.encode(self.sendCmd))
        end
    end)

    self.nSuccHandle = EventSystem.On(Event.ExchangeSuc, function()
        UI.CloseConnection()
        UI.Close(self)
        if self.fSucCallback then self.fSucCallback() end
    end)
end

function tbClass:OnClose()
    EventSystem.Remove(self.nSuccHandle)
end

function tbClass:OnOpen(nId, nTime, fCallback)
    if not nId or not nTime then return end
    self.fSucCallback = fCallback
    self.nId = nId

    self.tbCfg = Gacha.GetCfg(nId)
    if not self.tbCfg then return end

    local bCan, tbGDPL = self.tbCfg:CheckCost(nTime)
    if bCan then return end

    local g, d, p, l, n = table.unpack(tbGDPL)


    if not g or not d or not p or not l or not n then return end

    local nHave = me:GetItemCount(g, d, p, l)
    local nNeed = n - nHave

    local exchangeInfo = Item.tbExchange[string.format("%s-%s-%s-%s", g, d, p, l)]
    if not exchangeInfo then return end

    local cashId, nRatio =  exchangeInfo.tbCash[1],  exchangeInfo.tbCash[2]
    if not cashId or not nRatio then return end

    self.cashId = cashId
    self.nRatio = nRatio
    
    self.nNeed = nNeed * nRatio
    local icon , _ , nNum = Cash.GetMoneyInfo(cashId)

    SetTexture(self.IconCurrency, icon)
    self.TxtNum:SetText(tostring((self.nNeed or 0)) .. '/')

    ---不足
    if self.nNeed > nNum  then
        Color.Set(self.TxtNum2, Color.WarnColor)
    end

    self.TxtNum2:SetText(nNum)
    self.Item:Display({ G = g, D = d, P = p, L = l, N = nNeed, bForceShowNum = true})

    self.sendCmd = {tbGDPLN = {g, d, p, l, nNeed}}

    local pTemplate = UE4.UItem.FindTemplate(g, d, p, l)
    self.TxtPurchaseTip:SetText(Text('ui.TxtPurchaseTip', Text(pTemplate.I18N)))
end

return tbClass