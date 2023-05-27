---@class Magic_ChangeAttributeLimitMaxValue  修改属性上限值
local Magic = Ability.DefineMagic('ChangeAttributeLimitMaxValue');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)

    local ParamNum =  Parameter.Params:Length()
    local AttributeName = Parameter.Params:Get(1).ParamValue
    local LimitMaxValuePre = ParamNum >= 2 and UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(2)) or 0;
    local LimitMaxValue = ParamNum >= 3 and UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(3)) or 0;

    if AbilityTarget then
        local Attribute= AbilityTarget:GetAbilityAttributeFromString(AttributeName)
        if AttributeName == nil then return end

        local MaxValue = AbilityTarget:GetRolePropertieClassMaxValue(Attribute)
        local LimitValue = MaxValue * LimitMaxValuePre * 0.01 + LimitMaxValue        
        AbilityTarget:SetAttributeLimitMaxValue(Attribute, LimitValue)
    end

    return true;
end

function Magic:OnRemove(AbilityTarget,Modifier, Parameter, CurOverlaid)
    local AttributeName = Parameter.Params:Get(1).ParamValue
    
    if AbilityTarget then
        local Attribute= AbilityTarget:GetAbilityAttributeFromString(AttributeName)
        if AttributeName == nil then return end
        AbilityTarget:SetAttributeLimitMaxValue(Attribute, 0)
    end
    return true;
end


return Magic;