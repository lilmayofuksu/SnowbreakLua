---@class Magic_HideWeapon:Magic
local Magic = Ability.DefineMagic('HideWeapon');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local Character = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
    if Character ~= nil and Character:GetWeapon() ~= nil then
        Character:GetWeapon():SetActorHiddenInGame(true);
    end
    return true;
end


function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    local Character = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
    if Character ~= nil and Character:GetWeapon() ~= nil then
        Character:GetWeapon():SetActorHiddenInGame(false);
    end
    return true;
end

return Magic;