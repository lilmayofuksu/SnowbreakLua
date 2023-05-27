local tbClass = Class()

function tbClass:OnActive()
	--后面死斗逻辑里，存和读都用这个tb  DefendLogic.tbFightDataTpl 

	local tb = {}
	local TaskActor = self:GetGameTaskActor()
	if IsValid(TaskActor) and IsValid(TaskActor.TaskDataComponent) then
		for DataName, _ in pairs(DefendLogic.tbFightDataTpl) do
			tb[DataName] = self:GetSaveValue(DataName,TaskActor)
		end
	end

	DefendLogic.SaveFightData(tb, function() self:Finish() end)
end

function tbClass:GetSaveValue(DataName, ValidTaskActor)
	if DataName == 'Device' then
		local Value = 0;
		local DeviceArray = UE4.UGameplayStatics.GetAllActorsOfClass(self,UE4.AItemSpawner_CanSave)
		for i = 1, DeviceArray:Length() do
            local Device = DeviceArray:Get(i)
            if IsValid(Device) and Device:GetIsValid() then
                Value = SetBits(Value,1,Device.Index,Device.Index)
            end
        end
        return Value;
	elseif DataName == 'PlayerHp' then
		local hpData = 0
		local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
		if controller then
			local lineup = controller:GetPlayerCharacters()
			for i = 1, lineup:Length() do
				local char = lineup:Get(i)
				if char and char.Ability then
					local curHp = char.Ability:GetPropertieValueFromString("Health")
					local maxHp = char.Ability:GetPropertieMaxValueFromString("Health")
					local perHp = (maxHp > 0) and (curHp / maxHp) or 0
					perHp = math.ceil(perHp * 100)
					hpData = SetBits(hpData, perHp, (i-1) * 8 , i * 8 - 1)
				end
			end
		end
		return hpData
	end
	return ValidTaskActor.TaskDataComponent:GetOrAddValue(DataName)
end

function tbClass:OnEnd()

end

return tbClass;