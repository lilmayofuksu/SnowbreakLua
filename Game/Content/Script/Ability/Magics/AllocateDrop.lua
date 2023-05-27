---@class Magic_AllocateDrop:Magic
local Magic = Ability.DefineMagic('AllocateDrop');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    if not AbilityTarget then
        return false
    end
    local AITarget = AbilityTarget:GetOwner():Cast(UE4.AGameAICharacter)
    if not AITarget then
        return false
    end
    local DropID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local pDropSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelDropsManager)
    if pDropSubSys then
        pDropSubSys:AllocateDropToAI(AITarget,DropID)
    end
    return true;
end


function Magic:OnRemove(AbilityTarget, Modifier, Parameter)
    if not AbilityTarget then
        return false
    end
    local AITarget = AbilityTarget:GetOwner():Cast(UE4.AGameAICharacter)
    if not AITarget then
        return false
    end
    local DropID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local pDropSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelDropsManager)
    if pDropSubSys then
        pDropSubSys:RemoveDropFromAI(AITarget,DropID)
    end
    return true;
end

return Magic;