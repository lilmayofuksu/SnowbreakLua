-- ========================================================
-- @File    : uw_house_interactlist.lua
-- @Brief   : 交互列表
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:RegisterEvent(
        Event.OnInteractListAddItem,
        function(WidgetClass, Order, InItemOwner, ShowText)
            -- if self.ListInteractItems:GetChildrenCount() > 0 then
            --     self.ItemOwner = InItemOwner
            --     return
            -- end
            self:AddInteractItem(WidgetClass, Order, InItemOwner, ShowText)
        end
    )
end

return tbClass
