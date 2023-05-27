-- ========================================================
-- @File    : ActiveOnlineShop.lua
-- @Brief   : 激活联机buff商店
-- @Author  :
-- @Date    :
-- ========================================================
---@class ActiveOnlineShop : GameTaskEvent
local ActiveOnlineShop = Class()

function ActiveOnlineShop:OnTrigger()
    if self.ShopId and self.ShopState then
        EventSystem.TriggerToCpp("NotifyBufferShopState", self.ShopId, self.ShopState)
        --[[local shops = UE4.UGameplayStatics.GetAllActorsOfClass(self,UE4.ABufferShop)
        for i = 1, shops:Length() do
            local shop = shops:Get(i)
            if shop:GetShopId() == self.ShopId then
                UE4.Timer.Add(shop.ShowTipTime,function ()
                    if self then
                        EventSystem.TriggerToCpp("NotifyBufferShopHideTip", self.ShopId)
                    end
                end)
            end
        end]]
    end
end

return ActiveOnlineShop
