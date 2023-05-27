---@class Magic_ShowSpecialFightUI:Magic
local Magic = Ability.DefineMagic('ShowSpecialFightUI');


function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    if AbilityTarget and Modifier then
        local CharacterOwner = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
        if CharacterOwner ~= nil then
            CharacterOwner = UE4.UAbilityFunctionLibrary.GetOriginPlayer(CharacterOwner)
            if CharacterOwner ~= nil then
                local PlayerController = CharacterOwner:GetCharacterController();
                if PlayerController ~= nil then
                    PlayerController:ShowOrHideSpecialFightUI(Modifier.ID, Parameter, true);
                end
            end
        end
    end
    return true;
end

function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    if AbilityTarget ~= nil and Modifier then
        local CharacterOwner = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
        if CharacterOwner ~= nil then
            CharacterOwner = UE4.UAbilityFunctionLibrary.GetOriginPlayer(CharacterOwner)
            if CharacterOwner ~= nil then
                local PlayerController = CharacterOwner:GetCharacterController();
                if PlayerController ~= nil then
                    PlayerController:ShowOrHideSpecialFightUI(Modifier.ID, Parameter, false);
                end
            end
        end
    end
    return true;
end


return Magic;