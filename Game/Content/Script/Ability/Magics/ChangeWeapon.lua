---@class Magic_ChangeWeapon:Magic
local Magic = Ability.DefineMagic('ChangeWeapon');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    if not AbilityTarget then return end
    local lpCharacter = AbilityTarget:GetOriginCharacter()
    if not lpCharacter then return end

    Modifier.OldWeapon = lpCharacter:GetWeapon()
    if not Modifier.OldWeapon then return end
    Modifier.OldWeapon:SetCurrentUseWeapon(false)
    local GrowupID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1))
    local AppearID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(2))
    
    local NewWeapon = UE4.UAccount.CloneWeaponItem(Modifier.OldWeapon:GetWeaponItem(), GrowupID, AppearID)
    lpCharacter:ChangeWeaponByItem(NewWeapon)
    return true;
end


function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    if not AbilityTarget then return end
    local lpCharacter = AbilityTarget:GetOriginCharacter()
    if not lpCharacter then return end
    local CurWeapon = lpCharacter:GetWeapon()

    if Modifier.OldWeapon ~= nil and Modifier.OldWeapon ~= CurWeapon then
        lpCharacter:ChangeWeapon(Modifier.OldWeapon)
        Modifier.OldWeapon = nil
    end
    if CurWeapon then
        CurWeapon:K2_DestroyActor()
    end
    return true;
end

return Magic;