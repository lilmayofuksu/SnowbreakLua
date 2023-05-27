---@class Magic_ExecuteAgainDamage:Magic
local Magic = Ability.DefineMagic('ExecuteAgainDamage');

function Magic:ApplyDamageEffect(MagicParam, PreDamageData, nLevel)
    local Luancher = PreDamageData.Luancher
    local Target = PreDamageData.Target
    if not Luancher or not Target then
        return true
    end
    local nDamageRate =  UE4.UAbilityLibrary.GetFloatValueStringForLevel(MagicParam.Params:Get(1).ParamValue, nLevel);

    local nChangeValueData = PreDamageData.ChangeValue
    nChangeValueData.bDamageEffect = true
    nChangeValueData.DamageScaler = nChangeValueData.DamageScaler * nDamageRate * 0.01
    Target:ModifyHealth(Luancher, nChangeValueData, true)
    return true;
end


return Magic;