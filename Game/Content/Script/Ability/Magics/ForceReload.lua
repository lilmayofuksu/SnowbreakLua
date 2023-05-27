---@class Magic_ForceReload:Magic
local Magic = Ability.DefineMagic('ForceReload');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local lpCharacter = AbilityTarget:GetOriginCharacter() 
    if not lpCharacter then return true end
    local lpController = lpCharacter:GetCharacterController()
    if not lpController then return true end
    lpController:ForceReload()
    return true;
end



return Magic;