local tbClass = Class()

function tbClass:OnTrigger()
	if self.IsHide then
		local UIWidgets = self:HideAllUI()
		self:SetUIWidgets(UIWidgets)
	else
		local UIWidgets = self:GetUIWidgets()
		self:ShowAllUI(UIWidgets)
	end
end

function tbClass:DealFightUI(IsHide,FightWidget)
	local Root = FightWidget and FightWidget.RootCanvasPanel
	if not Root then
		return
	end
	if IsHide then
		local FightState = UE4.TMap(UE4.int32, UE4.ESlateVisibility)

		local Count = Root:GetChildrenCount();
		for i = 1, Count do
	        local Item = Root:GetChildAt(i)
	        if Item then
	        	FightState:Add(i,Item:GetVisibility())
	            WidgetUtils.Hidden(Item)
	        end
	    end
	    if not self.IncludeJoystick then
	    	WidgetUtils.Visible(FightWidget.Joystick)
	    end
		self:SetFightWidgets(FightState)
	else
		local FightState = self:GetFightWidgets()
		if FightState then
			local Count = Root:GetChildrenCount();
			for i = 1, Count do
		        local Item = Root:GetChildAt(i)
		        local Vi = FightState:Find(i)
		        if Item and Vi then
		        	Item:SetVisibility(Vi)
		        end
		    end
		end
	end
end

return tbClass;