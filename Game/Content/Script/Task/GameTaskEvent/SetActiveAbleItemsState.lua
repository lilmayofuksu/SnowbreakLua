local tbClass = Class()

function tbClass:OnTrigger()
	local Items = UE4.UGameplayStatics.GetAllActorsWithInterface(GetGameIns(),UE4.UActiveAble)
	for i = 1, Items:Length() do
        local Item = Items:Get(i)
        if Item and Item:ActorHasTag(self.Tag) then
        	Item:SetActive(self.Active)
        end
    end
end

return tbClass;