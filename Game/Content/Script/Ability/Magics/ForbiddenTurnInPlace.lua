---@class Magic_ForbiddenTurnInPlace:Magic
local Magic = Ability.DefineMagic('ForbiddenTurnInPlace');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local Character = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);

    if Character ~= nil and Character:GetGameAnimInstance() ~= nil then
        Character:GetGameAnimInstance():SetForbiddenTriggerTurnInPlace(true);
    end
    return true;
end


function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    local Character = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);

    if Character ~= nil and Character:GetGameAnimInstance() ~= nil then
        Character:GetGameAnimInstance():SetForbiddenTriggerTurnInPlace(false);
    end
    return true;
end

return Magic;