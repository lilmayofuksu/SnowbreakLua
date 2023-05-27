local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
	BtnClearEvent(self.SkipAll);
	BtnAddEvent(self.SkipAll,function ()
		local Mode = UE4.UGameplayStatics.GetGameMode(GetGameIns())
		local HouseMode = Mode and Mode:Cast(UE4.AHouseGameMode)
	    if HouseMode then
	    	Mode:SkipAllCameraView()
	    end
	end)

	BtnClearEvent(self.SkipOne);
	BtnAddEvent(self.SkipOne,function ()
		local Mode = UE4.UGameplayStatics.GetGameMode(GetGameIns())
		local HouseMode = Mode and Mode:Cast(UE4.AHouseGameMode)
	    if HouseMode then
	    	Mode:SkipNowCameraView()
	    end
	end)
end

function tbClass:OnOpen()
	
end

function tbClass:OnClose()
	
end

return tbClass;