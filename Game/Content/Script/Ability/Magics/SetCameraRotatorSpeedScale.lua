---@class Magic_SetCameraRotatorSpeedScale:Magic
local Magic = Ability.DefineMagic('SetCameraRotatorSpeedScale');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    local Scale = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(1));

    if AbilityTarget ~= nil then
        local CharacterOwner = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
        if CharacterOwner ~= nil then
            local PlayerController = CharacterOwner:GetCharacterController();
            if PlayerController ~= nil then
                PlayerController:SetCameraInputScale(Scale);
            end
        end
    end
    return true;
end


function Magic:OnRemove(AbilityTarget, Modifier, Parameter)

    if AbilityTarget ~= nil then
        local CharacterOwner = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
        if CharacterOwner ~= nil then
            local PlayerController = CharacterOwner:GetCharacterController();
            if PlayerController ~= nil then
                PlayerController:SetCameraInputScale(1.0);
            end
        end
    end
    return true;
end

return Magic;