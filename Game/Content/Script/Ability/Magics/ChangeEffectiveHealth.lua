---@class Magic_ChangeEffectiveHealth:Magic  目标属性修改——“有效血量”
local Magic = Ability.DefineMagic('ChangeEffectiveHealth');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)

    self:ChangeHealth(AbilityTarget, Modifier, Parameter, bKeepEffect)
    return true;
end

function Magic:OnExec(AbilityTarget, Modifier, Parameter , CurOverlaid)
    self:ChangeHealth(AbilityTarget, Modifier, Parameter, false)
    return true;
end

function Magic:ChangeHealth(AbilityTarget, Modifier, Parameter, bKeep)
    local nValue = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(1)); -- 改变值
    local nPrecent = 0.01 * UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(2)); --改变值百分比

    local nHealthValue = AbilityTarget:GetRolePropertieValue(UE4.EAttributeType.Health) 
    local nShieldValue = AbilityTarget:GetRolePropertieValue(UE4.EAttributeType.Shield)

    local nHealthMax =  AbilityTarget:GetRolePropertieMaxValue(UE4.EAttributeType.Health) 
    local nShieldMax =  AbilityTarget:GetRolePropertieMaxValue(UE4.EAttributeType.Shield) 

    -- local nHealthBase =  AbilityTarget:GetRolePropertieBaseValue(UE4.EAttributeType.Health) 
    -- local nShieldBase =  AbilityTarget:GetRolePropertieBaseValue(UE4.EAttributeType.Shield) 

    local nChangeValue = nValue + (nHealthMax + nShieldMax ) * nPrecent

    local nHealth = 0
    local nShield = 0
    if nChangeValue > 0 then        
        if nHealthMax <= nHealthValue + nChangeValue then
            nHealth = nHealthMax
            nShield = nHealthValue + nChangeValue - nHealthMax            
        else
            nHealth = nChangeValue
            nShield = 0
        end
    else
        if nChangeValue + nShieldValue >= 0 then
            nHealth = 0
            nShield = nChangeValue
        else
            nHealth = nChangeValue + nShieldValue
            nShield = -nShieldValue
        end
    end

    local AttributeChangeValue = UE4.FAttributeChangeValue()
    if nHealth ~= 0 then
        AttributeChangeValue.AttributeClass = AbilityTarget:GetAbilityAttributeFromString("Health")
        AttributeChangeValue.Value = nHealth
        Modifier:ApplyAttributeChange(AbilityTarget, AttributeChangeValue, bKeep)
    end
    if nShield ~= 0 then
        AttributeChangeValue.AttributeClass = AbilityTarget:GetAbilityAttributeFromString("Shield")
        AttributeChangeValue.Value = nShield
        Modifier:ApplyAttributeChange(AbilityTarget, AttributeChangeValue, bKeep)
    end
end



return Magic;