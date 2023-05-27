-- ========================================================
-- @File	: Shop/BP_RandomShop.lua
-- @Brief	: 游戏战斗内随机商店
-- ========================================================

local BP_RandomShop = Class()

function BP_RandomShop:ReceiveActorBeginOverlap()
    local InteractiveMode = self:GetInteractiveMode();
    local shopUI = {'BufferShop', 'BufferShopChoose', 'BufferShopText'};
    if (InteractiveMode < #shopUI) then

        self.tbParams = {uiName = shopUI[InteractiveMode + 1]}
        EventSystem.Trigger(Event.OnInteractListAddItem, self.InteractWidgetClass, 1, self)

        print('BP_RandomShop', InteractiveMode, #shopUI, UI.Open);
        --UI.Open(shopUI[InteractiveMode + 1]);
    end
end
 
function BP_RandomShop:ReceiveActorEndOverlap(OtherActor)
    local InteractiveMode = self:GetInteractiveMode();
    local shopUI = {'BufferShop', 'BufferShopChoose', 'BufferShopText'};
    if (InteractiveMode < #shopUI) then
        EventSystem.Trigger(Event.EndOverlapRandomShop, self)
        UI.CloseByName(shopUI[InteractiveMode + 1], nil, false);
    end
end

return BP_RandomShop
