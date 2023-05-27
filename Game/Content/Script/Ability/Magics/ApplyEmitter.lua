---@class Magic_ApplySubSkill:Magic
local Magic = Ability.DefineMagic('ApplySubSkill');


function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local ID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local Launcher = Modifier:GetLauncher();
    local Target = AbilityTarget;
    
    local EmitterInfo = UE4.FEmitterInfo();
    UE4.UAbilityComponentBase.LoadEmitterStatic(ID, EmitterInfo, Launcher);
    local Querier = UE4.UAbilityFunctionLibrary.MakeQueryResult_AdjustToTarget(Target:GetOwner(), UE4.EApplyLocationType.Center);
    UE4.USkillEmitter.ApplyEffectToActor(EmitterInfo, Launcher, Target, Modifier.ApplyLocation, Modifier.OriginLocation, Modifier:GetLevel());
   
    return true;
end


function Magic:OnExec(AbilityTarget,Modifier, Parameter, CurOverlaid)
    local ID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local Launcher = Modifier:GetLauncher();
    local Target = AbilityTarget;
    
    local EmitterInfo = UE4.FEmitterInfo();
    UE4.UAbilityComponentBase.LoadEmitterStatic(ID, EmitterInfo, Launcher);
    local Querier = UE4.UAbilityFunctionLibrary.MakeQueryResult_AdjustToTarget(Target:GetOwner(), UE4.EApplyLocationType.Center);
    UE4.USkillEmitter.ApplyEffectToActor(EmitterInfo, Launcher, Querier, Modifier.ApplyLocation, Modifier.OriginLocation, Modifier:GetLevel());
   
    return true;
end

return Magic;