---@class Magic_GMGod:Magic
local Magic = Ability.DefineMagic('GMGod');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    AbilityTarget:SetGodFather(true) 
    return true;
end


function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    AbilityTarget:SetGodFather(false) 
    return true;
end

return Magic;