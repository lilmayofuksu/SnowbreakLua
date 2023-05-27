---@class Magic_ModifyHPTypeDamageScaler:Magic
local Magic = Ability.DefineMagic('ModifyHPTypeDamageScaler');

function Magic:DamageApplyEffect(Target, Modifier, MagicParam, Overlaid, ChangeValueData)

    if not ChangeValueData or not ChangeValueData.ChangeValue then
        return 0, 0;
    end

    local sType = MagicParam.Params:Get(1).ParamValue
    local arrayScaler = UE4.UAbilityFunctionLibrary.GetParamfloatArrayValue(MagicParam.Params:Get(2));
    local Scaler = UE4.UAbilityLibrary.GetFloatArrayValueForLevel(arrayScaler, Modifier:GetLevel())
    Scaler = Scaler * math.max(Overlaid, 1);
    --local Scaler = UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(2));

    local Additional = MagicParam.Params:Length()>2 and UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(3)) or 0;
    local nType = UE4.EModifyHPType.EntityBullet
    local bSuperPower = false
    if sType == "全" then
        return Scaler, Additional; 
    elseif sType == "动能" then
        nType = UE4.EModifyHPType.EntityBullet
    elseif sType == "元素" then
        bSuperPower = true
    elseif sType == "特异" then
        nType = UE4.EModifyHPType.Magic_4
    elseif sType == "高热" then
        nType = UE4.EModifyHPType.Magic_1
    elseif sType == "低温" then
        nType = UE4.EModifyHPType.Magic_2
    elseif sType == "电击" then
        nType = UE4.EModifyHPType.Magic_3
    end
    local TargetType = ChangeValueData.ChangeValue.HealthChangeType
    if bSuperPower then
        if TargetType == UE4.EModifyHPType.Magic_1 
            or TargetType == UE4.EModifyHPType.Magic_2 
            or TargetType == UE4.EModifyHPType.Magic_3 then
                return Scaler, Additional;
        end
    else
        if TargetType == nType then
            return Scaler, Additional;
        end
    end
    return 0, 0;
end

function Magic:DamageReceiveEffect(Target, Modifier, MagicParam, Overlaid, ChangeValueData)

    local sType = MagicParam.Params:Get(1).ParamValue
    local arrayScaler = UE4.UAbilityFunctionLibrary.GetParamfloatArrayValue(MagicParam.Params:Get(2));
    local Scaler = UE4.UAbilityLibrary.GetFloatArrayValueForLevel(arrayScaler, Modifier:GetLevel())
    Scaler = Scaler * math.max(Overlaid, 1);
    --local Scaler = UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(2));

    local Additional = MagicParam.Params:Length()>2 and UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(3)) or 0;
    local nType = UE4.EModifyHPType.EntityBullet
    local bSuperPower = false
    if sType == "全" then
        return Scaler, Additional; 
    elseif sType == "动能" then
        nType = UE4.EModifyHPType.EntityBullet
    elseif sType == "元素" then
        bSuperPower = true
    elseif sType == "特异" then
        nType = UE4.EModifyHPType.Magic_4
    elseif sType == "高热" then
        nType = UE4.EModifyHPType.Magic_1
    elseif sType == "低温" then
        nType = UE4.EModifyHPType.Magic_2
    elseif sType == "电击" then
        nType = UE4.EModifyHPType.Magic_3
    end
    local TargetType = ChangeValueData.ChangeValue.HealthChangeType
    if bSuperPower then
        if TargetType == UE4.EModifyHPType.Magic_1 
            or TargetType == UE4.EModifyHPType.Magic_2 
            or TargetType == UE4.EModifyHPType.Magic_3 then
                return Scaler, Additional;
        end
    else
        if TargetType == nType then
            return Scaler, Additional;
        end
    end
    return 0, 0;
end

return Magic;