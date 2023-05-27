---@class Magic_HitDistanceChangeDamage:Magic
local Magic = Ability.DefineMagic('HitDistanceChangeDamage')


function Magic:HitDistanceChangeDamage(Target, Modifier, MagicParam, Overlaid, ChangeValueData)

    local Range = UE4.UAbilityFunctionLibrary.GetParamfloatArrayValue(MagicParam.Params:Get(1))
    local bAdd = MagicParam.Params:Get(2).ParamValue == "+"
    local Curve = MagicParam.Params:Get(3).ParamValue
    local K = UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(4))
    local A = UE4.UAbilityFunctionLibrary.GetParamfloatValue(MagicParam.Params:Get(5))
    local DamageSoruce = MagicParam.Params:Get(6).ParamValue
    local DamageType = MagicParam.Params:Get(7).ParamValue
    local distance = UE4.UKismetMathLibrary.Vector_Distance(ChangeValueData.ChangeValue.ApplyLocation, ChangeValueData.ChangeValue.OriginLocation)
    distance = (distance - Range:Get(1))/(Range:Get(2) - Range:Get(1))
    distance = UE4.UKismetMathLibrary.FClamp(distance, 0.0, 1.0)

    local pLoadCurve = UE4.UGameAssetManager.GameLoadAssetFormPath(Curve)
    if not pLoadCurve then return end
    local CurveFloat = pLoadCurve:Cast(UE4.UCurveFloat)
    local x = CurveFloat:GetFloatValue(distance)
    local OutValue = x * K + A
    local OutScale = bAdd and 0 or OutValue 
    local OutAddtion = bAdd and OutValue or 0

    local bCheck = false
    if DamageSoruce == "全" then
        bCheck = true
    elseif DamageSoruce == "普攻" and  ChangeValueData.ChangeValue.DamageOriginType == 0 then
        bCheck = true
    elseif DamageSoruce == "技能" and  ChangeValueData.ChangeValue.DamageOriginType == 1 then
        bCheck = true
    end
    if not bCheck then
        return 0, 0
    end


    local nType = UE4.EModifyHPType.EntityBullet
    local bSuperPower = false
    if DamageType == "全" then
        return OutScale, OutAddtion
    elseif DamageType == "动能" then
        nType = UE4.EModifyHPType.EntityBullet
    elseif DamageType == "元素" then
        bSuperPower = true
    elseif DamageType == "特异" then
        nType = UE4.EModifyHPType.Magic_4
    elseif DamageType == "高热" then
        nType = UE4.EModifyHPType.Magic_1
    elseif DamageType == "低温" then
        nType = UE4.EModifyHPType.Magic_2
    elseif DamageType == "电击" then
        nType = UE4.EModifyHPType.Magic_3
    end

    local TargetType = ChangeValueData.ChangeValue.HealthChangeType
    if bSuperPower then
        if TargetType == UE4.EModifyHPType.Magic_1 
            or TargetType == UE4.EModifyHPType.Magic_2 
            or TargetType == UE4.EModifyHPType.Magic_3 then
                return OutScale, OutAddtion
        end
    else
        if TargetType == nType then
            return OutScale, OutAddtion
        end
    end
    return 0, 0
end

return Magic