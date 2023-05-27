-- ========================================================
-- @File    : uw_bplevelpurchase.lua
-- @Brief   : bp通行证等级购买界面
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    BtnAddEvent(self.BtnNo, function() UI.Close(self) end)
    BtnAddEvent(self.BtnOK, function() self:DoBuy() end)

	BtnAddEvent(self.BtnReduce, function() self:DoChangeLevel(-1) end)
    BtnAddEvent(self.BtnAdd, function() self:DoChangeLevel(1) end)
    BtnAddEvent(self.BtnMax, function() self:DoChangeLevel() end)

    self.List:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)

    self.BtnAdd.OnLongPressed:Add(self, function(_, _, n)
        if self:DoChangeLevel(1) then
            self.BtnAdd:StopLongPress()
        end
    end)

    self.BtnReduce.OnLongPressed:Add(self, function(_, _, n)
        if self:DoChangeLevel(-1) then
            self.BtnReduce:StopLongPress()
        end
    end)
end

function tbClass:OnOpen()
    self.tbConfig = BattlePass.GetMeConfig()
    self.nAddLevel = 1
    self:ShowLevel()
    self:ShowMoney()
    self:ShowAward()
end

--关闭
function tbClass:OnClose()
    self.tbConfig = nil
end

--显示等级
function tbClass:ShowLevel()
    if not self.tbConfig then return end

    self.TxtNum:SetText(string.format("X%d", BattlePass.GetCurLevel()))

    local nShowLevel = BattlePass.GetCurLevel()+self.nAddLevel
    if nShowLevel > BattlePass.GetMaxLevel(self.tbConfig.nId) then
        nShowLevel = BattlePass.GetMaxLevel(self.tbConfig.nId)
        self.nAddLevel = nShowLevel - BattlePass.GetCurLevel()
    end

    self.TxtNum_1:SetText(string.format("X%d", nShowLevel))

    self:ShowAddLevel()
end

--显示增加的等级
function tbClass:ShowAddLevel()
    if self.nAddLevel < 0 then
        self.nAddLevel = 0
    end

    self.TextNum:SetText(self.nAddLevel)
end

--修改等级
function tbClass:DoChangeLevel(nNum)
    if not self.tbConfig then return end

    local nRet = false
    local nMax = BattlePass.GetMaxLevel(self.tbConfig.nId)
    if not nNum then
        self.nAddLevel = (nMax - BattlePass.GetCurLevel())
    else
        nNum = nNum or 1
        self.nAddLevel = self.nAddLevel + nNum
    end
    
    if self.nAddLevel <= 0 then
        UI.ShowTip("tip.shop_min")
        self.nAddLevel = 1
        nRet = true
    elseif self.nAddLevel + BattlePass.GetCurLevel() > nMax then
        UI.ShowTip("tip.shop_max")
        self.nAddLevel = nMax
        nRet = true
    end

    self:ShowLevel()
    self:ShowMoney()
    self:ShowAward()

    return nRet
end

--显示购买金额
function tbClass:ShowMoney()
    if not self.tbConfig then return end
    if not self.tbConfig.tbMoney and #self.tbConfig.tbMoney > 0 then return end

    --WidgetUtils.Visible(self.Currency)
    
    local icon, _, _ = Cash.GetMoneyInfo(self.tbConfig.tbMoney[1])
    SetTexture(self.IconCurrency, icon)

    local nAllNum = tonumber(self.tbConfig.tbMoney[2] * self.nAddLevel)
    self.TxtCurrencyNum:SetText(nAllNum)

    if Cash.GetMoneyCount(self.tbConfig.tbMoney[1]) >= nAllNum then
        self.TxtCurrencyNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 1))
    else
        self.TxtCurrencyNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1))
    end
end

--确定购买
function tbClass:DoBuy()
    if self.nAddLevel <= 0 then
        UI.Close(self)
        return
    end

    local bRet,sDesc = BattlePass.CheckBuyLevel(self.tbConfig)
    if not bRet or self.nAddLevel <= 0 or self.nAddLevel > 999 then
        UI.ShowTip(sDesc)
        return
    end

    local nAllNum = tonumber(self.tbConfig.tbMoney[2] * self.nAddLevel)
    if not CashExchange.ShowCheckExchange(self.tbConfig.tbMoney[1], nAllNum, function() UI.Close(self) end, "tip.cash_not_enough") then
        return
    end

    BattlePass.DoBuyLevel(self.nAddLevel)
    UI.Close(self)
end

--显示奖励
function tbClass:ShowAward()
    self:DoClearListItems(self.List)

    local tbNormalConfig = BattlePass.GetLevelAward()
    local tbAdvanceConfig = nil
    local nCurLevel = BattlePass.GetCurLevel()
    local doMakeParam = function(tbConfig, nIdx, bAdv) 
        if not tbConfig then return {} end
        local tbAward = tbConfig.tbNormalAward
        if bAdv then
            tbAward = tbConfig.tbAdvanceAward
        end

        local tbParam = {G = tbAward[1],D = tbAward[2],P = tbAward[3],L = tbAward[4],N =tbAward[5] or 1}
        return tbParam
    end

    local nCurLevel = BattlePass.GetCurLevel()
    if not self.nAddLevel or self.nAddLevel < 1 then return end

    for i=nCurLevel+1,nCurLevel+self.nAddLevel do
        local tbInfo = tbNormalConfig[i]
        local tbParam =doMakeParam(tbInfo, i)

        local obj = self.Factory:Create(tbParam)
        self.List:AddItem(obj)

        tbParam =doMakeParam(tbInfo, i, true)
        obj = self.Factory:Create(tbParam)
        self.List:AddItem(obj)
    end
end

return tbClass