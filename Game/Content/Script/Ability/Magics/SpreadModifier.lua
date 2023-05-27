---@class Magic_SpreadModifier:Magic
local Magic = Ability.DefineMagic('SpreadModifier');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)

    local AddID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1)); 
    local ClearID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(2)); 
    
    Modifier:SpreadModifier(AbilityTarget , AddID , ClearID);
    return true;
end


function Magic:OnExec(AbilityTarget,Modifier, Parameter, CurOverlaid)
    local AddID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1)); 

    if Parameter.Params:Length() >= 2 then
        local ClearID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(2)); 
    end

    Modifier:SpreadModifier(AbilityTarget , AddID , ClearID);
    return true;
end

return Magic;