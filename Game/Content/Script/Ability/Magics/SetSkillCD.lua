---@class Magic_SetSkillCD:Magic
local Magic = Ability.DefineMagic('SetSkillCD');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    local Params = Parameter.Params
    local SkillID = UE4.UAbilityFunctionLibrary.GetParamintValue(Params:Get(1));

    local AvaliableSkillInfo = AbilityTarget:K2_GetAvaliableSkillInfo(SkillID);
    local nSkillLevel = 1
    if AvaliableSkillInfo then
        nSkillLevel = AvaliableSkillInfo.SkillLevel
    end
    local TempSkillCD = UE4.UAbilityFunctionLibrary.GetParamfloatValueForLevel(Params:Get(2), nSkillLevel);
    local UsePercentChange = UE4.UAbilityFunctionLibrary.GetParamboolValue(Params:Get(3));
    local SkillTag = UE4.FString("");
    if Params:Length() > 3 then
        SkillTag =  Params:Get(4).ParamValue;
    end
    local SkillTypes = UE4.TArray(UE4.FString)
    if Params:Length() > 4 then
        SkillTypes = UE4.UAbilityFunctionLibrary.GetStringArrayValue(Params:Get(5));
    end
    local bUseAdditionChange = false;
    if Params:Length() > 5 then
        bUseAdditionChange = UE4.UAbilityFunctionLibrary.GetParamboolValue(Params:Get(6));
    end

    if AbilityTarget ~= nil then
        if SkillTypes:Length() > 0 then
            AbilityTarget:SetSkillTempCDBySkillType(SkillTypes, TempSkillCD, UsePercentChange);
        else
            if UE4.UKismetStringLibrary.IsEmpty(SkillTag) == false then
                AbilityTarget:SetSkillTempCDByTagName(SkillTag, TempSkillCD,UsePercentChange);
            else
                if bUseAdditionChange == true then 
                    local CurrentCD = AbilityTarget:GetSkillUsingCD(AvaliableSkillInfo);
                    TempSkillCD = TempSkillCD + CurrentCD;
                    if TempSkillCD < 0.0 then
                        TempSkillCD = 0.01
                    end
                end
                AbilityTarget:SetSkillTempCD(SkillID, TempSkillCD,UsePercentChange);
            end
        end
    end
    return true;
end


function Magic:OnRemove(AbilityTarget, Modifier, Parameter)
    local Params = Parameter.Params
    local SkillID = UE4.UAbilityFunctionLibrary.GetParamintValue(Params:Get(1));
    local SkillTag = UE4.FString("");
    if Params:Length() > 3 then
        SkillTag =  Params:Get(4).ParamValue;
    end
    local SkillTypes = UE4.TArray(UE4.FString)
    if Params:Length() > 4 then
        SkillTypes = UE4.UAbilityFunctionLibrary.GetStringArrayValue(Params:Get(5));
    end

    if AbilityTarget ~= nil then
        if SkillTypes:Length() > 0 then
            AbilityTarget:SetSkillTempCDBySkillType(SkillTypes, -1, false);
        else
            if UE4.UKismetStringLibrary.IsEmpty(SkillTag) == false then
                AbilityTarget:SetSkillTempCDByTagName(SkillTag, -1, false);
            else
                AbilityTarget:SetSkillTempCD(SkillID, -1, false);
            end
        end

    end
    return true;
end

return Magic;