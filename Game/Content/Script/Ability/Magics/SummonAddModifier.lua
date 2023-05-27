---@class Magic_SummonAddModifier:Magic
local Magic = Ability.DefineMagic('SummonAddModifier');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    local InLevel = 1
    if not Modifier then return end

    InLevel = Modifier:GetLevel()
    Modifier.bBindOnNotifySummon = true
    
    local ParamsLength = Parameter.Params:Length()
    local ModifierID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1))
    local bUseLancher = false
    if ParamsLength >= 2 then
        bUseLancher = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(2))
    end
    local CurLancher = bUseLancher and Modifier:GetLauncher() or AbilityTarget
    local lpCharacter = AbilityTarget:GetOriginCharacter()
    if not lpCharacter then return end
    local AllSummon = UE4.TArray(UE4.AGameCharacter)
    lpCharacter:GetAllSummoned(AllSummon)
    for i = 1, AllSummon:Length() do
        local lpSummon = AllSummon:Get(i)       
        if lpSummon then
            if lpSummon:IsMinion() then            
                UE4.UModifier.MakeModifier(ModifierID, AbilityTarget, CurLancher, lpSummon.Ability, nil, lpSummon:K2_GetActorLocation(), lpSummon:K2_GetActorLocation(), 1, InLevel)
            end
        end
    end
end
function Magic:OnNotifySummon(AbilityTarget,Modifier, Parameter, InSummon)
    if not InSummon then return end
    if not Modifier then return end
    local InLevel = Modifier:GetLevel()
    local ParamsLength = Parameter.Params:Length()
    local ModifierID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1))
    local bUseLancher = false
    if ParamsLength >= 2 then
        bUseLancher = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(2))
    end
    local CurLancher = bUseLancher and Modifier:GetLauncher() or AbilityTarget
    if not InSummon:IsMinion() then return end
    UE4.UModifier.MakeModifier(ModifierID, AbilityTarget, CurLancher, InSummon.Ability, nil, InSummon:K2_GetActorLocation(), InSummon:K2_GetActorLocation(), 1, InLevel)
    return true;
end

function Magic:OnRemove(AbilityTarget,Modifier, Parameter, CurOverlaid)
    if not Modifier then return end
    local ParamsLength = Parameter.Params:Length()
    local ModifierID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1))
    local bUseLancher = false
    if ParamsLength >= 2 then
        bUseLancher = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(2))
    end
    local CurLancher = bUseLancher and Modifier:GetLauncher() or AbilityTarget
    local lpCharacter = AbilityTarget:GetOriginCharacter()
    if not lpCharacter then return end
    local AllSummon = UE4.TArray(UE4.AGameCharacter)
    lpCharacter:GetAllSummoned(AllSummon)
    for i = 1, AllSummon:Length() do
        local lpSummon = AllSummon:Get(i)       
        if lpSummon then
            if lpSummon:IsMinion() then            
                lpSummon.Ability:RemoveModifierFormModifierID(ModifierID, CurLancher)
            end
        end
    end
end


return Magic;