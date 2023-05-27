-- ========================================================
-- @File    : uw_dlcrogue_goods.lua
-- @Brief   : 肉鸽活动 商品item
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnNoBuy, function ()
        UI.ShowMessage(Text("tip.gold_not_enough"))
    end)
    BtnAddEvent(self.BtnBuyOver, function ()
        UI.ShowMessage(Text("tip.Mall_Limit_Buy"))
    end)
    BtnAddEvent(self.BtnBuy, function ()
        if not self.NodeInfo or not self.GoodsInfo then
            return
        end
        local fun = function ()
            local uiShop = UI.GetUI("DlcRogueShop")
            if uiShop and uiShop:IsOpen() then
                uiShop:UpdateGoodsList()
            end
        end
        if self.nType == 1 then --购买商品
            local tbData = {nID = self.NodeInfo.nID, nType = self.NodeInfo.nNode, nGoodsID = self.GoodsInfo.nID}
            RogueLogic.FinishNode(tbData, fun)
        elseif self.nType == 2 and self.GoodsInfo.Card then --复活队员
            local key = ""
            if self.GoodsInfo.Card:IsTrial() then
                key = me:GetTrialIDByItem(self.GoodsInfo.Card) .. "_T"
            else
                key = self.GoodsInfo.Card:Id() .. "_P"
            end
            local tbData = {nID = self.NodeInfo.nID, nType = self.NodeInfo.nNode, sRoleKey = key}
            RogueLogic.ReviveRole(tbData, fun)
        end
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    ---商品类型 1普通商品 2复活队员
    self.nType = pObj.Data.nType
    ---商品信息或可复活的角色卡
    self.GoodsInfo = pObj.Data.GoodsInfo
    ---节点信息
    self.NodeInfo = pObj.Data.NodeInfo
    ---0未购买 1已经购买
    self.nBuyState = pObj.Data.nBuyState or 0

    if not self.GoodsInfo or not self.NodeInfo then return end

    local nPrice = math.floor(RogueLogic.GetGoodsPriceBuff() * (self.GoodsInfo.nPrice or 0) / 100)

    if self.nBuyState > 0 then
        WidgetUtils.Collapsed(self.BtnBuy)
        WidgetUtils.Collapsed(self.BtnNoBuy)
        WidgetUtils.HitTestInvisible(self.PanelBuyOver)
        WidgetUtils.Visible(self.BtnBuyOver)
    elseif nPrice and nPrice > Cash.GetMoneyCount(RogueLogic.MoneyId) then
        WidgetUtils.Collapsed(self.PanelBuyOver)
        WidgetUtils.Collapsed(self.BtnBuy)
        WidgetUtils.Collapsed(self.BtnBuyOver)
        WidgetUtils.Visible(self.BtnNoBuy)
    else
        WidgetUtils.Collapsed(self.PanelBuyOver)
        WidgetUtils.Collapsed(self.BtnNoBuy)
        WidgetUtils.Collapsed(self.BtnBuyOver)
        WidgetUtils.Visible(self.BtnBuy)
    end

    if self.nType == 1 then
        self:SetName(Text(self.GoodsInfo.sBuffName), Text(self.GoodsInfo.sDesc, table.unpack(self.GoodsInfo.tbBuffParamPerCount or {})), nPrice)
        if self.GoodsInfo.nType == 3 then
            WidgetUtils.Collapsed(self.BuffIcon)
            WidgetUtils.SelfHitTestInvisible(self.Role)
            local pTrialCard = me:GetTrialCard(self.GoodsInfo.nTrialID)
            if pTrialCard then
                self.Role:Show(pTrialCard)
            end
            WidgetUtils.Collapsed(self.TextTitle)
        else
            WidgetUtils.Collapsed(self.Role)
            WidgetUtils.HitTestInvisible(self.BuffIcon)
            self.BuffIcon:Show(self.GoodsInfo.nIcon)
            WidgetUtils.HitTestInvisible(self.TextTitle)
        end
    elseif self.nType == 2 then
        self:SetName(Text("rogue.TxtRoleLife"), Text("rogue.TxxRoleLiftDetail", self.GoodsInfo.nPrice, Text(self.GoodsInfo.Card:I18N() .. "_suits")), self.GoodsInfo.nPrice)
        WidgetUtils.Collapsed(self.BuffIcon)
        WidgetUtils.SelfHitTestInvisible(self.Role)
        self.Role:Show(self.GoodsInfo.Card)
        WidgetUtils.Collapsed(self.TextTitle)
    end
end

function tbClass:SetName(Name, Desc, Price)
    self.TxtBuffName:SetText(Name)
    self.TxtBuffDetail:SetText(Desc)
    self.TxtMoney:SetText(Price)
    self.TxtMoney1:SetText(Price)
end

return tbClass
