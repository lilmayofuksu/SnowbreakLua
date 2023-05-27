
---@class Magic_DeadCheckCauseDamageSkill:Magic
local Magic = Ability.DefineMagic('DeadCheckCauseDamageSkill');

function Magic:OnModifierDeadCheck(DamageCauser, Modifier, MagicParam, HealthCHangeData)
    local CheckSkillIDs = UE4.UAbilityFunctionLibrary.GetParamInt32ArrayValue(MagicParam.Params:Get(1));
    local CheckSkillIndex = 0
    if MagicParam.Params:Length() >=2 then
        CheckSkillIndex = UE4.UAbilityFunctionLibrary.GetParamintValue(MagicParam.Params:Get(2));
    end

    local Character = DamageCauser:GetOriginCharacter();
    if Character ~= nil then
        if Character:GetSummonedOwner() ~= nil then
            Character = Character:GetSummonedOwner();
        end

        DamageCauser = Character.Ability;
    end

    for i = 1, CheckSkillIDs:Length() do
        local bSame = UE4.UAbilityFunctionLibrary.IsRelavantSkill(CheckSkillIDs:Get(i), HealthCHangeData.OriginID);
        if  HealthCHangeData.DamageOriginType == 1 and bSame == true then
            return true;
        end
    end

    if CheckSkillIndex <= 0 then
        return false;
    end

    if CheckSkillIndex > 0 then
        local Ability = DamageCauser:Cast(UE4.UAbilityComponent);
        if HealthCHangeData.DamageOriginType == 1 and Ability ~= nil then
            local Index = Ability:GetSkillIndexByAll(HealthCHangeData.OriginID);
            if HealthCHangeData.DamageOriginType == 1 and  CheckSkillIndex == Index then
                return true;
            end
        end
        
        return false;
    end
    return true
end

return Magic