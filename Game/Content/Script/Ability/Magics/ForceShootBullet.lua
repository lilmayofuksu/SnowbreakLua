---@class Magic_ForceShootBullet:Magic
local Magic = Ability.DefineMagic('ForceShootBullet');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    ---拖拽的模式

    local Launcher = Modifier:GetLauncher():GetOriginCharacter();
    if Launcher == nil then return true end
    local Weapon = Launcher:GetWeapon()
    if Weapon == nil then return true end


    local ExtraCount = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1)); --额外射击次数
    local FireDelayTime = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(2)); --射击间隔(float)
    local Recoil = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(3)); --后座力大小临时调节值

    Weapon:ForceShootBullet(ExtraCount, FireDelayTime)
    Weapon:AlterShotRecoilForceRevise(Recoil)   
   
    return true;
end

function Magic:OnRemove(AbilityTarget, Modifier, Parameter)
   
    
    return true;
end
return Magic