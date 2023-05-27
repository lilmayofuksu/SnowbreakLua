---@class Magic_RemoveAbnormalModifier:Magic  移除属于指定异常状态的数个Modifier
local Magic = Ability.DefineMagic('RemoveAbnormalModifier');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    self:RemoveModidier(AbilityTarget, Modifier, Parameter)
    return true
end

function Magic:OnExec(AbilityTarget,Modifier, Parameter , CurOverlaid) 
    self:RemoveModidier(AbilityTarget, Modifier, Parameter)
end

function Magic:OnRemove(AbilityTarget, Modifier, Parameter)
    return true
end

function Magic:GetRandomModifier(Modifiers, Num)
    local Results = UE4.TArray(UE4.UModifier);
    if Num >= Modifiers:Length() then
        return Modifiers;
    end

    for i = 1, Num do
        local RandIndex = math.random(1, Modifiers:Length());
        Results:AddUnique(Modifiers:Get(RandIndex));
        Modifiers:Remove(Modifiers:Get(RandIndex));
    end

    return Results;
end

function Magic:GetMinLifeModifier(Modifiers, Num)
    local Results = UE4.TArray(UE4.UModifier);
    if Num >= Modifiers:Length() then
        return Modifiers;
    end

    for i = 1, Num do
        local MinLifeModifier = UE4.UModifier;
        local MinLife = -1.0;
        for n = 1, Modifiers:Length() do
            if MinLife < 0.0 or Modifiers:Get(n).LifeTime < MinLife then
                MinLife = Modifiers:Get(n).LifeTime
                MinLifeModifier = Modifiers:Get(n)
            end
        end

        Results:AddUnique(MinLifeModifier);
        Modifier:Remove(MinLifeModifier);
    end

    return Results;
end

function Magic:GetMaxLifeModifier(Modifiers, Num)
    local Results = UE4.TArray(UE4.UModifier);
    if Num >= Modifiers:Length() then
        return Modifiers;
    end

    for i = 1, Num do
        local MaxLifeModifier = UE4.UModifier;
        local MaxLife = 0.0;
        for n = 1, Modifiers:Length() do
            if Modifiers:Get(n).LifeTime > MaxLife then
                MaxLife = Modifiers:Get(n).LifeTime
                MaxLifeModifier = Modifiers:Get(n)
            end
        end
        
        Results:AddUnique(MinLifeModifier);
        Modifier:Remove(MinLifeModifier);
    end

    return Results;
end

function Magic:RemoveModidier(AbilityTarget, Modifier, Parameter)
    local StateName = UE4.UAbilityFunctionLibrary.GetStringArrayValue(Parameter.Params:Get(1));
    local RemoveModifierNum = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(2));
    local RemoveType = Parameter.Params:Get(3).ParamValue;
    
    local Modifiers = UE4.UAbilityFunctionLibrary.GetBlockStateModifiersInTarget(AbilityTarget, StateName);
    if Modifiers:Length() > 0 then
        print("Try Remove Modifiers : ", RemoveType)
        if RemoveType == "Random" then
            print("Try Remove Modifiers InRandom")
            local NeedRemoveModifiers = self:GetRandomModifier(Modifiers, RemoveModifierNum);
            print("Try Remove Modifiers InRandom Num : ", NeedRemoveModifiers:Length())
            for i = 1, NeedRemoveModifiers:Length() do
                AbilityTarget:RemoveModifier(NeedRemoveModifiers:Get(i));
            end
        end
        if RemoveType == "MinLifeTime" then
            local NeedRemoveModifiers = self:GetMinLifeModifier(Modifiers, RemoveModifierNum);
            for i = 1, NeedRemoveModifiers:Length() do
                AbilityTarget:RemoveModifier(NeedRemoveModifiers:Get(i));
            end
        end
        if RemoveType == "MaxLifeTime" then
            local NeedRemoveModifiers = self:GetMaxLifeModifier(Modifiers, RemoveModifierNum);
            for i = 1, NeedRemoveModifiers:Length() do
                AbilityTarget:RemoveModifier(NeedRemoveModifiers:Get(i));
            end
        end
    end
    return true
end

return Magic