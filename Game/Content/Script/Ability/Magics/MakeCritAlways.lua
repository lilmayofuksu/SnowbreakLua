---@class Magic_MakeCritAlways:Magic
---使拥有者命中一直保持(命中/被命中)暴击或者不暴击
local Magic = Ability.DefineMagic('MakeCritAlways');

function Magic:ApplyHitApplyEffect(Target, Modifier, MagicParam, Overlaid, OriginID, Outer, bCrit)   
    local CritResult = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(1));
    return CritResult;
end

function Magic:ApplyHitReceiveEffect(Target, Modifier, MagicParam, Overlaid, OriginID, Outer, bCrit)
    local CritResult = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(1));
    return CritResult;
end

return Magic;