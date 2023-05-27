---@class Magic_ShieldRecoverControl:Magic
local Magic = Ability.DefineMagic('ShieldRecoverControl');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    local bOpen = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(1));

    if AbilityTarget ~= nil then
        local Buffers = AbilityTarget:GetActiveAbilityBuffer(AbilityTarget.ShieldRecoverClass);
        for i = 1 , Buffers:Length() > 0 do
            local ShieldRecoverBuffer = Buffers:Get(i);
            if ShieldRecoverBuffer ~= nil then
                if bOpen == false then
                    ShieldRecoverBuffer:DelayAbilityAttribute(AbilityTarget:K2_GetCardGrowTemplateData().ShieldDelayTime);
                else
                    ShieldRecoverBuffer:DelayAbilityAttribute(0);
                end
            end
        end
    end
    
    return true;
end

return Magic;