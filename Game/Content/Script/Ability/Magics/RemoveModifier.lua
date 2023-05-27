---@class Magic_RemoveModifier:Magic  移除x层某modifier。配置项：层数、modifierID、modifierTag。
local Magic = Ability.DefineMagic('RemoveModifier');

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

function Magic:RemoveModidier(AbilityTarget, Modifier, Parameter)
    local RemoveOverlaidCount = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    if RemoveOverlaidCount <= 0 then return end
    local ModifierID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(2));
    local ModifierTag = ""
    if Parameter.Params:Length() >= 3 then
        ModifierTag = Parameter.Params:Get(3).ParamValue
    end
    if not AbilityTarget then return end
    local AllModifier = nil
    if ModifierID > 0 then
        AllModifier = AbilityTarget:FindAllModifierByID(ModifierID, Modifier:GetLauncher())
    else
        AllModifier = AbilityTarget:FindModifiersByTagName(ModifierTag)
    end
    if not AllModifier then return end
    for i = 1, AllModifier:Length() do
        local Modifier = AllModifier:Get(i)
        if Modifier then
            Modifier:RemoveOverlaid(RemoveOverlaidCount)
        end
    end
    return true
end
return Magic