---@class Magic_BulletHitModifierTarget  --命中持有特殊Modifier目标，子弹添加附魔
local Magic = Ability.DefineMagic('BulletHitModifierTarget');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    if Modifier then
        Modifier.bBindBulletHit = true
    end
    return true;
end

function Magic:OnBulletHit(AbilityTarget,Modifier, Param, InBullet, InHitTarget)
    if not InHitTarget then return end
    if not InBullet then return end

    local ModifierID = UE4.UAbilityFunctionLibrary.GetParamintValue(Param.Params:Get(1));
    local ModifierTag = Param.Params:Get(2).ParamValue
    local OrgBullet = UE4.UAbilityFunctionLibrary.GetParamintValue(Param.Params:Get(3));
    if OrgBullet > 0 and OrgBullet ~= InBullet.CurrentBulletID then
        return
    end

    local EnchantBulletID = UE4.UAbilityFunctionLibrary.GetParamintValue(Param.Params:Get(4));
    local bExsitModieir = false
    if ModifierTag ~= "" then
        local OutModifiers = InHitTarget:FindModifiersByTagName(ModifierTag)
        bExsitModieir = OutModifiers:Length() > 0
    else
        local OutModifier = InHitTarget:FindModifierByID(ModifierID, Modifier:GetLauncher())
        bExsitModieir = OutModifier ~= nil
    end
    if bExsitModieir then
        local Info = UE4.FEnchantBulletInfo()
        Info.EnchantBulletID = EnchantBulletID
        Info.OriginalBulletID = OrgBullet
        Info.BulletLevel = Modifier:GetLevel()
        Info.EnchantAbility = Modifier:GetLauncher()
        InBullet:SetEnchantBulletID(Info, true)
    end
    return 
end

function Magic:OnRemove(AbilityTarget,Modifier, Parameter, CurOverlaid)
    

    return true;
end


return Magic;