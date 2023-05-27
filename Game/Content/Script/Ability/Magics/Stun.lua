---@class Magic_Stun:Magic
local Magic = Ability.DefineMagic('Stun');

---@param Modifier UModifier
---@param Parameter table
function Magic:GetParameter(Modifier, Parameter)
    return UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(1));
end

---@param Modifier UModifier
---@param Parameter table
function Magic:GetModifyParam(Modifier, Parameter)
    return true, self:GetParameter(Modifier, Parameter);
end

function Magic:GetOrAddRecordTable(AbilityTarget, Modifier)
    if not self.RecordData then
        self.RecordData = {}
    end
    if not self.RecordData[AbilityTarget] then
        self.RecordData[AbilityTarget] = {}
    end

    local AbilityTargetInfo = self.RecordData[AbilityTarget]
    if not AbilityTargetInfo[Modifier] then
        AbilityTargetInfo[Modifier] = {}
    end

    return AbilityTargetInfo[Modifier]
end

function Magic:ClearRecordTable(AbilityTarget, Modifier)
    if self.RecordData and AbilityTarget and self.RecordData[AbilityTarget] and Modifier and self.RecordData[AbilityTarget][Modifier] then
        self.RecordData[AbilityTarget][Modifier] = nil
    end

    if self.RecordData and AbilityTarget and self.RecordData[AbilityTarget] and next(self.RecordData[AbilityTarget]) == nil then
        self.RecordData[AbilityTarget] = nil
    end
end


function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local RecordTable = self:GetOrAddRecordTable(AbilityTarget, Modifier);
    local Launcher = Modifier:GetLauncher();
    local Target = AbilityTarget;

    RecordTable.OpenControlProtection = Target:IsOpenControlProtection()
    local AbnormalInfo = UE4.FAbnormalInfo();
    AbnormalInfo.AbnormalCauser = Launcher:GetOwner();
    AbnormalInfo.AbnormalState = UE4.EAbnormalState.Stun;
    if RecordTable.OpenControlProtection then
        AbnormalInfo.KeepTime = Modifier:GetModifierKeepTime(AbilityTarget);
    else
        AbnormalInfo.KeepTime = Modifier:GetModifierKeepTime();
    end
    AbnormalInfo.AppliedModifierRunTimeID = Modifier.RunTimeID;
    
    if Target ~= nil and RecordTable.OpenControlProtection and AbilityTarget:IsInControlProtectionTimeCall() then
        Target:HandleFlyImmuneControl(Launcher, "modifier.immune")
        Modifier.LifeTime = 0.0;
    elseif Target ~= nil then
        local bSuccess = Target:ReceiveAbnormalState(UE4.EAbnormalState.Stun, AbnormalInfo);
        if bSuccess == false then
            Target:HandleFlyImmuneControl(Launcher, "modifier.immune")
            Modifier.LifeTime = 0.0;
            print("Stun Block")
        elseif RecordTable.OpenControlProtection then
            Target:SetBeginNewAbnormalControlStateCall(UE4.EAbnormalState.Stun)
            RecordTable.MagicBornSuccess = true;
        end
    end
    Modifier:LogReceiveAbnormalState(true)
    return true;
end

function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    local RecordTable = self:GetOrAddRecordTable(AbilityTarget, Modifier);
    local Launcher = Modifier:GetLauncher();
    local Target = AbilityTarget;
    local bNoSuccessBornInProtection = RecordTable.OpenControlProtection and not RecordTable.MagicBornSuccess

    if Target ~= nil and not bNoSuccessBornInProtection then
        Target:RemoveAbnormalState(UE4.EAbnormalState.Stun,Modifier.RunTimeID);
        if RecordTable.MagicBornSuccess then
            Target:SetEndNewAbnormalControlStateCall(UE4.EAbnormalState.Stun)
            RecordTable.MagicBornSuccess = nil;
        end
    end
    
    Modifier:LogReceiveAbnormalState(false)
    self:ClearRecordTable(AbilityTarget, Modifier)
    return true;
end


return Magic;