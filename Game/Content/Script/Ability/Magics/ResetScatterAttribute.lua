---@class Magic_ResetScatterAttribute:Magic
local Magic = Ability.DefineMagic('ResetScatterAttribute');

---@param Modifier UModifier
---@param Parameter table

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)

    if AbilityTarget ~= nil then
        AbilityTarget:ResetScatterRatio();
    end

    return true;
end

return Magic;