local tbClass = Class()

function tbClass:OnTrigger()
	local BirdClass = UE4.UClass.Load("/Game/Characters/Npc/npc601/BP_Npc601_New.BP_Npc601_New")
	local World = GetGameIns():GetWorld()
	if not World then
		return
	end
	local SpawnParam = UE4.FActorSpawnParameters()
	SpawnParam.SpawnCollisionHandlingOverride = UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn;
	local pc = UE4.UGameplayStatics.GetPlayerController(World, 0)
	if IsValid(pc) then
		print("测试飞鸟",BirdClass,pc,Bird)
		local Bird = World:SpawnActor(BirdClass,pc:GetTransform(),SpawnParam)
		if IsValid(Bird) then
			Bird:SetFollowTarget(pc);
		end
	end
	--FMath::RInterpTo( const FRotator& Current, const FRotator& Target, float DeltaTime, float InterpSpeed)
end

return tbClass