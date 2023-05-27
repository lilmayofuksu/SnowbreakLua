---@class Magic_InitAttributeToTargetAttribute:Magic
---用Target的属性初始化Launcher的某个指定的属性
local Magic = Ability.DefineMagic('InitAttributeToTargetAttribute');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    if not Modifier then return end
    local AttributeName = Parameter.Params:Get(1).ParamValue;
    local AttributePercent = UE4.UAbilityFunctionLibrary.GetParamfloatValueForLevel(Parameter.Params:Get(2), Modifier:GetLevel());

    if AbilityTarget ~= nil and Modifier.Launcher ~= nil then
        local AttributeRef = AbilityTarget:GetAbilityAttributeFromString(AttributeName)
        if AttributeRef == nil then
            return
        end

        local CurValue = Modifier.Launcher:GetPropertieValueFromString(AttributeName)
        local MaxValue = Modifier.Launcher:GetPropertieMaxValueFromString(AttributeName)

        local SetValue = AttributePercent * CurValue / 100
        local SetMaxValue = AttributePercent * MaxValue / 100

        AbilityTarget:K2_InitAttribute(AttributeRef, SetMaxValue, 0, 0, SetValue)
        -- AbilityTarget:SetMaxAttributeValue(AttributeRef, SetMaxValue)
        -- AbilityTarget:SetAttributeValue(AttributeRef, SetValue)
    end
end

return Magic;