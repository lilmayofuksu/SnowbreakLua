---@class Magic_ReviveArmor:Magic
local Magic = Ability.DefineMagic("ReviveArmor")

function Magic:OnModifierPreDeadExec(DamageCauser, DeadCharAbility, Modifier, MagicParam, HealthCHangeData)
    if not DeadCharAbility then
        return 
    end
    --- Param1 : 回复值
    --- Param2 : 是否按百分比回复
    --- Param3 : 触发ModifierID(,分隔)
    local HealthValue = UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(1))
    local bUsePercentValue = UE4.UAbilityFunctionLibrary.GetParamboolValue(MagicParam.Params:Get(2))
    local ModifierIDs = UE4.UAbilityFunctionLibrary.GetParamInt32ArrayValue(MagicParam.Params:Get(3))
    local Value = HealthValue
    if bUsePercentValue then
        Value = DeadCharAbility:GetRolePropertieMaxValue(UE4.EAttributeType.Health) * HealthValue/100
    end
    DeadCharAbility:AppendHealthValue(DeadCharAbility,Value,nil)
    for i = 1,ModifierIDs:Length() do
        UE4.UModifier.MakeModifier(ModifierIDs:Get(i), Modifier, DeadCharAbility, DeadCharAbility, Modifier.EmitterOwner, Modifier.ApplyLocation, Modifier.OriginLocation)
    end

end

return Magic
