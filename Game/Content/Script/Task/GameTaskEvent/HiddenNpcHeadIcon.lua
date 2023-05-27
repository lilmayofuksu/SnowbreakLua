local tbClass = Class()

function tbClass:OnTrigger()
	local Chars = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(self,UE4.AGameAICharacter,self.Tag)
	for i = 1, Chars:Length() do
        local Char = Chars:Get(i)
        if IsValid(Char) then
        	Char:NotifyFightUmgTips(self.IsShow)
        end
    end
end

return tbClass