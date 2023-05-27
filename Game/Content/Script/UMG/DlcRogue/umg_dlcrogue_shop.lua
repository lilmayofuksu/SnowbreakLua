-- ========================================================
-- @File    : umg_dlcrogue_shop.lua
-- @Brief   : 小肉鸽活动商店节点界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListGoods)
end

function tbClass:OnInit()
    self:DoClearListItems(self.ListGoods)
    self.Factory = Model.Use(self)
    BtnAddEvent(self.BtnReset, function ()
        if not self.tbRefreshMoney or not self.NodeInfo then
            return
        end
        local index = RogueLogic.GetBaseInfo().nRefreshTimes + 1
        if #self.tbRefreshMoney < index then
            index = #self.tbRefreshMoney
        end
        if Cash.GetMoneyCount(RogueLogic.MoneyId) < self.tbRefreshMoney[index] then
            UI.ShowMessage(Text("rogue.TxtMoneyWarn"))
            return
        end

        local fun = function ()
            self:UpdateGoodsList()
            self:UpdateMoney()
        end
        RogueLogic.RefreshShopGoods(self.NodeInfo.nID, fun)
    end)
    self.BtnTpis:InitHelpImages(29)
    self.Title:SetCustomEvent(UI.CloseTopChild, function ()
        UI.Open("MessageBox", Text("rogue.TxtQuitShop"), function ()
            if self.NodeInfo then
                local tbData = {nID = self.NodeInfo.nID, nType = self.NodeInfo.nNode}
                RogueLogic.FinishNode(tbData, UI.CloseTopChild)
            else
                UI.CloseTopChild()
            end
        end)
    end)
end

function tbClass:OnOpen(tbInfo)
    self.ListGoods:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.Title:SetCustomEvent(UI.CloseTopChild)

    if not tbInfo then
        return
    end

    ---1=战斗节点，2=事件节点，3=商店节点，4=休息点
    if tbInfo.nNode ~= 3 then
        return
    end

    self.Money:Init({9})

    local cfg = RogueLogic.tbActivitiesCfg[RogueLogic.GetActivitieID()]
    if cfg.tbRefresh then
        ---刷新代币消耗
        self.tbRefreshMoney = cfg.tbRefresh
    end
    if cfg.tbPrice then
        ---复活角色消耗
        self.tbRevivePrice = cfg.tbPrice
    end

    self.NodeInfo = tbInfo
    self:UpdateGoodsList()
    self:UpdateMoney()
end

---刷新消耗
function tbClass:UpdateMoney()
    if not self.tbRefreshMoney then
        return
    end
    local index = RogueLogic.GetBaseInfo().nRefreshTimes + 1
    if #self.tbRefreshMoney < index then
        index = #self.tbRefreshMoney
    end
    self.TextMoney:SetContent(Text("rogue.TxtRefreshBtn", self.tbRefreshMoney[index]))
end

---刷新商品列表
function tbClass:UpdateGoodsList()
    self:DoClearListItems(self.ListGoods)
    local tbGoods = RogueLogic.GettbGoods(self.NodeInfo.nID)
    for _, v in pairs(tbGoods) do
        local data = {nType = 1, NodeInfo = self.NodeInfo, GoodsInfo = v.GoodsInfo, nBuyState = v.nBuyState}
        local pObj = self.Factory:Create(data)
        self.ListGoods:AddItem(pObj)
    end

    local tbDeathCard = RogueLogic.GettbDeathCard()
    local index = RogueLogic.GetBaseInfo().nReviveTimes + 1
    if #self.tbRevivePrice < index then
        index = #self.tbRevivePrice
    end
    for _, Card in pairs(tbDeathCard) do
        local data = {nType = 2, NodeInfo = self.NodeInfo, GoodsInfo = {Card = Card, nPrice = self.tbRevivePrice[index]}}
        local pObj = self.Factory:Create(data)
        self.ListGoods:AddItem(pObj)
    end
end

function tbClass:OnClose()
    local uiRogue = UI.GetUI("DlcRogue")
    if uiRogue and uiRogue:IsOpen() then
        uiRogue:UpdatePanel()
    end
end

return tbClass
