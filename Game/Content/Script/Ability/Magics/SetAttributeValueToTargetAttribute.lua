---@class Magic_SetAttributeValueToTargetAttributey:Magic
---将目标Target的指定属性设置为Launcher当前的属性值
local Magic = Ability.DefineMagic('SetAttributeValueToTargetAttribute');


function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local AttributeName = Parameter.Params:Get(1).ParamValue;

    if AbilityTarget ~= nil and Modifier.Launcher ~= nil then
        local AttributeRef = AbilityTarget:GetAbilityAttributeFromString(AttributeName)
        if AttributeRef == nil then
            return
        end
        local CurValue = Modifier.Launcher:GetPropertieValueFromString(AttributeName)
        AbilityTarget:SetAttributeValue(AttributeRef, CurValue)
       
    end
end

return Magic;