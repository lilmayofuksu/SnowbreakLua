---@class Magic_ChangePartBounceData:Magic
---修改部位跳弹概率
local Magic = Ability.DefineMagic('ChangePartBounceData');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    local PratName = Parameter.Params:Get(1).ParamValue
    local BouncePre = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(2));
    local BounceExtraPre = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(3));
    AbilityTarget:AddPartBounceData(PratName, BouncePre, BounceExtraPre);
    return true;
end

return Magic;