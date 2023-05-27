---@class Magic_InitAttributeToTargetAttribute2:Magic
---用Target的属性初始化Launcher的某个指定的属性
local Magic = Ability.DefineMagic('InitAttributeToTargetAttribute2');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    if not Modifier then return end
    local Params = Parameter.Params
    local AttributeName = Params:Get(1).ParamValue;
    local Length = Params:Length()
    

    if AbilityTarget ~= nil and Modifier.Launcher ~= nil then
        local AttributeRef = AbilityTarget:GetAbilityAttributeFromString(AttributeName)
        if AttributeRef == nil then
            return
        end

        local SetValue = 0
        local SetMaxValue = 0
        for idx = 3, Length, 2 do

            local OtherName = Params:Get(idx-1).ParamValue;
            local OtherPercent = UE4.UAbilityFunctionLibrary.GetParamfloatValueForLevel(Params:Get(idx), Modifier:GetLevel());
            local CurValue = Modifier.Launcher:GetPropertieValueFromString(OtherName)
            local MaxValue = Modifier.Launcher:GetPropertieMaxValueFromString(OtherName)

            local SetValue = SetValue + OtherPercent * CurValue / 100
            local SetMaxValue = SetMaxValue + OtherPercent * MaxValue / 100
        end
        AbilityTarget:K2_InitAttribute(AttributeRef, SetMaxValue, 0, 0, SetValue)
    end
end

return Magic;