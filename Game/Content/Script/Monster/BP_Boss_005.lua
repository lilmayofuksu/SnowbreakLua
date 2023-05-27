local tbClass = Class()

function tbClass:LuaTick()
	local AccessoryClassType1 = LoadClass('/Game/Blueprints/Character/Monster/Mon_205/BP_Mon_205_Part01.BP_Mon_205_Part01')
	local Accessory1 = self:GetAccessoryByClass(AccessoryClassType1)
	if IsValid(Accessory1) then
		local AccAbility = Accessory1:GetAbilityComponent()
		if IsValid(AccAbility) then
			self.Part01_01Health = AccAbility:GetRolePropertieValue(UE4.EAttributeType.Health,0)
			if self.Part01_01Health <= 0  and not self.Part01_01HealthDoOnce then
				self.Part01_01HealthDoOnce = true;
				self:EffectOnPartDead01()
			end
		end
	end

	--用事件做了，也废弃
end

function tbClass:RegisterAccessoryDeathEvent(path,func,index)
	local AccessoryClassType = LoadClass(path)
	local Accessory1 = self:GetAccessoryByClass(AccessoryClassType)
	if IsValid(Accessory1) then
		local AccAbility = Accessory1:GetAbilityComponent()
		if IsValid(AccAbility) then
			self.Part01_01Health = AccAbility:GetRolePropertieValue(UE4.EAttributeType.Health,0)
			if self.Part01_01Health <= 0  and not self['PartDoOnce'..index] then
				self['PartDoOnce'..index] = true;
				self:EffectOnPartDead01()
			end
		end
	end
end

return tbClass;