local tbClass = Class()

function tbClass:OnActive()

	local TaskActor = self:GetGameTaskActor();
	if IsValid(TaskActor) and IsValid(TaskActor.TaskDataComponent) then
		local MonsterWaveNum = TaskActor.TaskDataComponent:GetOrAddValue('MonsterWave')
		if MonsterWaveNum <= 1 then
			self:Finish()
			return
		end
	end

	local tbParams = {}

	tbParams.Actions = self.Actions;
	tbParams.TxtKeys = self.TxtKeys;
	tbParams.MoneyNums = self.MoneyNums;
	tbParams.ChooseContinue = function ()
		self:ChooseContinue()
	end;
	tbParams.ChooseExit = function ()
		self:ChooseExit()
	end 
	tbParams.TaskActor = self:GetGameTaskActor();
	tbParams.Node = self;

	UI.Open('DefendShop',tbParams)

	UE4.UGameplayStatics.SetGamePaused(self, true)

	local pc = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
	if IsValid(pc) then
		pc:ClearKeyboardInput(UE4.EPCKeyboardType.SwitchPre);
		pc:ClearKeyboardInput(UE4.EPCKeyboardType.SwitchNext);
		pc:ClearKeyboardInput(UE4.EPCKeyboardType.Switch1);
		pc:ClearKeyboardInput(UE4.EPCKeyboardType.Switch2);
		pc:ClearKeyboardInput(UE4.EPCKeyboardType.Switch3);
	end
end

function tbClass:ChooseContinue()
	UI.Close('DefendShop')
	UE4.UGameplayStatics.SetGamePaused(self, false)
	self:Finish()
end

function tbClass:OnEnd()
	local pc = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
	if IsValid(pc) then
		pc:SetKeyboardInput(UE4.EPCKeyboardType.SwitchPre);
		pc:SetKeyboardInput(UE4.EPCKeyboardType.SwitchNext);
		pc:SetKeyboardInput(UE4.EPCKeyboardType.Switch1);
		pc:SetKeyboardInput(UE4.EPCKeyboardType.Switch2);
		pc:SetKeyboardInput(UE4.EPCKeyboardType.Switch3);
	end
end

function tbClass:ChooseExit()
	UE4.UGameplayStatics.SetGamePaused(self, false)
	local pTaskActor = self:GetGameTaskActor()
	if pTaskActor then
		pTaskActor:LevelFinishBroadCast(UE4.ELevelFinishResult.Success, UE4.ELevelFailedReason.ManualExit)
	else
		Launch.End()
	end
end

return tbClass;