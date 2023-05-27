-- ========================================================
-- @File    : umg_open_world_map_tip.lua
-- @Brief   : 开放世界tip
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
   BtnAddEvent(self.BtnDetail, function() 
      if self.onClickDetail then self.onClickDetail(self) end 
   end)

   BtnAddEvent(self.BtnTrans, function() 
      if self.onClickTrans then self.onClickTrans(self) end 
   end)
end

function tbClass:SetClickDetailCallback(callback)
   self.onClickDetail = callback
end

function tbClass:SetClickTransCallback(callback)
   self.onClickTrans = callback
end

function tbClass:SetName(name)
   self.Name:SetText(name)   
end

function tbClass:SetId(id)
   self.id = id
end

function tbClass:ShowStyleTask()
   WidgetUtils.Visible(self.Task)
   WidgetUtils.Collapsed(self.Player)
   WidgetUtils.Collapsed(self.Trans)
end

function tbClass:ShowStylePlayer()
   WidgetUtils.Collapsed(self.Task)
   WidgetUtils.Collapsed(self.Trans)
   WidgetUtils.Visible(self.Player)
end

function tbClass:ShowStyleTransPoint()
   WidgetUtils.Collapsed(self.Task)
   WidgetUtils.Collapsed(self.Player)
   WidgetUtils.Visible(self.Trans)
end

function tbClass:SetTransColor(color)
   self.TransBack:SetColorAndOpacity(color)
end

function tbClass:SetPlayerAngle(angle)
   self.PlayerDir:SetRenderTransformAngle(angle);
end

return tbClass