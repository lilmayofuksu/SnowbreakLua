local tbClass = Class()

function tbClass:LuaTick(DeltaSeconds)
	--[[if self.ParentClass and self.ParentClass.ReceiveTick then
		self.ParentClass:ReceiveTick(DeltaSeconds)
	end]]
	if not IsValid(self.Ability) then
		return
	end
	local CastingSkilId = self.Ability:GetCastingSkillIDInAnim()
	local Mesh = self:GetComponentByClass(UE4.USkeletalMeshComponent)
	if CastingSkilId == 4205101 or CastingSkilId == 4205201 then
		Mesh:SetCollisionResponseToChannel(UE4.ECollisionChannel.ECC_PhysicsBody,UE4.ECollisionResponse.ECR_Ignore)
		Mesh:SetCollisionResponseToChannel(UE4.ECollisionChannel.ECC_Pawn,UE4.ECollisionResponse.ECR_Ignore)
	else
		Mesh:SetCollisionResponseToChannel(UE4.ECollisionChannel.ECC_PhysicsBody,UE4.ECollisionResponse.ECR_Block)
		Mesh:SetCollisionResponseToChannel(UE4.ECollisionChannel.ECC_Pawn,UE4.ECollisionResponse.ECR_Block)
	end
	local AccessoryClassType1 = LoadClass('/Game/Blueprints/Character/Monster/Mon_205/BP_Mon_205_Part01.BP_Mon_205_Part01')
	local Accessory1 = self:GetAccessoryByClass(AccessoryClassType1)
	if IsValid(Accessory1) then
		local AccAbility = Accessory1:GetAbilityComponent()
		if IsValid(AccAbility) then
			self.Part01Health = AccAbility:GetRolePropertieValue(UE4.EAttributeType.Health,0)
			if self.Part01Health <= 0  and not self.Part01HealthDoOnce then
				self.Part01HealthDoOnce = true;
				--local ParticleClass = LoadClass('/Game/Effects/Monster/boss002/e_boss002_skill01_self10_p.e_boss002_skill01_self10_p')
				local ParticleObj =  UE4.UObject.Load('/Game/Effects/Monster/boss002/e_boss002_skill01_self10_p.e_boss002_skill01_self10_p')
				UE4.UGameplayStatics.SpawnEmitterAttached(ParticleObj,Mesh,"Bip001-R-Hand")
				self.Ability:CastSubSkill(4205901,0,self)
			end
		end
	end

	local AccessoryClassType2 = LoadClass('/Game/Blueprints/Character/Monster/Mon_205/BP_Mon_205_Part02.BP_Mon_205_Part02')
	local Accessory2 = self:GetAccessoryByClass(AccessoryClassType2)
	if IsValid(Accessory2) then
		local AccAbility = Accessory2:GetAbilityComponent()
		if IsValid(AccAbility) then
			self.Part02Health = AccAbility:GetRolePropertieValue(UE4.EAttributeType.Health,0)
			if self.Part02Health <= 0  and not self.Part02HealthDoOnce then
				self.Part02HealthDoOnce = true;
				local ParticleObj = UE4.UObject.Load('/Game/Effects/Monster/boss002/e_boss002_skill01_self10_p.e_boss002_skill01_self10_p')
				UE4.UGameplayStatics.SpawnEmitterAttached(ParticleObj,Mesh,"Bip001-L-Hand")
				self.Ability:CastSubSkill(4205901,0,self)
			end
		end
	end

	if self.Ability:GetRolePropertieValue(UE4.EAttributeType.Health,0) == 0 or (self.Part01Health <= 0 and self.Part02Health <= 0) then
		self.Ability:RemoveModifierFormModifierID(4205501)
		if IsValid(self.BuffParticle) then
			self.BuffParticle:Deactivate()
		end
		if IsValid(self) then
			UE4.UWwiseLibrary.PostEventAttachedActor("Stop_Mon205_Base_Loop",self)
		end
	end
end

return tbClass;