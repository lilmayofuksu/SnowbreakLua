---@class Magic_UseTempWeaponBullet:Magic
local Magic = Ability.DefineMagic('UseTempWeaponBullet');


function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    ---临时的子弹ID
    local TempBulletID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1)); 
    ---临时子弹的生效次数(<0 则不限次数)
    local ActiveTimes = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(2)); 

    local Target = AbilityTarget;
    local CharacterOwner = Target:GetOwner():Cast(UE4.AGameCharacter);
    if CharacterOwner ~= nil then
        local Weapon = CharacterOwner:GetWeapon();
        if Weapon ~= nil then
            Weapon:SetTempBulletID(TempBulletID,Modifier.RunTimeID, ActiveTimes);
        end
    end

    return true;
end

function Magic:OnRemove(AbilityTarget, Modifier, Parameter)
    local Target = AbilityTarget;
    local CharacterOwner = Target:GetOwner():Cast(UE4.AGameCharacter);
    if CharacterOwner ~= nil then
        local Weapon = CharacterOwner:GetWeapon();
        if Weapon ~= nil then
            Weapon:ClearTempBulletID(Modifier.RunTimeID);
        end
    end
    return true;
end

return Magic;