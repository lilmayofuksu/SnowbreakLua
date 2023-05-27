---@class Magic_AddEnmity:Magic
local Magic = Ability.DefineMagic('AddEnmity');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local EnmityValue = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(1));
    local Range = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(2));
    
    local AICharacters = UE4.UGameplayStatics.GetAllActorsOfClass(AbilityTarget, UE4.AGameAICharacter)
    for i = 1, AICharacters:Length() do
        local AICharacter = AICharacters:Get(i);
        local LocationOffset = AbilityTarget:GetOwner():K2_GetActorLocation() - AICharacter:K2_GetActorLocation()
        local Length = LocationOffset:Size();
        local IsEnermy = UE4.UAbilityFunctionLibrary.IsEnermy(AICharacter, AbilityTarget:GetOwner())

        if Length < Range and IsEnermy == true then
            AbilityTarget:AddEnmity(AICharacter.Ability, EnmityValue, UE4.EEnmityType.Sight);
        end
    end
    return true;
end


function Magic:OnExec(AbilityTarget,Modifier, Parameter, CurOverlaid)
    local EnmityValue = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(1));
    local Range = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(2));

    local AICharacters = UE4.UGameplayStatics.GetAllActorsOfClass(AbilityTarget, UE4.AGameAICharacter)
    for i = 1, AICharacters:Length() do
        local AICharacter = AICharacters:Get(i);
        local LocationOffset = AbilityTarget:GetOwner():K2_GetActorLocation() - AICharacter:K2_GetActorLocation();
        local Length = LocationOffset:Size();
        local IsEnermy = UE4.UAbilityFunctionLibrary.IsEnermy(AICharacter, AbilityTarget:GetOwner())

        if Length < Range and IsEnermy == true then
            AbilityTarget:AddEnmity(AICharacter.Ability, EnmityValue, UE4.EEnmityType.Sight);
        end
    end
    return true;
end

return Magic;