---@class Magic_Intensify:Magic
local Magic = Ability.DefineMagic('Intensify');


function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
end

function Magic:Intensify(Skill , Modifier , Parameter , CurOverlaid, bFire)

    --- Param1 : 伤害倍率
    --- Param2 : 生效的SkillID
    local DamageScaler = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(1));
    local ValidSkillID = UE4.UAbilityFunctionLibrary.GetParamfloatArrayValue(Parameter.Params:Get(2));

    for i = 1, ValidSkillID:Length() do
        if Skill ~= nil then
            if Skill:GetID() == ValidSkillID:Get(i) then
                Modifier.bEndModifier = true;
                return 1 + DamageScaler * CurOverlaid;
            end
        end

        if bFire == true and ValidSkillID:Get(i) == -1 then
            Modifier.bEndModifier = true;
            return 1 + DamageScaler * CurOverlaid;
        end
    end

    return 1.0;
end

return Magic;