local tbClass = Class()

function tbClass:OnTrigger()
	local pc = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
	if IsValid(pc) then
		if self.ByIndex then
			pc:SwitchPlayerCharacter(self.Index - 1)
		else
			if self.IsPre then
				pc:SwitchPrePlayerCharacter(true,false)
			else
				pc:SwitchNextPlayerCharacter(false,true,false)
			end
		end
	end
end

return tbClass;