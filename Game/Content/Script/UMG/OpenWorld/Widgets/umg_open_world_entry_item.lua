-- ========================================================
-- @File    : umg_open_world_entry_item.lua
-- @Brief   : 开放世界进入条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
   BtnAddEvent(self.BtnSelect, function() 
      self.tbParam.onSelect()
   end)
   print("entry item Construct");
end

function tbClass:OnListItemObjectSet(pObj)
   local tbParam = pObj.Data
   self.tbParam = tbParam

   print("entry item OnListItemObjectSet", self, tbClass);
   
   tbParam.onRefresh = function(id) 
      if id == tbParam.id then
         self:OnRefresh()
      end
   end
   self:OnRefresh()
end

function tbClass:OnRefresh()
   self.Name:SetText(self.tbParam.name)
   self.ProgressValue:SetText(string.format("%.2f%%", self.tbParam.progress))

   if self.tbParam.isSelect then 
      WidgetUtils.Visible(self.Selected)
   else 
      WidgetUtils.Collapsed(self.Selected)
   end
end

return tbClass