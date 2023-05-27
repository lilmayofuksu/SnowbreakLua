---@class Magic_ModifyHealEffectScaler:Magic
local Magic = Ability.DefineMagic('ModifyHealEffectScaler');

function Magic:HealEffect(Target, Modifier, MagicParam, Overlaid, ChangeValueData)


    local arrayScaler = UE4.UAbilityFunctionLibrary.GetParamfloatArrayValue(MagicParam.Params:Get(1));
    local Scaler = UE4.UAbilityLibrary.GetFloatArrayValueForLevel(arrayScaler, Modifier:GetLevel())
    Scaler = Scaler * math.max(Overlaid, 1);

    local Additional = MagicParam.Params:Length()>2 and UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(2)) or 0;
    Additional = Additional * math.max(Overlaid, 1);

    return Scaler, Additional;
end

return Magic;