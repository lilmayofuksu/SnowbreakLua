local tbClass = Class()

function tbClass:Tick(DeltaSeconds)
	self.Super:Tick(DeltaSeconds)
	local AttachParentActor = self:GetAttachParentActor();
	if not IsValid(AttachParentActor) then
		return
	end
	if not self.GetAbilityComponent then
		return
	end
	local AbilityComponent = self:GetAbilityComponent()
	if not IsValid(AbilityComponent) then
		return
	end
	if AbilityComponent:IsDead() and not self.HasDoOnceCheckDead then
		self.HasDoOnceCheckDead = true;
		UE4.Timer.Add(1,function ( ... )
			local SMC = self:GetComponentByClass(UE4.UStaticMeshComponent)
			if IsValid(SMC) then
				SMC:SetVisibility(false,false)
			end
		end)
	end

	local GameCharacter = AttachParentActor:Cast(UE4.AGameCharacter)
	if not IsValid(GameCharacter) then
		return
	end
	GameCharacter:GetCurrentMontage()
	--蓝图中有Timeline,放弃翻译
end

return tbClass;