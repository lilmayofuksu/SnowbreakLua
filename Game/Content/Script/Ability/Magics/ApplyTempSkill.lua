---@class Magic_ApplyTempSkill:Magic
local Magic = Ability.DefineMagic('ApplyTempSkill');


function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    --- Param1 : 临时技能位置
    --- Param2 : 临时技能ID
    --- Param3 : 临时技能持续时间
    --- Param4 : 前置CD

    local Index = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1))
    local SkillID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(2))
    local ActiveTime = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(3))
    local PreCD = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(4))

    local Ability = AbilityTarget;
    
    if Ability ~= nil then
        Ability:ReplaceSkillAtIndex(Index , SkillID , ActiveTime, Modifier:GetID());
    end

    Ability:ChangeSkillCD(SkillID,PreCD);
    return true;
end

return Magic;