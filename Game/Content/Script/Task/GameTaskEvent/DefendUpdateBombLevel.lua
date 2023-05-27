local tbClass = Class()

function tbClass:OnTrigger( ... )
	local Bombs = UE4.UGameplayStatics.GetAllActorsOfClass(GetGameIns(),UE4.AExplosiveActorBase)
	for i=1,Bombs:Length() do
		local Bomb = Bombs:Get(i)
		if IsValid(Bomb) and Bomb.InitAbilityComponent then
			Bomb:InitAbilityComponent()
		end
	end
end

return tbClass