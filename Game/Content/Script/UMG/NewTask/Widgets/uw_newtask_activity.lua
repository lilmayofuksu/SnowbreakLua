-- ========================================================
-- @File    : umg_newtask_activity.lua
-- @Brief   : 新手7天乐子说明widget(新增bp使用，待更新为通用(名字:Info))
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
end

--新增通用调用
function tbClass:OnOpen(key,closeFunc)
	if not closeFunc then
		closeFunc = function() UI.Close(self)  end
	end

	self:SetInfo(key,closeFunc)
end

--7天乐调用
function tbClass:SetInfo(key,closeFunc)
	if key then	
		WidgetUtils.SelfHitTestInvisible(self.ListInfo)
		self.TxtDetail:SetContent(Text(key))
	end

	self.TxtTitle:SetText(Text("ui.TxtGachaRateTitle3"))

	BtnClearEvent(self.BtnClose)
	BtnAddEvent(self.BtnClose,closeFunc)

	BtnClearEvent(self.BtnBottom)
	BtnAddEvent(self.BtnBottom,closeFunc)
end

return tbClass;