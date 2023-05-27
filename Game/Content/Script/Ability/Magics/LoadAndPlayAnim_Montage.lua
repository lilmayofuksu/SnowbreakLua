---@class Magic_LoadAndPlayAnim_Montage:Magic
local Magic = Ability.DefineMagic('LoadAndPlayAnim_Montage');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local Character = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
    local MontageName = Parameter.Params:Get(1).ParamValue;
    local GroupName = Parameter.Params:Get(2).ParamValue;

    if Character ~= nil and Character:GetGameAnimInstance() ~= nil then
        Character:GetGameAnimInstance():LoadMontageAndPlay(MontageName);
    end
    return true;
end


function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    local Character = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
    local MontageName = Parameter.Params:Get(1).ParamValue;
    local GroupName = Parameter.Params:Get(2).ParamValue;

    if Character ~= nil and Character:GetGameAnimInstance() ~= nil then
        Character:GetGameAnimInstance():StopMontageBySlotGroup(GroupName);
    end
    return true;
end

return Magic;