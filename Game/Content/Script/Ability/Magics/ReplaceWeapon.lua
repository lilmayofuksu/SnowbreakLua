---@class Magic_ReplaceWeapon:Magic
local Magic = Ability.DefineMagic('ReplaceWeapon');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    ---TODO : New skill info
    --- Param1 : Weapon ID
    local weaponG, weaponD, weaponP, weaponL = UE4.UAbilityFunctionLibrary.GetParamGDPLValue(Parameter.Params:Get(1))
    local NewWeaponID = UE4.UItemLibrary.GetTemplateId( weaponG, weaponD, weaponP, weaponL)

    local  Target = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
    local WeaponClass = UE4.UAbilityFunctionLibrary.GetWeaponClass(NewWeaponID)
    if WeaponClass == nil then
        return true;
    end

    if Target ~= nil then
        Modifier.OldWeapon = Target:GetWeapon()
        Modifier.OldWeapon:SetActorHiddenInGame(true)
        Modifier.OldWeapon:SetOwner(nil)
        Target:AttachWeaponByWeaponID(NewWeaponID);
    end

    return true;
end


function Magic:OnRemove(AbilityTarget, Modifier, Parameter)

    local Character = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter)
    if Character ~= nil and Modifier.OldWeapon ~= nil and Modifier.OldWeapon ~= Character:GetWeapon() then
        Character:GetWeapon():SetActorHiddenInGame(true)
        Character:GetWeapon():SetOwner(nil)
        Character:GetWeapon():SetLifeSpan(0.1)
         
        Modifier.OldWeapon:SetActorHiddenInGame(false)
        Modifier.OldWeapon:SetOwner(Character)
    end

    return true;
end

return Magic;