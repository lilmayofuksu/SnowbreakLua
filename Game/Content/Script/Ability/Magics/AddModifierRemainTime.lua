---@class Magic_AddModifierRemainTime:Magic
local Magic = Ability.DefineMagic('AddModifierRemainTime');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local ModifierID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local AddTime = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(2));

    if AbilityTarget ~= nil then
        local Modifiers = AbilityTarget:FindAllModifierByID(ModifierID, Modifier:GetLauncher());
        if Modifiers:Length() > 0 then
            for i = 1, Modifiers:Length() do
                local M = Modifiers:Get(i);
                if M ~= nil then
                    M:AddRemainingTime(AddTime);
                end
            end
        end
    end

    return true;
end


function Magic:OnExec(AbilityTarget,Modifier, Parameter, CurOverlaid)
    local ModifierID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local AddTime = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(2));

    if AbilityTarget ~= nil then
        local Modifiers = AbilityTarget:FindAllModifierByID(ModifierID, Modifier:GetLauncher());
        if Modifiers:Length() > 0 then
            for i = 1, Modifiers:Length() do
                local M = Modifiers:Get(i);
                if M ~= nil then
                    M:AddRemainingTime(AddTime);
                end
            end
        end
    end

    return true;
end

return Magic;