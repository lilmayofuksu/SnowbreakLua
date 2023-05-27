---@class Magic_DamageScaler:Magic
local Magic = Ability.DefineMagic('CheckHitType');

function Magic:OnModifierHitCheck(HitLauncher, Modifier, Parameter, HitType, OriginID)
    
    local CheckHitType = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local CheckOriginID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(2));
    local bIgnoreOthers = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(3));
    local CharacterID = 0;
    if Parameter.Params:Length() > 3 then
        CharacterID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(4));
    end
    local OnlySpecificType = false;
    if Parameter.Params:Length() > 4 then
        OnlySpecificType = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(5));
    end
    local OnlySpecificType = false;
    if Parameter.Params:Length() > 4 then
        OnlySpecificType = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(5));
    end
    local BulletWillThrugh = false;
    if Parameter.Params:Length() > 5 then
        BulletWillThrugh = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(6));
    end
    local Launcher = Modifier:GetLauncher();
    local LauncherChar = Launcher:GetOriginCharacter();
    local HitLauncherChar = HitLauncher:GetOriginCharacter();
    local HitCharacterID = HitLauncherChar:GetCharacterCardID();


    local bCheckRelation = true;
    if Parameter.Params:Length() > 6 then
        local tbCampRelation = UE4.UAbilityFunctionLibrary.GetCampRelationValue(Parameter.Params:Get(7))
        local Relation = UE4.UAbilityFunctionLibrary.GetRelation(LauncherChar, HitLauncherChar)
        bCheckRelation = not tbCampRelation:Contains(Relation)
    end

    if not bCheckRelation then
        return false, BulletWillThrugh;
    end

    local bApplyEffect = true;
    local BulletThrough = true;
    if HitLauncher ~= nil then
        if HitType == CheckHitType then
            if HitType == 0 then
                if bIgnoreOthers == true then
                    if HitLauncher ~= Launcher then
                        bApplyEffect = false;
                        return bApplyEffect, BulletWillThrugh;
                    end
                end
                if CharacterID > 0 and HitLauncherChar:GetCharacterCardID() ~= CharacterID then
                    bApplyEffect = false;
                    return bApplyEffect, BulletWillThrugh;
                end
                bApplyEffect = true;
                return bApplyEffect, BulletWillThrugh;
            else
                if CheckOriginID <= 0 then 
                    return true, BulletWillThrugh;
                end
                if OriginID == CheckOriginID then
                    if bIgnoreOthers == true then
                        if HitLauncher ~= Launcher then
                            bApplyEffect = false;
                        end
                    end
                    
                    if CharacterID > 0 and HitLauncherChar:GetCharacterCardID() ~= CharacterID then
                        bApplyEffect = false;
                        return bApplyEffect, BulletWillThrugh;
                    end
                    bApplyEffect = true;
                    return bApplyEffect, BulletWillThrugh;
                else
                    bApplyEffect = false;
                    return bApplyEffect, BulletWillThrugh;
                end
            end
        end
        if HitType ~= CheckHitType and OnlySpecificType == false then
            if CheckHitType ~= -1 then
                
                bApplyEffect =  false;
                return bApplyEffect, BulletWillThrugh;
            else
                if bIgnoreOthers == true then
                    if HitLauncher ~= Launcher then
                        bApplyEffect =  false;
                        return bApplyEffect, BulletWillThrugh;
                    end
                end
                
                if CharacterID > 0 and HitLauncherChar:GetCharacterCardID() ~= CharacterID then
                    bApplyEffect =  false;
                    return bApplyEffect, BulletWillThrugh;
                end
                bApplyEffect =  true;
                return bApplyEffect, BulletWillThrugh;
            end
        end

    end
    return bApplyEffect, BulletWillThrugh;
end

return Magic;