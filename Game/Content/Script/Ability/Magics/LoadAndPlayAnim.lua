---@class Magic_LoadAndPlayAnim:Magic
local Magic = Ability.DefineMagic('LoadAndPlayAnim');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local Character = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
    local AnimSeqName = Parameter.Params:Get(1).ParamValue;
    local GroupName = Parameter.Params:Get(2).ParamValue;
    local LoopCount = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(3));

    if Character ~= nil and Character:GetGameAnimInstance() ~= nil then
        Character:GetGameAnimInstance():LoadAnimSequanceAndPlayBySlotGroup(AnimSeqName,GroupName,LoopCount);
    end
    return true;
end


function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    local Character = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
    local AnimSeqName = Parameter.Params:Get(1).ParamValue;
    local GroupName = Parameter.Params:Get(2).ParamValue;

    if Character ~= nil and Character:GetGameAnimInstance() ~= nil then
        Character:GetGameAnimInstance():StopMontageBySlotGroup(GroupName);
    end
    return true;
end

return Magic;