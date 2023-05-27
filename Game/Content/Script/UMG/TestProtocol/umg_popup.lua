-- ========================================================
-- @File    : umg_popup.lua
-- @Brief   : 协议
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
	self.BtnUnable:SetVisibility(UE4.ESlateVisibility.Collapsed)
	self.BtnOk:SetVisibility(UE4.ESlateVisibility.Visible)
    BtnAddEvent(self.BtnOk, function()
    	UE4.UUserSetting.SetBool('ProtocolAgree', true);
    	UE4.UUserSetting.Save();
    	UI.Close(self)
    end)
    BtnAddEvent(self.BtnNo, function()
    	UE4.UGameLibrary.RequestExit();
    end)
    BtnAddEvent(self.BtnUnable, function()
     	UI.ShowTip('ui.TxtTips01')
    end)
end

function tbClass:CreateTimer()
	UE4.Timer.Add(1, function()
		if not UI.IsOpen('TestProtocol') then return end
    	local bCanAgree = self.ScrollBox_193:GetScrollOffset() == self.ScrollBox_193:GetScrollOffsetOfEnd()
    	if bCanAgree then
    		self.BtnUnable:SetVisibility(UE4.ESlateVisibility.Collapsed)
	    	self.BtnOk:SetVisibility(UE4.ESlateVisibility.Visible)
    	else
    		self:CreateTimer()
    	end
    end)
end

function tbClass:OnOpen(pCallBack)
	-- self:CreateTimer()
	self.pCallBack = pCallBack
end

function tbClass:OnClose()
	if self.pCallBack then self.pCallBack() end
end

return tbClass