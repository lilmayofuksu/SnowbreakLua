---@class Magic_WeaponDamageTypeEnchant:Magic
---给武器附魔属性
local Magic = Ability.DefineMagic('WeaponDamageTypeEnchant');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local Launcher = Modifier:GetLauncher();
    local Target = AbilityTarget;
    local Params = Parameter.Params
    local DamageTypeName = Params:Get(1).ParamValue;
    local SpecificTargetEnchantID = UE4.UAbilityFunctionLibrary.GetParamintValue(Params:Get(2));
    local EmitterID = UE4.UAbilityFunctionLibrary.GetParamintValue(Params:Get(3));
    local bApplyBySource = false;
    if Params:Length() > 3 then
        bApplyBySource = UE4.UAbilityFunctionLibrary.GetParamboolValue(Params:Get(4))
    end

    if Target ~= nil then
        Target:AddSpecificEnchantInfo(SpecificTargetEnchantID);
        Target:AddEnchantDamageByName(DamageTypeName);
        if bApplyBySource then
            Target:AddEnchantEmitter(EmitterID, Launcher, bApplyBySource, Modifier:GetLevel());
        else
            Target:AddEnchantEmitter(EmitterID, nil, false, Modifier:GetLevel());
        end
        -- if Launcher ~= Target then
        --     Target:AddEnchantEmitter(EmitterID, Launcher, bApplyBySource, Modifier:GetLevel());
        -- else
        --     Target:AddEnchantEmitter(EmitterID, nil, false, Modifier:GetLevel());
        -- end
        print("Enchant EmitterID is : ", EmitterID)
    end
    
    return true;
end

function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    local Launcher = Modifier:GetLauncher();
    local Target = AbilityTarget;
    local Params = Parameter.Params
    local DamageTypeName = Params:Get(1).ParamValue;
    local SpecificTargetEnchantID = UE4.UAbilityFunctionLibrary.GetParamintValue(Params:Get(2));
    local EmitterID = UE4.UAbilityFunctionLibrary.GetParamintValue(Params:Get(3));

    if Target ~= nil then
        Target:RemoveSpecificEnchantInfo(SpecificTargetEnchantID);
        Target:RemoveEnchantDamageByName(DamageTypeName);
        Target:RemoveEnchantEmitter(EmitterID);
    end
    return true;
end


return Magic;

