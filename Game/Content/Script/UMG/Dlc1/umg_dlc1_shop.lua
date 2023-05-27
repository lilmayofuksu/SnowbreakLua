-- ========================================================
-- @File    : umg_dlc1_shop.lua
-- @Brief   : dlc1商店界面
-- ========================================================

local tbClass = Class('UMG.BaseWidget')

function tbClass:OnInit()
    BtnAddEvent(self.btn1, function() self:ShowShop(1) end)
    BtnAddEvent(self.btn2, function() self:ShowShop(2) end)
    self.ShopIdx = 1
end

function tbClass:OnOpen()
    ShopLogic.GetOpenTime()
    self.tbShops = ShopLogic.GetDlcOpenTab()
    ---货币数量改变时刷新列表
    if self.nMoneyChangeEvent then
        EventSystem.Remove(self.nMoneyChangeEvent)
    end
    self.nMoneyChangeEvent = EventSystem.On(Event.CustomAttr, function()
        if not UI.IsOpen('Dlc1Shop') then return end
        if self.ShopId then
            local data = ShopLogic.GetLocalGoodsList(self.ShopId)
            if data then
                self:OnReceiveUpdate(data)
            end
        end

        if self.ShopTips and self.ShopTips:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
            self.ShopTips:UpdatePrice()
        end
    end)

    if self.ShopTips and self.ShopTips:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
        self.ShopTips:Refresh()
    end

    self:PlayAnimation(self.AllEnter)
end

function tbClass:OnClose()
    EventSystem.Remove(self.nMoneyChangeEvent)
end

function tbClass:OnDisable()
    EventSystem.Remove(self.nMoneyChangeEvent)
end

function tbClass:UpdateShopGroup()
    self.tbShops = ShopLogic.GetDlcOpenTab()
    for i = 1, 2 do
        if self.tbShops[i] then
            WidgetUtils.SelfHitTestInvisible(self['Tab'..i])
            self['None'..i]:SetText(Text(self.tbShops[i].sName))
            self['Txtcheck'..i]:SetText(Text(self.tbShops[i].sName))
            if i == self.ShopIdx then self:ShowShop(i) end
        else
            WidgetUtils.Collapsed(self['Tab'..i])
        end
    end
    self:UpdateTab()
end

function tbClass:ShowShop(shopIdx)
    if self.ShopIdx == shopIdx and self.ShopId then return end
    self.ShopIdx = shopIdx
    local tbShop = self.tbShops[shopIdx]
    if not tbShop then return end
    self.ShopId = tbShop.nShopId
    self.nEndTime = tbShop.nEnd
    WidgetUtils.Collapsed(self.ShopTips)
    self.Money:Init(tbShop.tbShopMoneyType, false)
    ShopLogic.GetGoodsList(tbShop.nShopId)
    self:UpdateTab()
    self:UpdateTime()
end

function tbClass:OnReceiveUpdate(tbParam)
    --先关闭商品详情页
    if self.ShopTips and self.ShopTips:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
        self.ShopTips.goodsInfo = nil
        WidgetUtils.Collapsed(self.ShopTips)
    end

    if tbParam.shopId and tbParam.goodsList then
        local shop = ShopLogic.GetShopInfo(tbParam.shopId)
        if not shop then return end
        local data = {shopId = tbParam.shopId, goodsList = tbParam.goodsList, shopInfo = shop}
        self.ShopOrdinary:Init(data)
        if shop.tbShopMoneyType then
            self.Money:Init(shop.tbShopMoneyType, tbParam.shopId ~= 1)
        end
        self:PlayAnimation(self.Enter)
    end
    self:UpdateTab()
end

function tbClass:UpdateTab()
    for idx, shop in ipairs (self.tbShops) do
        if shop.nShopId == self.ShopId then self.ShopIdx = idx end
    end
    for i = 1, 2 do
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self['Check'..i], i == self.ShopIdx)
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self['Txtcheck'..i], i == self.ShopIdx)
    end
end

---打开商品详情页
function tbClass:OpenShopTips(cfg)
    if not self.ShopTips then
        self.ShopTips = WidgetUtils.AddChildToPanel(self.CanvasPanel_0, '/Game/UI/UMG/Shop/Widgets/uw_shop_tips.uw_shop_tips_C', 3)
    end
    if not self.ShopTips then return end
    WidgetUtils.SelfHitTestInvisible(self.ShopTips)
    self.ShopTips:Init(cfg)
end

function tbClass:UpdateTime()
    if not self then return end
    if self.TimerIdx then UE4.Timer.Cancel(self.TimerIdx); self.TimerIdx = nil end
    if not self.nEndTime then return end
    local now = GetTime()
    if self.nEndTime > now then
        local nDay, nHour, nMin, nSec = TimeDiff(self.nEndTime, now)
        if nDay >= 1 then  --大于一天
            self.Days:SetText(string.format("%s%s", nDay, Text("ui.TxtTimeDay")))
        else
            self.Days:SetText(string.format("%02d:%02d:%02d", nHour, nMin, nSec))
        end
    else
        self.Days:SetText(Text("ui.TxtDLC1Over"))
        return
    end
    self.TimerIdx = UE4.Timer.Add(1, function() if self then self:UpdateTime() end end)
end

function tbClass:OnClose()
    if self.TimerIdx then
        UE4.Timer.Cancel(self.TimerIdx)
        self.TimerIdx = nil
    end
end

function tbClass:OnDisable()
    if self.TimerIdx then
        UE4.Timer.Cancel(self.TimerIdx)
        self.TimerIdx = nil
    end
end

return tbClass