---@class Magic_AccessoryDamageScaler:Magic
local Magic = Ability.DefineMagic('AccessoryDamageScaler');

function Magic:DamageApplyEffect(Target, Modifier, MagicParam, Overlaid, ChangeValueData)
    local Scaler = UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(1));
    local Additional = UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(2));
    local OwnerActor = Target:GetOwner():Cast(UE4.ACharacterAccessory);

    if OwnerActor ~= nil  and ChangeValueData.HealthChangeType ~= UE4.EModifyHPType.Heal then
        return Scaler, Additional;
    end

    return 0, 0;
end

return Magic;