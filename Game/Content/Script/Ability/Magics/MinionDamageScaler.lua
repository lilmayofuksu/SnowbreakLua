---@class Magic_MinionDamageScaler:Magic
local Magic = Ability.DefineMagic('MinionDamageScaler');

function Magic:MinionDamageEffect(Target, Modifier, MagicParam, Overlaid, ChangeValueData)

    local Scaler = UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(1));
    Scaler = Scaler * math.max(Overlaid, 1);
    local Additional = MagicParam.Params:Length()>2 and UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(2)) or 0;
    Additional = Additional * math.max(Overlaid, 1);

    return Scaler, Additional;
end

return Magic;