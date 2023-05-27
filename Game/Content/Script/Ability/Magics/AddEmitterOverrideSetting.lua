---@class Magic_AddEmitterOverrideSetting:Magic
local Magic = Ability.DefineMagic('AddEmitterOverrideSetting');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    local TargetID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local OverrideID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(2));

    if AbilityTarget ~= nil then
        local Buffers = AbilityTarget:GetActiveAbilityBuffer(UE4.UOverrideEmitterBuffer:StaticClass());
        if Buffers:Length() > 0 then
            local OEB = Buffers:Get(1):Cast(UE4.UOverrideEmitterBuffer);
            print("OEB Get : ", OEB:GetName())
            if OEB ~= nil then
                OEB:AddOverrideSetting(TargetID, OverrideID);
            end
        end
    end

    return true; 
end


function Magic:OnRemove(AbilityTarget, Modifier, Parameter)

    local TargetID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local OverrideID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(2));

    if AbilityTarget ~= nil then
        local Buffers = AbilityTarget:GetActiveAbilityBuffer(UE4.UOverrideEmitterBuffer:StaticClass());
        if Buffers:Length() > 0 then
            local OEB = Buffers:Get(1):Cast(UE4.UOverrideEmitterBuffer);
            if OEB ~= nil then
                OEB:RemoveOverrideSetting(TargetID, OverrideID);
            end
        end
    end

    return true;
end

return Magic;