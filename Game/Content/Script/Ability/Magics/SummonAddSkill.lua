---@class Magic_SummonAddSkill:Magic
local Magic = Ability.DefineMagic('SummonAddSkill');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    if Modifier then
        Modifier.bBindOnNotifySummon = true
    end

    if not InSummon then return end
    local Params = Param.Params
    local SkillID = UE4.UAbilityFunctionLibrary.GetParamintValue(Params:Get(1));
    local bOnlyMinion = false
    local bApplyAll = false
    local length = Params:Length()
    if length > 1 then
         bOnlyMinion = UE4.UAbilityFunctionLibrary.GetParamboolValue(Params:Get(2));
    end
    if length > 2 then
        bApplyAll = UE4.UAbilityFunctionLibrary.GetParamboolValue(Params:Get(3));
    end
    if bApplyAll then
        local lpCharacter = AbilityTarget:GetOriginCharacter()
        if not lpCharacter then return end
        local AllSummon = UE4.TArray(UE4.AGameCharacter)
        lpCharacter:GetAllSummoned(AllSummon)
        for i = 1, AllSummon:Length() do
            local lpSummon = AllSummon:Get(i)       
            if lpSummon then
                if bOnlyMinion then
                    if lpSummon:IsMinion() then
                        lpSummon.Ability:AddSkill(SkillID, 1)
                    end
                else
                    lpSummon.Ability:AddSkill(SkillID, 1)
                end
            end
        end
    end
    return true;
end
function Magic:OnNotifySummon(AbilityTarget,Modifier, Param, InSummon)
    if not InSummon then return end
    local Params = Param.Params
    local SkillID = UE4.UAbilityFunctionLibrary.GetParamintValue(Params:Get(1));
    local bOnlyMinion = false
    local length = Params:Length()
    if length > 1 then
         bOnlyMinion = UE4.UAbilityFunctionLibrary.GetParamboolValue(Params:Get(2));
    end

    if bOnlyMinion then
        if InSummon:IsMinion() then
            InSummon.Ability:AddSkill(SkillID, 1)
        end
    else
        InSummon.Ability:AddSkill(SkillID, 1)
    end
    return true;
end



return Magic;