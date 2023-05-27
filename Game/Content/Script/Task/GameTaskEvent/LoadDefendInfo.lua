local tbClass = Class()

function tbClass:OnTrigger()
	local tbNeedLoad = DefendLogic.GetFightData(true)
	local TaskActor = self:GetGameTaskActor()
	if IsValid(TaskActor) and IsValid(TaskActor.TaskDataComponent) then
		for DataName, Value in pairs(tbNeedLoad) do
			TaskActor.TaskDataComponent:SetValue(DataName,Value)
			self:OnValueLoad(DataName,Value,TaskActor)
		end
	end
	--self:OnValueLoad('Device',3) 
end

function tbClass:OnValueLoad(DataName, Value, ValidTaskActor)
	if DataName == 'Device' then
		local DeviceArray = UE4.UGameplayStatics.GetAllActorsOfClass(self,UE4.AItemSpawner_CanSave)
		for i = 1, DeviceArray:Length() do
            local Device = DeviceArray:Get(i)
            if IsValid(Device) then
            	if (GetBits(Value,Device.Index,Device.Index) == 1 or Value == -1) then
	                Device:ReSpawn(true);
	            else
	            	Device:ReSpawn(false);
	            end
	        end
        end
	elseif DataName == "PlayerHp" then
		local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
		if controller then
			local lineup = controller:GetPlayerCharacters()
			for i = 1, lineup:Length() do
				local char = lineup:Get(i)
				if char and char.Ability then
					local perHp = Value == -1 and 100 or GetBits(Value, (i-1) * 8, i * 8 - 1)
					perHp = perHp / 100
					local maxHp = char.Ability:GetPropertieMaxValueFromString("Health")
					char.Ability:SetPropertieValueFromString("Health", maxHp * perHp)
					if perHp <= 0 then
						local Controller = char:GetCharacterController()
						if Controller then
							Controller:SwitchNextPlayerCharacter(true)
						end
					end
				end
			end
		end
	end

	--[[if DataName == 'Wave' then
		--获取死斗等级
		local NowDefendMonsLevel = 2
		ValidTaskActor.TaskDataComponent.SetValue('DefendMonsLevelName',NowDefendMonsLevel)
	end--]]
end

return tbClass;