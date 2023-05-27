-- ========================================================
-- @File    : uw_gacha_gm_item.lua
-- @Brief   : 扭蛋调试
-- ========================================================
---@class tbClass
---@field List UListView
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.ListFactory = Model.Use(self)
end

function tbClass:OnListItemObjectSet(pObj)
    self:DoClearListItems(self.List)
    local tbData = pObj.Data
    local pItem = self.ListFactory:Create(tbData)
    self.List:AddItem(pItem)
end

return tbClass