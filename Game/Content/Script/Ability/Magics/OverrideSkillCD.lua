---@class Magic_OverrideSkillCD:Magic
local Magic = Ability.DefineMagic('OverrideSkillCD');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    local SkillIDs = UE4.UAbilityFunctionLibrary.GetParamInt32ArrayValue(Parameter.Params:Get(1));
    local NewSkillCDs = UE4.UAbilityFunctionLibrary.GetParamfloatArrayValue(Parameter.Params:Get(2));
    local UsePercentChange = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(3));
    local SkillTag = UE4.FString("");
    if Parameter.Params:Length() > 3 then
        SkillTag =  Parameter.Params:Get(4).ParamValue;
    end

    if NewSkillCDs:Length() < 1 then
        return
    end

    if AbilityTarget ~= nil then
        if UE4.UKismetStringLibrary.IsEmpty(SkillTag) == false then
            local SetCD = NewSkillCDs:Get(1);
            AbilityTarget:SetSkillCurrentCDByTagName(SkillTag, SetCD,UsePercentChange);
        else
            for i = 1, SkillIDs:Length() do
                local SetCD = NewSkillCDs:Get(1);
                if NewSkillCDs:Length() < i then
                    SetCD = NewSkillCDs:Get(NewSkillCDs:Length());
                else
                    SetCD = NewSkillCDs:Get(i);
                end
                print("Skill ID : ", SkillIDs:Get(i), "SetCD is : ", SetCD)
                AbilityTarget:SetSkillCurrentCD(SkillIDs:Get(i), SetCD,UsePercentChange);
            end
        end
    end
    return true;
end


function Magic:OnRemove(AbilityTarget, Modifier, Parameter)

    local SkillIDs = UE4.UAbilityFunctionLibrary.GetParamInt32ArrayValue(Parameter.Params:Get(1));
    local SkillTag = UE4.FString("");
    if Parameter.Params:Length() > 3 then
        SkillTag =  Parameter.Params:Get(4).ParamValue;
    end
    if AbilityTarget ~= nil then
        if UE4.UKismetStringLibrary.IsEmpty(SkillTag) == false then
            AbilityTarget:ResetSkillCurrentCDByTagName(SkillTag);
        else
            for i = 1, SkillIDs:Length() do
                AbilityTarget:ResetSkillCurrentCD(SkillIDs:Get(i));
            end
        end
    end
    return true;
end

return Magic;