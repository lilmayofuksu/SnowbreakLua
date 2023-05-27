---@class Magic_IgnoreDamage_OnDamage:Magic
local Magic = Ability.DefineMagic('IgnoreDamage_OnDamage');

function Magic:DamageApplyEffect(Target, Modifier, MagicParam, Overlaid, ChangeValueData)
    return true;
end

function Magic:DamageReceiveEffect(Launcher, Modifier, MagicParam, Overlaid, ChangeValueData)
    return true;
end

return Magic;