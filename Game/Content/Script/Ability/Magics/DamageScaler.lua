---@class Magic_DamageScaler:Magic
local Magic = Ability.DefineMagic('DamageScaler');

function Magic:DamageApplyEffect(Target, Modifier, MagicParam, Overlaid, ChangeValueData)
    local Scaler = UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(1));
    local Additional = 0
    if MagicParam.Params:Length() >=2 then
        Additional = UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(2));
    end

    if ChangeValueData.HealthChangeType ~= UE4.EModifyHPType.Heal then
        return Scaler, Additional;
    end

    return 0, 0;
end

return Magic;