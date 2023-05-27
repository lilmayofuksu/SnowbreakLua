local tbClass = Class()

function tbClass:OnTrigger()
    local Chars = nil;
    if self.KillAll then
        Chars = UE4.UGameplayStatics.GetAllActorsOfClass(GetGameIns(),UE4.AGameAICharacter)
    else
        Chars = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(GetGameIns(),UE4.AGameAICharacter,self.Tag)
    end
	for i = 1, Chars:Length() do
        local Char = Chars:Get(i)
        if Char then
        	Char:Leave()
        end
    end
end

return tbClass;