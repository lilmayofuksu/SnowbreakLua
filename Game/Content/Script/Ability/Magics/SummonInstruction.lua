---@class SummonInstruction:Magic
local Magic = Ability.DefineMagic('SummonInstruction');


function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local Target = AbilityTarget;
    local CharacterOwner = Target:GetOwner():Cast(UE4.AGameAICharacter);
    if CharacterOwner ~= nil then
        local InstructionString = Parameter.Params:Get(1).ParamValue; 
        local bEnable = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(2)); 

        CharacterOwner:GameAIInstruction(InstructionString, bEnable);
    end

    return true;
end

function Magic:OnRemove(AbilityTarget, Modifier, Parameter)
    local Target = AbilityTarget;
    local CharacterOwner = Target:GetOwner():Cast(UE4.AGameAICharacter);
    if CharacterOwner ~= nil then
        local InstructionString = Parameter.Params:Get(1).ParamValue; 
        local bEnable = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(2)); 
        CharacterOwner:GameAIInstruction(InstructionString, not bEnable);
    end

    return true;
end

return Magic;