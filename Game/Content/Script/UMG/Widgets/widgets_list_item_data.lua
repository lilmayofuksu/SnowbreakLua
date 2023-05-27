-- ========================================================
-- @File    : uw_widgets_list_item_data.lua
-- @Brief   : 物品列表展示所用的数据对象
-- ========================================================

local tbClass = Class("UMG.SubWidget")

---初始化
---@param tbParam table<UE4.UItem , function, boolean> 初始化数据,格式为
function tbClass:OnInit(tbParam)
    self.pItem = tbParam.pItem;
    self.OnSelect = tbParam.OnSelect;
    self.bSelected = tbParam.bSelected;
end

function tbClass:SetSelect(bSelect)
    self.bSelected = bSelect;
    EventSystem.TriggerTarget(self, "ITEM_SELECT");
end

return tbClass