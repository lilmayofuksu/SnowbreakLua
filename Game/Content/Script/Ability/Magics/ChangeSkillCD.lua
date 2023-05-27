---@class Magic_ChangeSkillCD:Magic
local Magic = Ability.DefineMagic('ChangeSkillCD');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    local SkillID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local CoolTagName = Parameter.Params:Get(2).ParamValue;
    local bPercent = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(3));
    local CDModifyValue = UE4.UAbilityLibrary.GetFloatValueStringForLevel(Parameter.Params:Get(4).ParamValue, Modifier:GetLevel());
    if bPercent then
        CDModifyValue = CDModifyValue/100
    end
    local ChangeType = 0;
    if Parameter.Params:Length() > 4 then
        if Parameter.Params:Get(5).ParamValue == "ChargingSkill" then
            ChangeType = 1;
        end
        
        if Parameter.Params:Get(5).ParamValue == "NonChargingSkill" then
            ChangeType = 2;
        end
    end

    local Types = UE4.TArray(UE4.FString);
    if Parameter.Params:Length() > 5 then
        Types = UE4.UAbilityFunctionLibrary.GetStringArrayValue(Parameter.Params:Get(6));
    end
    if Parameter.Params:Length() > 6 then
        local bCaculateOverlaid = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(7));
        if bCaculateOverlaid then
            -- print("CDModifyValue:   ", CDModifyValue, "       CurOverlaid:   ", Modifier.CurOverlaid)
            CDModifyValue = CDModifyValue * Modifier.CurOverlaid;
            -- print("CaculateCDModifyValue:   ", CDModifyValue)
        end
    end
    if Types:Length() > 0 then
        AbilityTarget:ChangeSkillCDBySkillType(Types, CDModifyValue, bPercent,ChangeType);
    else
        if ChangeType == 0 then
            AbilityTarget:ChangeSkillCD(SkillID, CDModifyValue,bPercent);
            AbilityTarget:ChangeSkillCDByTagName(CoolTagName,  CDModifyValue,bPercent);
        end
        if ChangeType == 1 then
            AbilityTarget:ChangeAllChargingSkill(CDModifyValue,bPercent);
        end
        if ChangeType == 2 then
            AbilityTarget:ChangeAllNonChargingSkill(CDModifyValue,bPercent);
        end
    end

    return true;
end

function Magic:OnExec(AbilityTarget,Modifier, Parameter, CurOverlaid)
    local SkillID = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    local CoolTagName = Parameter.Params:Get(2).ParamValue;
    local bPercent = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(3));
    local CDModifyValue = UE4.UAbilityLibrary.GetFloatValueStringForLevel(Parameter.Params:Get(4).ParamValue, Modifier:GetLevel());
    if bPercent then
        CDModifyValue = CDModifyValue/100
    end
    local ChangeType = 0;
    if Parameter.Params:Length() > 4 then
        if Parameter.Params:Get(5).ParamValue == "ChargingSkill" then
            ChangeType = 1;
        end
        
        if Parameter.Params:Get(5).ParamValue == "NonChargingSkill" then
            ChangeType = 2;
        end
    end
    if Parameter.Params:Length() > 6 then
        local bCaculateOverlaid = UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(7));
        if bCaculateOverlaid then
            CDModifyValue = CDModifyValue * Modifier.CurOverlaid;
        end
    end

    if ChangeType == 0 then
        AbilityTarget:ChangeSkillCD(SkillID, CDModifyValue,bPercent,ChangeType);
        AbilityTarget:ChangeSkillCDByTagName(CoolTagName,  CDModifyValue,bPercent);
    end
    if ChangeType == 1 then
        AbilityTarget:ChangeAllChargingSkill(CDModifyValue,bPercent);
    end
    if ChangeType == 2 then
        AbilityTarget:ChangeAllNonChargingSkill(CDModifyValue,bPercent);
    end
    
    return true;
end


return Magic;