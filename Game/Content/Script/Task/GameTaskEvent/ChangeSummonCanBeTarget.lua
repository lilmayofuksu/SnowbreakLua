local tbClass = Class()

function tbClass:OnTrigger()
	local Summons = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(GetGameIns(),UE4.AGameSummon,self.Tag)
	for i=1,Summons:Length() do
		local Sum = Summons:Get(i)
		if IsValid(Sum) then
			Sum.bCanBeTarget = self.CanBeTarget;
		end
	end
end

return tbClass;