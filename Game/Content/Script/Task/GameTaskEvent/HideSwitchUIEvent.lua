local tbClass = Class()

function tbClass:OnTrigger()
	local pc = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
	if IsValid(pc) then
		local ui = UI.GetUI('Fight')
		if self.IsHide then
			pc:ClearKeyboardInput(UE4.EPCKeyboardType.SwitchPre);
			pc:ClearKeyboardInput(UE4.EPCKeyboardType.SwitchNext);
			pc:ClearKeyboardInput(UE4.EPCKeyboardType.Switch1);
			pc:ClearKeyboardInput(UE4.EPCKeyboardType.Switch2);
			pc:ClearKeyboardInput(UE4.EPCKeyboardType.Switch3);

			if ui then
				WidgetUtils.Collapsed(ui.PlayerSelect)
			end
		else
			pc:SetKeyboardInput(UE4.EPCKeyboardType.SwitchPre);
			pc:SetKeyboardInput(UE4.EPCKeyboardType.SwitchNext);
			pc:SetKeyboardInput(UE4.EPCKeyboardType.Switch1);
			pc:SetKeyboardInput(UE4.EPCKeyboardType.Switch2);
			pc:SetKeyboardInput(UE4.EPCKeyboardType.Switch3);

			if ui then
				WidgetUtils.Visible(ui.PlayerSelect)
			end
		end
	end
end

return tbClass;