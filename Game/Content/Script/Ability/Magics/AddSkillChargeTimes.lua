---@class Magic_AddSkillChargeTimes:Magic
local Magic = Ability.DefineMagic('AddSkillChargeTimes');


function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local AddNum = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local SkillID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(2));
    local SkillTag = UE4.FString("");
    if Parameter.Params:Length() > 2 then
        SkillTag = Parameter.Params:Get(3).ParamValue;
    end
    
    AbilityTarget:AddSkillChargeTime(SkillID, AddNum);
    AbilityTarget:AddSkillChargeTimebyTag(SkillTag, AddNum);

    return true;
end


function Magic:OnExec(AbilityTarget,Modifier, Parameter, CurOverlaid)
    local AddNum = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local SkillID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(2));
    local SkillTag = UE4.FString("");
    if Parameter.Params:Length() > 2 then
        SkillTag = Parameter.Params:Get(3).ParamValue;
    end
   
    AbilityTarget:AddSkillChargeTime(SkillID, AddNum);
    AbilityTarget:AddSkillChargeTimebyTag(SkillTag, AddNum);

    return true;
end

return Magic;