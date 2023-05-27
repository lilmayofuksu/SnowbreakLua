---@class Magic_InitAttributeToTargetAttribute:Magic
---用Target的属性初始化Launcher的某个指定的属性
local Magic = Ability.DefineMagic('InitMaxAttributeToTargetAttribute');

function Magic:OverrideGrowAttributeID(AbilityTarget,Modifier)
    if AbilityTarget == nil or Modifier.Launcher == nil then
        return
    end
    local lpSum = AbilityTarget:GetOriginCharacter()
    if lpSum ~= nil and UE4.UGameLibrary.IsOnlineServer(lpSum) then
        --local lpPlayer = lpSum:GetSummonedOwner()
        --print(lpPlayer, lpPlayer.Level)
        local lpMonster = Modifier.Launcher:GetOriginCharacter();
        if lpMonster ~= nil then
            local lvl = 0;
            local nGrowAttributeID = lpMonster:GetGrowAttributeID(lvl)
            -- print("InitMaxAttributeToTargetAttribute", "Grow", nGrowAttributeID)
            lpSum:SetGrowAttributeID(nGrowAttributeID)
            --[[
            local AR = Modifier.Launcher:GetAbilityAttributeFromString(AttributeName)
            if AR ~= nil then
                print("RecalcAttributeValue begin:", MaxValue)
                MaxValue = lpMonster:RecalcAttributeValue(AR, MaxValue, lpPlayer.Level, false)
                print("RecalcAttributeValue end:", MaxValue)
            end
            --]]
        end
    end
end

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local AttributeName = Parameter.Params:Get(1).ParamValue;
    local AttributePercent = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(2));

    if AbilityTarget ~= nil and Modifier.Launcher ~= nil then
        local AttributeRef = AbilityTarget:GetAbilityAttributeFromString(AttributeName)
        if AttributeRef == nil then
            return
        end
        -- 重载成长模板ID
        self:OverrideGrowAttributeID(AbilityTarget, Modifier)
        
        -- local CurValue = Modifier.Launcher:GetPropertieValueFromString(AttributeName)
        local MaxValue = Modifier.Launcher:GetPropertieMaxValueFromString(AttributeName)
        -- local SetValue = AttributePercent * CurValue / 100
        local SetMaxValue = AttributePercent * MaxValue / 100
        -- print("InitMaxAttributeToTargetAttribute", AttributeName, SetMaxValue)
        AbilityTarget:K2_InitAttribute(AttributeRef, SetMaxValue, 0, 0, SetMaxValue)
        -- AbilityTarget:SetMaxAttributeValue(AttributeRef, SetMaxValue)
        -- AbilityTarget:SetAttributeValue(AttributeRef, SetMaxValue)
    end
end

return Magic;