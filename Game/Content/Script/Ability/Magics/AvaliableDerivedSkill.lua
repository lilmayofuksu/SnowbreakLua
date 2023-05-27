---@class Magic_AvaliableDerivedSkill:Magic
local Magic = Ability.DefineMagic('AvaliableDerivedSkill');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    if bKeepEffect == false then
        return true;
    end

    local bActive = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(1));
    local IDs = UE4.UAbilityFunctionLibrary.GetParamInt32ArrayValue(Parameter.Params:Get(2));
    
    if bActive == true then
        AbilityTarget:ActiveDeriveSkillByModifier(Modifier.RunTimeID, IDs);
    else
        AbilityTarget:DeActiveDeriveSkillByModifier(Modifier.RunTimeID, IDs);
    end
    return true;
end

return Magic;