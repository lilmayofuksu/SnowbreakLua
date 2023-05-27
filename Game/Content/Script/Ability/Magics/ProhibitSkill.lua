---@class Magic_ProhibitSkill:Magic  禁用指定位置的技能
local Magic = Ability.DefineMagic('ProhibitSkill');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)

    local SkillIDs = UE4.UAbilityFunctionLibrary.GetParamInt32ArrayValue(Parameter.Params:Get(1));

    if AbilityTarget ~= nil then
        if SkillIDs:Length() > 0 then

            for i = 1, SkillIDs:Length() do
                local SkillRef = AbilityTarget:GetSkill(SkillIDs:Get(i));
                if SkillRef ~= nil then
                    SkillRef.bProhibit = true;
                end
            end
        end
    end

    return true;
end


function Magic:OnRemove(AbilityTarget, Modifier, Parameter)

    local SkillIDs = UE4.UAbilityFunctionLibrary.GetParamInt32ArrayValue(Parameter.Params:Get(1));

    if AbilityTarget ~= nil then
        if SkillIDs:Length() > 0 then

            for i = 1, SkillIDs:Length() do
                local SkillRef = AbilityTarget:GetSkill(SkillIDs:Get(i));
                if SkillRef ~= nil then
                    SkillRef.bProhibit = false;
                end
            end
        end
    end

    return true;
end

return Magic;