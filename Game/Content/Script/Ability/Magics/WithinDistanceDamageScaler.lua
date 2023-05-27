---@class Magic_WithinDistanceDamageScaler:Magic
local Magic = Ability.DefineMagic('WithinDistanceDamageScaler');



-- ---实现对受到伤害的缩放
-- ---@param Modifier UModifier
-- ---@param DamageCasuer UAbilityComponentBase
-- ---@param DamageType EModifyHPType
-- ---@param Damage float
-- ---@param Parameter FMagicParameter
-- ---@return float
-- function Magic:OnTargetDamage(Modifier,OriginLocation , ApplyLocation ,DamageCasuer, DamageType, Damage, Parameter)
--     local Distance = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(1));
--     local Scaler = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(2));
--     if DamageType ~= UE4.EModifyHPType.Heal then

--         local Offset = DamageCasuer:GetOwner():K2_GetActorLocation() - ApplyLocation
--         local dis = Offset:Size2D()
--         if dis <= Distance  then
--             Damage = Damage * Scaler;
--         end
--     end
--     return Damage;
-- end

---当受到任意来源的伤害
---@param Launcher UAbilityComponent 造成伤害的来源
---@param Modifier UModifier 效果所属Modifier
---@param MagicParam FMagicParameter 效果的参数
---@param overlaid int32 当前Modifier的层数
---@param ChangeValueData FHealthChangeValue 命中造成伤害的参数
function Magic:DamageReceiveEffect(Launcher, Modifier, MagicParam, Overlaid, ChangeValueData)
    local Distance = UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(1));
    local Scaler = UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(2));

    if ChangeValueData.HealthChangeType ~= UE4.EModifyHPType.Heal then
        local Offset = ChangeValueData.ApplyLocation - ChangeValueData.OriginLocation;
        local dis = Offset:Size2D()
        if dis <= Distance  then
           return Scaler;
        end
    end

    return 0;
end

return Magic;