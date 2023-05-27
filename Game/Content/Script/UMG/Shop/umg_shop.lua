-- ========================================================
-- @File    : umg_shop.lua
-- @Brief   : 商店界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.tbShopItem = {}
    self.tbCloseWidgetName = {
        "ShopPurchase",
        "ShopMonthCard",
        "ShopFashionList",
        "ShopMain",
    }
    self.Factory = Model.Use(self)
    WidgetUtils.Collapsed(self.ShopTips)
end

function tbClass:PreOpen()
    local bOpen, tbTip = FunctionRouter.IsOpenById(FunctionType.Shop)
    if not bOpen then
        UI.ShowTip(tbTip[1])
    end
    return bOpen
end

function tbClass:OnOpen(ShopId)
    self.SelectShopTab = nil
    self:CloseWidget()

    --月卡商店开放且月卡剩余小于三天 直接前往月卡商店
    if ShopLogic.GetShopInfo(21) then
        local data = ShopLogic.GetGoodsData(2101)
        local time = GetTime()
        if data and data.invalidtime and data.invalidtime > time and (data.invalidtime - time < 86400*3) then
            ShopId = 21
        end
    end

    if not ShopId then
        ShopId = self.SelectShopId
    end

    if ShopId then
        local shopInfo = ShopLogic.GetShopInfo(ShopId)
        if shopInfo then
            self.SelectShopTab = shopInfo.nGroupId
            self.SelectShopId = shopInfo.nShopId
        end
    end

    self.ListTab:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    Audio.PlayVoices("EntryShop")
    ShopLogic.GetOpenTime()

    ---货币数量改变时刷新列表
    if self.nMoneyChangeEvent then
        EventSystem.Remove(self.nMoneyChangeEvent)
    end
    self.nMoneyChangeEvent = EventSystem.On(Event.CustomAttr, function()
        if self.ShopTips:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
            self.ShopTips:UpdatePrice()
        end
    end)

    self:PlayAnimation(self.AllEnter)
end

function tbClass:OnClose()
    Audio.PlayVoices("ExitShop")
    EventSystem.Remove(self.nMoneyChangeEvent)
end

function tbClass:UpdateShopGroup()
    self:DoClearListItems(self.ListTab)
    local allOpenTab = ShopLogic.GetAllOpenTab()
    for _, groupId in ipairs(ShopLogic.tbGroupId) do
        local tbshop = allOpenTab[groupId]
        if tbshop and #tbshop >= 1 then
            local data = {}
            if not self.SelectShopTab or not self.SelectShopId then
                self.SelectShopTab = groupId
                self.SelectShopId = tbshop[1].nShopId
            end
            if self.SelectShopTab == groupId then
                data.SeleShop = self.SelectShopId
                data.isSele = true
            else
                data.SeleShop = tbshop[1].nShopId
                data.isSele = false
            end
            data.tbCfg = tbshop
            data.UpdateSelect = function()
                if self.SelectShopTab == groupId then return end
                self.tbShopItem[self.SelectShopTab]:SetSelect(false)
                self.tbShopItem[groupId]:SetSelect(true)
                self.SelectShopTab = groupId
            end
            data.UpdateShop = function(nShopId)
                if self.SelectShopId == nShopId then
                    return
                end
                self:UpdateGoodsList(nShopId)
            end
            data.FunRefreshListTab = function()
                self.ListTab:RequestRefresh()
            end
            local pObj = self.Factory:Create(data)
            self.ListTab:AddItem(pObj)
            self.tbShopItem[groupId] = pObj.Data
        end
    end
    self:UpdateGoodsList(self.SelectShopId)
end

---跳转到指定分类
function tbClass:GotoShop(shopId)
    WidgetUtils.Collapsed(self.ShopTips)
    local info = ShopLogic.GetShopInfo(shopId)
    if not info then return end

    if self.SelectShopTab == info.nGroupId then return end
    if self.tbShopItem[self.SelectShopTab] then
        self.tbShopItem[self.SelectShopTab]:SetSelect(false)
    end
    if self.tbShopItem[info.nGroupId] then
        self.tbShopItem[info.nGroupId]:SetSelect(true)
    end
    self.SelectShopTab = info.nGroupId

    self:UpdateGoodsList(info.nShopId)
end

---刷新显示的代币信息
function tbClass:UpdateMoney(shopId)
    local info = ShopLogic.GetShopInfo(shopId)
    if info and info.tbShopMoneyType then
        self.Money:Init(info.tbShopMoneyType, shopId ~= 1)
    end
end

---获取商品列表
function tbClass:UpdateGoodsList(shopId)
    if shopId and self.SelectShopId ~= shopId then
        self.SelectShopId = shopId
    end
    ShopLogic.GetGoodsList(self.SelectShopId)
end

---打开商品详情页
function tbClass:OpenShopTips(cfg)
    WidgetUtils.SelfHitTestInvisible(self.ShopTips)
    self.ShopTips:Init(cfg)
    self.ShopTips:PlayAnimation(self.ShopTips.AllEnter)
end

---收到刷新商品页面
function tbClass:OnReceiveUpdate(tbParam)
    if self.ShopTips:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
        if self.ShopTips.goodsInfo and ShopLogic.GetGoodsInfo(self.ShopTips.goodsInfo.nGoodsId) then
            self.ShopTips:Refresh()
        else
            --关闭商品详情页
            self.ShopTips.goodsInfo = nil
            WidgetUtils.Collapsed(self.ShopTips)
        end
    end

    if tbParam.shopId and tbParam.goodsList then
        local shop = ShopLogic.GetShopInfo(tbParam.shopId)
        if not shop then return end
        local data = {shopId = tbParam.shopId, goodsList = tbParam.goodsList, shopInfo = shop}
        self:ShowTypeWidget(shop.nWidgetType, data)
        if self.tbShopItem[self.SelectShopTab] and self.tbShopItem[self.SelectShopTab].UpdateLabel then
            self.tbShopItem[self.SelectShopTab]:UpdateLabel()
        end
        if shop.tbShopMoneyType then
            self.Money:Init(shop.tbShopMoneyType, tbParam.shopId ~= 1)
        end
    end
end

---根据类型显示模板
function tbClass:ShowTypeWidget(type, data)
    self.WidgetSwitcher:SetActiveWidgetIndex(type - 1)
    local ActiveWidget = self.WidgetSwitcher:GetActiveWidget()
    if ActiveWidget then
        ActiveWidget:Init(data)
    end
    self:PlayAnimation(self.Enter)
    -- if widget.AllEnter then
    --     widget:PlayAnimation(widget.AllEnter)
    -- end
end

---购买商品后刷新页面
function tbClass:OnByGoodsUpdate()
    WidgetUtils.Collapsed(self.ShopTips)

    if not self.SelectShopId then return end
    local data = ShopLogic.GetLocalGoodsList(self.SelectShopId)
    if data then
        self:OnReceiveUpdate(data)
    end
end

---关闭不用模板
function tbClass:CloseWidget()
    for key, name in pairs(self.tbCloseWidgetName) do
        local widget = self[name]
        if widget then
            WidgetUtils.Collapsed(widget)
        end
    end
end

return tbClass
