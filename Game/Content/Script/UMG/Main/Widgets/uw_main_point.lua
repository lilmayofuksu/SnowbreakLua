-- ========================================================
-- @File    : uw_main_point.lua
-- @Brief   : banner navi
-- ========================================================
---@class tbClass : UUserWidget
---@field Content UWrapBox
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.SelectBtn, function()
    	if self.OnClick then 
    		self.OnClick() 
    	end
    end)
end

function tbClass:OnListItemObjectSet(InObj)
    self:Set(InObj.Data)
end

function tbClass:Set(Data)
    self.OnClick = Data.OnClick
    Data.InObj = self
    self:Update(Data.Light)
end

function tbClass:Update(bCheck)
	if bCheck then
		WidgetUtils.SelfHitTestInvisible(self.Check)
		WidgetUtils.Collapsed(self.Uncheck) 
	else
		WidgetUtils.Collapsed(self.Check)
		WidgetUtils.SelfHitTestInvisible(self.Uncheck) 
	end
end

return tbClass
