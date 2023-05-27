---@class Magic_BulletEnchanting  子弹附魔
local Magic = Ability.DefineMagic('BulletEnchanting');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    local EnchantBulletID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local Probability = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(2));
    
    if AbilityTarget then
        local Chara = AbilityTarget:GetOriginCharacter()
        if Chara == nil then return true end
        local Weapon = Chara:GetWeapon()
        if Weapon == nil then return true end
        local Launcher = Modifier:GetLauncher();
        AbilityTarget:SetSkillEnchantBulletInfo(EnchantBulletID, Weapon.BulletInfo.ID, Probability, Launcher, Modifier:GetLevel())
    end

    return true;
end

function Magic:OnRemove(AbilityTarget,Modifier, Parameter, CurOverlaid)
    if AbilityTarget then
        AbilityTarget:SetSkillEnchantBulletInfo(0,0, 0, nil, 0)
    end
    return true;
end


return Magic;