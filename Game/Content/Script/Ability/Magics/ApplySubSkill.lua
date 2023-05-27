---@class Magic_ApplySubSkill:Magic
local Magic = Ability.DefineMagic('ApplySubSkill');


function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local ID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local Launcher = Modifier:GetLauncher();
    local Target = AbilityTarget;
    
    if Target ~= nil then
        Target:CastSubSkill(ID, 1, Target:GetOwner());
    end
   
    return true;
end


function Magic:OnExec(AbilityTarget,Modifier, Parameter, CurOverlaid)
    local ID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local Launcher = Modifier:GetLauncher();
    local Target = AbilityTarget;
    
    if Target ~= nil then
        Target:CastSubSkill(ID, 1, Target:GetOwner());
    end
   
    return true;
end

return Magic;