---@class Magic_ReleaseAimAction:Magic
local Magic = Ability.DefineMagic('ReleaseAimAction');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    UE4.AGamePlayerController.StandardReleaseAimAction()
    return true;
end

return Magic;