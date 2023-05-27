-- ========================================================
-- @File    : umg_shop2.lua
-- @Brief   : 商店2界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.Factory = Model.Use(self)
    self:RegisterEvent(Event.NotifyShopData, function(tbParam) self:NotifyShopData(tbParam) end)
    self:RegisterEvent(Event.NotifyShopRefresh, function(tbParam) self:NotifyShopRefresh(tbParam) end) 
end

--[[
tbParam = 
{
    shopId = 1,         -- 商店id    
--    tbShopIds = {},     -- 所有需要显示的商店
}
--]]
function tbClass:OnOpen(tbParam)
    if tbParam then
        self.tbParam = tbParam
    end

    self:UpdateTab()
    WidgetUtils.Collapsed(self.ShopTips)
    ShopLogic.GetGoodsList(self.tbParam.shopId)
    Audio.PlayVoices("EntryShop")
end

function tbClass:OnClose()
    Audio.PlayVoices("ExitShop")

    for _, config in ipairs(self.tbGoods) do 
        config.refresh = nil;
        config.onSelect = nil;
    end
end 

-- 通知商店更新
function tbClass:NotifyShopData(tbParam)
    if tbParam.shopId ~= self.tbParam.shopId then return end

    self.tbGoods = ShopLogic.Sort(tbParam.goodsList)
    self:DoClearListItems(self.Items)
    for _, config in ipairs(self.tbGoods) do 
        config.selected = false
        config.refresh = nil
        config.onSelect = function() self:OnSelect(config) end
        local obj = self.Factory:Create(config)
        self.Items:AddItem(obj)
    end

    if #self.tbGoods > 0 then 
        self.tbGoods[1].onSelect()
    end
    self:UpdateMoney()
end

--- 购买道具后刷新商店
function tbClass:NotifyShopRefresh(tbParam)
    for _, tb in ipairs(self.tbGoods) do 
        if tb.refresh then
            tb.refresh(tb)
        end
    end
    self.ShopTips:Refresh()
    self:UpdateMoney()
end

-- 更新tab
function tbClass:UpdateTab()
    self:DoClearListItems(self.ListTab)
    local tbParam = {shopId = self.tbParam.shopId}
    local obj = self.Factory:Create(tbParam)
    self.ListTab:AddItem(obj)
end

-- 选中
function tbClass:OnSelect(config)
    for _, tb in ipairs(self.tbGoods) do 
        tb.selected = tb == config
        if tb.refresh then
            tb.refresh(tb)
        end
    end

    WidgetUtils.Visible(self.ShopTips)
    self.ShopTips:Init(config)
end

-- 更新货币
function tbClass:UpdateMoney()
    local shop = ShopLogic.GetShopInfo(self.tbParam.shopId)
    self.Money:Init(shop.tbShopMoneyType, true)
end



return tbClass
