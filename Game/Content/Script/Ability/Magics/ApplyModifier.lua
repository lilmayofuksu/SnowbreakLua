---@class Magic_ApplyModifier:Magic
local Magic = Ability.DefineMagic('ApplyModifier');


function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local ID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local bNeedControl = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(2));
    local Launcher = Modifier:GetLauncher();
    local Target = AbilityTarget;
   
    local RID = UE4.UModifier.MakeModifier(ID, Modifier, Launcher, Target, Modifier.EmitterOwner, Modifier.ApplyLocation, Modifier.OriginLocation);
    if bNeedControl == true then
        Modifier.SubModifierRunTimeID:AddUnique(ID);
    end
    return true;
end

function Magic:OnExec(AbilityTarget,Modifier, Parameter, CurOverlaid)
    local ID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local bNeedControl = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(2));
    local Launcher = Modifier:GetLauncher();
    local Target = AbilityTarget;
   
    local RID = UE4.UModifier.MakeModifier(ID, Modifier, Launcher, Target, Modifier.EmitterOwner, Modifier.ApplyLocation, Modifier.OriginLocation);
    if bNeedControl == true then
        Modifier.SubModifierRunTimeID:AddUnique(ID);
    end
    return true;
end

function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    for i = 1, Modifier.SubModifierRunTimeID:Length() do
        local RID = Modifier.SubModifierRunTimeID:Get(i);
        AbilityTarget:RemoveModifierFromRunTimeID(RID);
    end
end

return Magic;