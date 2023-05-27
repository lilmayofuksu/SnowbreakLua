---@class Magic_ReplaceCharAnimSeq:Magic
local Magic = Ability.DefineMagic('ReplaceCharAnimSeq');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local Character = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
    local OldAnimSeqName = Parameter.Params:Get(1).ParamValue;
    local NewAnimSeqName = Parameter.Params:Get(2).ParamValue;
    local bLoadAnim_External = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(3));
    
    if Character ~= nil and Character:GetGameAnimInstance() ~= nil then
        Character:GetGameAnimInstance():ReplaceAnimSequenceByVariableName(OldAnimSeqName,NewAnimSeqName,bLoadAnim_External);
    end
    return true;
end


function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    local Character = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
    local OldAnimSeqName = Parameter.Params:Get(1).ParamValue;
    local NewAnimSeqName = Parameter.Params:Get(2).ParamValue;

    if Character ~= nil and Character:GetGameAnimInstance() ~= nil then
        Character:GetGameAnimInstance():ReplaceAnimSequenceByVariableName(OldAnimSeqName,OldAnimSeqName,false);
    end
    return true;
end

return Magic;