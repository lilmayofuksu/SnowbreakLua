local tbClass = Class('UMG.SubWidget')

function tbClass:Initialize()
	self:SetCustomEvent(function ()
		UI.CloseTop()
	end,function ()
        GoToMainLevel()
    end)
end

function tbClass:SetCustomEvent(BackEvent,MainEvent)
	if BackEvent then
		BtnClearEvent(self.BtnContinue)
		BtnAddEvent(self.BtnContinue,BackEvent)
	end

	if MainEvent then
		BtnClearEvent(self.BtnExit)
		BtnAddEvent(self.BtnExit,MainEvent)
	end
end

function tbClass:SetShowExitBtn(bShow)
	if not bShow then
		WidgetUtils.Collapsed(self.BtnExit)
	else
		WidgetUtils.Visible(self.BtnExit)
	end
end

return tbClass;