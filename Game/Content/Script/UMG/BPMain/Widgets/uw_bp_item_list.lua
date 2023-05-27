-- ========================================================
-- @File    : uw_bp_item_list.lua
-- @Brief   : bp购买物品
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
end

function tbClass:OnListItemObjectSet(pObj)
    local tbParam = pObj.Data;
   
   self.uw_widgets_item_list:Display(tbParam)

   local iteminfo = UE4.UItem.FindTemplate(tbParam.G, tbParam.D, tbParam.P, tbParam.L)
   if iteminfo then
        WidgetUtils.SelfHitTestInvisible(self.TextBlock_47)
        self.TextBlock_47:SetText(Text(iteminfo.I18N))
   else
        WidgetUtils.Collapsed(self.TextBlock_47)
   end
end

return tbClass